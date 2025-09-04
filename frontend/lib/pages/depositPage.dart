import 'package:flutter/material.dart';
import 'package:piggyvest/apiCalls/userService.dart';

class TopUpScreen extends StatefulWidget {

  final Map<String, dynamic> goalData;

  TopUpScreen({required this.goalData});

  @override
  _TopUpScreenState createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print(widget.goalData); // Access your passed data here

    // Add listeners to update the button state when text changes
    _amountController.addListener(_updateButtonState);
    _phoneController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      // This will trigger a rebuild and update the button state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Top Up',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fund your flip account text
            Text(
              'Fund your flip account',
              style: TextStyle(
                color: Colors.teal,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 24),

            // Amount to top up
            Text(
              'Amount to top up',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.teal),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            SizedBox(height: 24),

            // Phone number section
            Text(
              'Phone number',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                // Country code container
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.green, Colors.red, Colors.yellow],
                            stops: [0.25, 0.50, .90],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '+237',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),

                // Phone number input
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Phone number',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),

            // Fee breakdown
            _buildFeeRow('Amount to top up', 'FCFA ${_amountController.text.isNotEmpty ? _amountController.text : '0'}'),
            SizedBox(height: 12),
            _buildFeeRow('Fees', 'FCFA ${_calculateFees()}'),
            SizedBox(height: 12),
            _buildFeeRow('You will be deducted', 'FCFA ${_calculateTotal()}'),
            SizedBox(height: 12),
            _buildFeeRow('Telecom Operator', '-'),
            SizedBox(height: 24),

            // Agreement checkbox
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'I understand and agree to the 2% fee for this top up. I am ready to proceed',
                      style: TextStyle(color: Colors.orange[800], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            Spacer(),

            // Top Up button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                _isFormValid()
                    ? () {
                  print("hello 1");
                  UserService.deposite(id: widget.goalData['id'], amount: double.parse(_amountController.text), number: int.parse(_phoneController.text));
                  // Handle top up action
                  _showTopUpDialog();
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  _isFormValid() ? Colors.teal : Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Top Up',
                  style: TextStyle(
                    color: _isFormValid() ? Colors.white : Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(
          amount,
          style: TextStyle(
            color: label == 'You will be deducted' ? Colors.black : Colors.teal,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _calculateFees() {
    if (_amountController.text.isEmpty) return '0';
    double amount = double.tryParse(_amountController.text) ?? 0;
    return (amount * 0.02).toStringAsFixed(0);
  }

  String _calculateTotal() {
    if (_amountController.text.isEmpty) return '0';
    double amount = double.tryParse(_amountController.text) ?? 0;
    double fees = amount * 0.02;
    return (amount + fees).toStringAsFixed(0);
  }

  bool _isFormValid() {
    return _amountController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        double.tryParse(_amountController.text) != null &&
        double.parse(_amountController.text) > 0;
  }

  void _showTopUpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Top Up'),
          content: Text(
            'Are you sure you want to top up FCFA ${_amountController.text} to ${_phoneController.text}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle the actual top up logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Top up initiated successfully!')),
                );
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    _amountController.removeListener(_updateButtonState);
    _phoneController.removeListener(_updateButtonState);
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}