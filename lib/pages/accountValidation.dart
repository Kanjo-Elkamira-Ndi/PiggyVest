import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:another_flushbar/flushbar.dart';
import '../models/validationData.dart';
import '../apiCalls/auth_service.dart';

class AccountValidationScreen extends StatefulWidget {
  final ValidationData validationData;

  const AccountValidationScreen({
    Key? key,
    required this.validationData,
  }) : super(key: key);

  @override
  _ValidationScreenState createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<AccountValidationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _codeControllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  // Method to get the complete verification code
  String get _verificationCode {
    return _codeControllers.map((controller) => controller.text).join();
  }

  // Method to handle code input and auto-focus
  void _handleCodeInput(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-submit when all fields are filled
    if (_verificationCode.length == 6) {
      _handleValidation();
    }
  }

  // Method to handle account validation - NOW WITH REAL API CALL
  void _handleValidation() async {
    if (_verificationCode.length != 6) {
      _showErrorMessage("Please enter the complete 6-digit code");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the actual API
      final result = await AuthService.verifyAccount(code: _verificationCode);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        _showSuccessMessage(result['message'] ?? "Account validated successfully!");
        // Navigate to next screen
        await Future.delayed(Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorMessage(result['message'] ?? "Invalid verification code. Please try again.");
        _clearCode();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage("An error occurred. Please try again.");
      _clearCode();
    }
  }

  // Method to resend verification code - NOW WITH REAL API CALL
  void _resendCode() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      // Call the actual API - using email or phone from validationData
      final result = await AuthService.resendCode(
        email_or_tell: widget.validationData.email, // or phone if you have it
      );

      setState(() {
        _isResending = false;
      });

      if (result['success']) {
        setState(() {
          _resendCountdown = 60;
        });
        _showSuccessMessage(result['message'] ?? "Verification code sent to ${widget.validationData.email}");
        _startCountdown();
      } else {
        _showErrorMessage(result['message'] ?? "Failed to resend code. Please try again.");
      }
    } catch (e) {
      setState(() {
        _isResending = false;
      });
      _showErrorMessage("An error occurred while resending code. Please try again.");
    }
  }

  // Method to start countdown for resend button
  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        _startCountdown();
      }
    });
  }

  // Method to clear all code inputs
  void _clearCode() {
    for (var controller in _codeControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  // Method to show success message
  void _showSuccessMessage(String message) {
    Flushbar(
      message: message,
      backgroundColor: Colors.green[600]!,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      icon: Icon(Icons.check_circle, color: Colors.white),
    ).show(context);
  }

  // Method to show error message
  void _showErrorMessage(String message) {
    Flushbar(
      message: message,
      backgroundColor: Colors.red[600]!,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      icon: Icon(Icons.error, color: Colors.white),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
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
                constraints: BoxConstraints(maxWidth: 900),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Card(
                      elevation: 20,
                      shadowColor: Color(0xFFF1EA00).withAlpha(30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
                        child: isTablet
                            ? _buildTabletLayout()
                            : _buildMobileLayout(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        SizedBox(height: 48),
        Row(
          children: [
            Expanded(child: _buildIllustration()),
            SizedBox(width: 32),
            Expanded(child: _buildValidationForm()),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        SizedBox(height: 32),
        _buildValidationForm(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFFF1EA00).withAlpha(10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read,
            size: 40,
            color: Colors.green[700],
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Verify Your Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            children: [
              TextSpan(text: 'We\'ve sent a 6-digit verification code to\n'),
              TextSpan(
                text: widget.validationData.email,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[100]!, Colors.green[50]!],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.security,
              size: 80,
              color: Colors.green[700],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Secure Verification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'Enter the 6-digit code to verify your identity and secure your account.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildValidationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Verification Code Input
          Text(
            'Enter Verification Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),

          // Code Input Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) => _buildCodeBox(index)),
          ),
          SizedBox(height: 32),

          // Verify Button
          Container(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleValidation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: Colors.green.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Verifying...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
                  : Text(
                'Verify Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 24),

          // Resend Code Section
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't receive the code? ",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: _resendCountdown > 0 || _isResending ? null : _resendCode,
                child: Text(
                  _resendCountdown > 0
                      ? 'Resend in ${_resendCountdown}s'
                      : _isResending
                      ? 'Sending...'
                      : 'Resend Code',
                  style: TextStyle(
                    color: _resendCountdown > 0 || _isResending
                        ? Colors.grey[500]
                        : Colors.green[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: _resendCountdown > 0 || _isResending
                        ? TextDecoration.none
                        : TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Back to Sign Up
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Back to Sign Up',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBox(int index) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _codeControllers[index].text.isNotEmpty
              ? Colors.green[700]!
              : Colors.grey[300]!,
          width: _codeControllers[index].text.isNotEmpty ? 2 : 1.5,
        ),
        color: _codeControllers[index].text.isNotEmpty
            ? Colors.green[50]
            : Colors.grey[50],
      ),
      child: TextFormField(
        controller: _codeControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          _handleCodeInput(index, value);
          setState(() {}); // Refresh UI for color changes
        },
        onTap: () {
          _codeControllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: _codeControllers[index].text.length),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}