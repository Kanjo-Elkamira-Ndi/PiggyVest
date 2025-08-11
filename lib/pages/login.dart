import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:piggyvest/apiCalls/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 768;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE8F5E8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
              child: ConstrainedBox(
                // Constraint maximum width for larger screens
                constraints: BoxConstraints(maxWidth: 1200),
                child: Card(
                  elevation: 12,
                  shadowColor: Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
                    child: isTablet
                        ? _buildTabletLayout() // Row layout for tablets/desktop
                        : _buildMobileLayout(), // Column layout for mobile
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // TABLET/DESKTOP LAYOUT - Uses Row (Horizontal arrangement)
  Widget _buildTabletLayout() {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Left side - Image and message
          Expanded(
            flex: 1,
            child: _buildImageSection(),
          ),
          // Divider line
          Container(
            width: 1,
            margin: EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[200]!,
                  Color(0xFFF1EA00).withOpacity(0.3),
                  Colors.grey[200]!,
                ],
              ),
            ),
          ),
          // Right side - Form
          Expanded(
            flex: 1,
            child: _buildFormSection(),
          ),
        ],
      ),
    );
  }

  // MOBILE LAYOUT - Uses Column (Vertical arrangement)
  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildImageSection(),
        SizedBox(height: 32),
        _buildFormSection(),
      ],
    );
  }

  // IMAGE SECTION - Reusable widget
  Widget _buildImageSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Container for image with styling
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green[700]!,
                  Color(0xFFF1EA00).withAlpha(100),
                ],
              ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.lock_person_rounded,
            size: 80,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 24),
        // Welcome message
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Sign in to your account to continue',
          style: TextStyle(
            fontSize: 16,
            color: Colors.green[400],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // FORM SECTION - Reusable widget
  Widget _buildFormSection() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sign In',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),

          // Email/Phone field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email or Phone',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black45, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email or phone';
              }
              return null;
            },
          ),
          SizedBox(height: 20),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black45, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 12),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Handle forgot password
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Forgot password clicked')),
                );
              },
              child: Text('Forgot Password?',
              style: TextStyle(
                color: Colors.green[700]
              ),)
            ),
          ),
          SizedBox(height: 24),

          // Login button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: _isLoading
                ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              'Sign In',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),

          // Sign up link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextButton(
                onPressed: () {Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final result = await AuthService.login(
          email_or_phone: _emailController.text.trim(),
          password: _passwordController.text.trim(),
      );

      if (result['success']) {
        // Show success message
        Flushbar(
          messageText: Text(
            "Login successful!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold),
          ), // "Login successful!"
          duration: Duration(seconds: 2),
          backgroundColor: Colors.white,
          margin: EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          flushbarPosition: FlushbarPosition.TOP, // 👈 This makes it appear at the top
        ).show(context);

        Navigator.pushNamed(
            context,
            '/validation');
      }

      // Simulate login delay
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}