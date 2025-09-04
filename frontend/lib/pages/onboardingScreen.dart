import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4ECDC4), // Teal
              Color(0xFF44A08D), // Darker teal
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Page content
              Expanded(
                flex: 5,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildFirstPage(),
                    _buildSecondPage(),
                    _buildThirdPage(),
                  ],
                ),
              ),

              // Page indicator and buttons
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Page indicator dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 30),

                    // Navigation buttons
                    Row(
                      children: [
                        // Previous button (only show after first page)
                        if (_currentPage > 0)
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: _previousPage,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'Back',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        if (_currentPage > 0) const SizedBox(width: 15),

                        // Next/Action button
                        Expanded(
                          flex: _currentPage == 0 ? 1 : 1,
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentPage == 2) {
                                  // Navigate to signup on last page
                                  Navigator.pushReplacementNamed(context, '/signup');
                                } else {
                                  _nextPage();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF4ECDC4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                _currentPage == 2 ? 'Get Started' : 'Next',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Login button (always visible)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstPage() {
    return Column(
      children: [
        // Top section with geometric shapes
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              // Yellow/Orange geometric shape - top right
              Positioned(
                top: 0,
                right: -50,
                child: Container(
                  width: 200,
                  height: 150,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFA726), // Orange
                        Color(0xFFFFD54F), // Yellow
                      ],
                    ),
                  ),
                  transform: Matrix4.identity()..rotateZ(-0.2),
                ),
              ),
              // Large teal cube with leaf icon
              Positioned(
                top: 80,
                left: 30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4ECDC4), Color(0xFF26A69A)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(5, 5),
                      ),
                    ],
                  ),
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(0.1)
                    ..rotateY(-0.1),
                  child: const Center(
                    child: Icon(Icons.eco, color: Colors.white, size: 40),
                  ),
                ),
              ),
              // Small orange cube with checkmark
              Positioned(
                top: 220,
                right: 60,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFA726), Color(0xFFFF8F00)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(-0.1)
                    ..rotateY(0.1),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              // Additional geometric shapes for depth
              Positioned(
                top: 160,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA726).withOpacity(0.3),
                  ),
                  transform: Matrix4.identity()..rotateZ(0.3),
                ),
              ),
            ],
          ),
        ),
        // Content section
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'What can I do?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Want to buy a car, contribute to a friend\'s wedding or just have emergency backup funds? Don\'t worry, we\'ve got you covered',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondPage() {
    return Column(
      children: [
        // Top section with profile images and connecting lines
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              // Dotted connecting lines
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 300),
                painter: DottedLinePainter(),
              ),
              // Profile images with placeholder containers (since images may not exist)
              _buildProfileImage(-30, null, 100, 80, 80, null),
              _buildProfileImage(80, 30, null, 100, 100, Icons.message),
              _buildProfileImage(180, null, 40, 120, 120, Icons.bolt),
              // Small decorative circles
              Positioned(
                bottom: 20,
                left: 50,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Leaf decoration
              Positioned(
                top: 150,
                left: 180,
                child: Transform.rotate(
                  angle: -0.3,
                  child: const Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content section
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'What do I stand to gain?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Financial discipline in realizing goals & up to 4% PA cash bonus on your savings',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThirdPage() {
    return Column(
      children: [
        // Top section with image collage (using placeholder containers)
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              // Image placeholders with different colors and icons
              _buildImagePlaceholder(20, 20, null, 100, 140, Icons.person, const Color(0xFFFFA726)),
              _buildImagePlaceholder(10, 140, null, 120, 100, Icons.attach_money, const Color(0xFF66BB6A)),
              _buildImagePlaceholder(20, null, 20, 80, 120, Icons.person_outline, const Color(0xFFEF5350)),
              _buildImagePlaceholder(130, 30, null, 90, 120, Icons.headphones, const Color(0xFF42A5F5)),
              _buildImagePlaceholder(150, 160, null, 110, 130, Icons.phone_android, const Color(0xFFAB47BC)),
              _buildImagePlaceholder(220, null, 15, 90, 120, Icons.business, const Color(0xFF26A69A)),
            ],
          ),
        ),
        // Content section
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Welcome to Nkwa',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF7CB342), // Green heart background
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nkwa is a digital wooden bank that lets you plan and set aside money for things that matter to you',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(double top, double? left, double? right, double? width, double height, IconData? icon) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Stack(
        children: [
          Container(
            width: width ?? 100,
            height: height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          if (icon != null)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFA726),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(double top, double? left, double? right, double width, double height, IconData icon, Color color) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 3),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.8),
              color.withOpacity(0.6),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

// Custom painter for dotted connecting lines (same as before)
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw curved dotted lines connecting the profile images
    final path1 = Path();
    path1.moveTo(size.width * 0.3, 120);
    path1.quadraticBezierTo(
      size.width * 0.6,
      80,
      size.width * 0.8,
      160,
    );

    final path2 = Path();
    path2.moveTo(size.width * 0.25, 180);
    path2.quadraticBezierTo(
      size.width * 0.5,
      220,
      size.width * 0.75,
      240,
    );

    _drawDottedPath(canvas, path1, paint);
    _drawDottedPath(canvas, path2, paint);
  }

  void _drawDottedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final extractedPath = pathMetric.extractPath(distance, distance + 5);
        canvas.drawPath(extractedPath, paint);
        distance += 15;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}