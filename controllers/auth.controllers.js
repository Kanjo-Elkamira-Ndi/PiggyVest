import bcryptjs from 'bcryptjs';
import pool from '../config/database.js'; // Assuming you have a database config
import { generateTokenAndSetCookie } from '../utils/gen_token.js';
import sendEmail  from '../utils/email.js'

// Input validation functions
function isEmail(input) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(input);
}

function isPhoneNumber(input) {
  const phoneRegex = /^\+?[1-9]\d{1,14}$/; // More strict E.164 format
  return phoneRegex.test(input);
}

function detectLoginType(input) {
  if (isEmail(input)) {
    return "email";
  } else if (isPhoneNumber(input)) {
    return "tell";
  } else {
    return "invalid";
  }
}

// Utility function to sanitize user data
function sanitizeUser(user) {
  const { password, token, token_expire_at, ...sanitizedUser } = user;
  return sanitizedUser;
}

// Utility function to generate verification token
function generateVerificationToken() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Utility function to generate token expiration date
function generateExpirationDate(hours = 24) {
  return new Date(Date.now() + hours * 60 * 60 * 1000);
}

export const signup = async (req, res) => {
  try {
    console.log("Signup request received:", req.body);
    const { fname, lname, dob, region, email, tell, password } = req.body;

    // Input validation
    if ((!fname && !lname) || !dob || !email || !tell || !password) {
      console.error("Validation error: Missing required fields");
      return res.status(400).json({ 
        success: false,
        message: "All fields are required. At least one name (first or last) must be provided." 
      });
    }
    console.log("Input validation passed");
    // Additional validation
    if (!isEmail(email)) {
      return res.status(400).json({
        success: false,
        message: "Please provide a valid email address"
      });
    }
    console.log("Email validation passed");
    if (!isPhoneNumber(tell)) {
      return res.status(400).json({
        success: false,
        message: "Please provide a valid phone number"
      });
    }
    console.log("Phone number validation passed");
    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: "Password must be at least 6 characters long"
      });
    }
    console.log("Password validation passed");
    // Check if user already exists
    const existingUser = await pool.query(
      `SELECT id FROM users WHERE email = $1 OR tell = $2`,
      [email.toLowerCase().trim(), tell.trim()]
    );
    console.log("Checked for existing user");
    if (existingUser.rows.length > 0) {
      return res.status(409).json({
        success: false,
        message: "User with this email or phone number already exists"
      });
    }

    // Hash password and generate verification token
    const hashedPassword = await bcryptjs.hash(password, 12); // Increased rounds for better security
    const verificationToken = generateVerificationToken();
    const expirationDate = generateExpirationDate(24);

    // Insert new user
    const result = await pool.query(
      `INSERT INTO users (fname, lname, dob, region, email, tell, password, token, token_expire_at, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, CURRENT_TIMESTAMP)
       RETURNING *`,
      [
        fname?.trim() || null, 
        lname?.trim() || null, 
        dob, 
        region?.trim() || null, 
        email.toLowerCase().trim(), 
        tell.trim(), 
        hashedPassword, 
        verificationToken, 
        expirationDate
      ]
    );

    const user = result.rows[0];
    const sanitizedUser = sanitizeUser(user);

    // Send verification email
    await sendEmail(verificationToken);

    res.status(201).json({ 
      success: true, 
      message: "User created successfully. Please check your email/SMS for verification code.", 
      user: sanitizedUser,
      verificationToken // Remove this in production, only for testing
    });

  } catch (error) {
    console.error("Error in signup:", error);
    
    // Handle specific database errors
    if (error.code === '23505') { // PostgreSQL unique constraint error
      return res.status(409).json({ 
        success: false, 
        message: "User with this email or phone number already exists" 
      });
    }

    res.status(500).json({ 
      success: false, 
      message: "Internal server error. Please try again later." 
    });
  }
};

export const verifyAccount = async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({ 
        success: false,
        message: "Verification token is required" 
      });
    }

    if (!/^\d{6}$/.test(token)) {
      return res.status(400).json({
        success: false,
        message: "Invalid token format. Token should be 6 digits."
      });
    }

    // Find user with valid token
    const result = await pool.query(
      `SELECT id, email, tell, is_verified FROM users 
       WHERE token = $1 AND token_expire_at > CURRENT_TIMESTAMP`,
      [token]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ 
        success: false,
        message: "Invalid or expired verification token" 
      });
    }

    const user = result.rows[0];

    if (user.is_verified) {
      return res.status(400).json({
        success: false,
        message: "Account is already verified"
      });
    }

    // Update user verification status
    await pool.query(
      `UPDATE users 
       SET is_verified = true, token = NULL, token_expire_at = NULL, verified_at = CURRENT_TIMESTAMP 
       WHERE id = $1`,
      [user.id]
    );

    res.status(200).json({ 
      success: true, 
      message: "Account verified successfully! You can now log in." 
    });

  } catch (error) {
    console.error("Error in verifyAccount:", error);
    res.status(500).json({ 
      success: false, 
      message: "Internal server error. Please try again later." 
    });
  }
};

export const login = async (req, res) => {
  try {
    const { email_or_phone, password } = req.body;
    console.log(req.body)
    // Input validation
    if (!email_or_phone || !password) {
      console.log("Validation error: Missing email/phone or password");
      return res.status(400).json({ 
        success: false,
        message: "Email/phone and password are required" 
      });
    }

    const identifier = detectLoginType(email_or_phone.trim());
    console.log("Detected identifier type:", identifier);
    if (identifier === "invalid") {
      return res.status(400).json({ 
        success: false,
        message: "Invalid email or phone number format" 
      });
    }

    // Use prepared statements for security
    let query;
    let queryParams;
    console.log("Preparing database query");
    if (identifier === "email") {
      query = `SELECT * FROM users WHERE email = $1`;
      queryParams = [email_or_phone.toLowerCase().trim()];
    } else {
      query = `SELECT * FROM users WHERE tell = $1`;
      queryParams = [email_or_phone.trim()];
    }

    // Find user
    const userResult = await pool.query(query, queryParams);
    const user = userResult.rows[0];
    
    if (!user) {
      return res.status(401).json({ 
        success: false, 
        message: "Invalid credentials" 
      });
    }
    console.log("User fetched from database:", user);

    // Check if account is verified
    if (!user.is_verified) {
      return res.status(403).json({ 
        success: false, 
        is_verified: false,
        message: "Account not verified. Please check your email/SMS for verification code." 
      });
    }
    console.log("Account is verified");

    // Verify password
    const isPasswordValid = await bcryptjs.compare(password, user.password);
    if (!isPasswordValid) {
      console.log('password invalid')
      return res.status(401).json({ 
        success: false, 
        message: "Invalid credentials" 
      });
    }
    console.log("Password is valid");
    // Generate and set authentication cookie/token
    const authToken = generateTokenAndSetCookie(res, user.id, user.role);

    // Update last login timestamp
    await pool.query(
      `UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = $1`,
      [user.id]
    );
    console.log("Last login timestamp updated");
    // Return success response with sanitized user data
    const sanitizedUser = sanitizeUser(user);
    
    res.status(200).json({
      success: true,
      message: "Logged in successfully",
      isVerified: true,
      token: authToken,
      user: sanitizedUser
    });

  } catch (error) {
    console.error("Error in login:", error);
    res.status(500).json({ 
      success: false, 
      message: "Internal server error. Please try again later." 
    });
  }
};

export const resendVerificationToken = async (req, res) => {
  try {
    const { email_or_phone } = req.body;

    if (!email_or_phone) {
      return res.status(400).json({
        success: false,
        message: "Email or phone number is required"
      });
    }

    const identifier = detectLoginType(email_or_phone.trim());
    
    if (identifier === "invalid") {
      return res.status(400).json({
        success: false,
        message: "Invalid email or phone number format"
      });
    }

    let query;
    let queryParams;

    if (identifier === "email") {
      query = `SELECT id, email, tell, is_verified FROM users WHERE email = $1`;
      queryParams = [email_or_phone.toLowerCase().trim()];
    } else {
      query = `SELECT id, email, tell, is_verified FROM users WHERE tell = $1`;
      queryParams = [email_or_phone.trim()];
    }

    const userResult = await pool.query(query, queryParams);
    const user = userResult.rows[0];

    if (!user) {
      // Don't reveal if user exists or not for security
      return res.status(200).json({
        success: true,
        message: "If an account with this email/phone exists, a verification code will be sent."
      });
    }

    if (user.is_verified) {
      return res.status(400).json({
        success: false,
        message: "Account is already verified"
      });
    }

    // Generate new verification token
    const newToken = generateVerificationToken();
    const newExpiration = generateExpirationDate(24);

    await pool.query(
      `UPDATE users SET token = $1, token_expire_at = $2 WHERE id = $3`,
      [newToken, newExpiration, user.id]
    );

    // TODO: Send new verification email/SMS
    await sendEmail(newToken);

    res.status(200).json({
      success: true,
      message: "New verification code sent successfully",
      verificationToken: newToken // Remove this in production
    });

  } catch (error) {
    console.error("Error in resendVerificationToken:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error. Please try again later."
    });
  }
};