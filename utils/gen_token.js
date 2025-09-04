import jwt from 'jsonwebtoken';

const secretKey = process.env.JWT_SECRET;

export const  generateTokenAndSetCookie = (res, userId, userRole) => {
    const token = jwt.sign({ userId, role:userRole}, secretKey, {
        expiresIn: "7d",
    })
    res.cookie("token", token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "strict",
        maxAge: 7 * 24 * 60 * 60 * 1000,    
    });
    return token;
}

export const extractTokenInfo = (req) => {
    // get id from the token
    const token = req.headers.authorization.split(' ')[1];
    console.log(token);
    if (!token) {
        return null;
    }
    try {
        const decoded = jwt.verify(token, secretKey);
        return decoded;
    } catch (error) {
        return null;
    }
}