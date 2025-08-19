import 'package:flutter/material.dart';

class PinEntryScreen extends StatefulWidget {
  @override
  _PinEntryScreenState createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  String _pin = '';
  final int _pinLength = 4;

  void _onNumberPressed(String number) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += number;
      });
    }
  }

  void _onBackspacePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _onClosePressed() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Enter your pin',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _onClosePressed,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 20, color: Colors.black),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 60),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          index < _pin.length
                              ? Colors.grey[600]
                              : Colors.grey[300],
                    ),
                  );
                }),
              ),

              SizedBox(height: 80),

              // Number pad
              Expanded(
                child: Column(
                  children: [
                    // Row 1: 1, 2, 3
                    _buildNumberRow(['1', '2', '3']),
                    SizedBox(height: 40),

                    // Row 2: 4, 5, 6
                    _buildNumberRow(['4', '5', '6']),
                    SizedBox(height: 40),

                    // Row 3: 7, 8, 9
                    _buildNumberRow(['7', '8', '9']),
                    SizedBox(height: 40),

                    // Row 4: 0, backspace
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(child: Container()), // Empty space
                        Expanded(child: _buildNumberButton('0')),
                        Expanded(
                          child: Center(
                            child: GestureDetector(
                              onTap: _onBackspacePressed,
                              child: Container(
                                padding: EdgeInsets.all(16),
                                child: Icon(
                                  Icons.backspace_outlined,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Forgot pin link
              GestureDetector(
                onTap: () {
                  // Handle forgot pin
                },
                child: Text(
                  'Forgot pin?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4ECDC4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          numbers.map((number) {
            return Expanded(child: _buildNumberButton(number));
          }).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return Center(
      child: GestureDetector(
        onTap: () => _onNumberPressed(number),
        child: Container(
          width: 60,
          height: 60,
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
