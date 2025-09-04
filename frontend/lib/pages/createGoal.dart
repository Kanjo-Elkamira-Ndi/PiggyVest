import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piggyvest/apiCalls/userService.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({Key? key}) : super(key: key);

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _goalTitleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _finePercentageController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedCategory;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Health and Hospital Bills',
      'icon': Icons.local_hospital,
      'color': Color(0xFFE57373),
    },
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Color(0xFFFFB74D)},
    {
      'name': 'Clothing/Fashion',
      'icon': Icons.checkroom,
      'color': Color(0xFFBA68C8),
    },
    {
      'name': 'Electronic/Smart Devices',
      'icon': Icons.smartphone,
      'color': Color(0xFF64B5F6),
    },
    {
      'name': 'Transportation',
      'icon': Icons.directions_car,
      'color': Color(0xFF81C784),
    },
    {
      'name': 'Investment',
      'icon': Icons.trending_up,
      'color': Color(0xFFFFD54F),
    },
    {'name': 'Rents', 'icon': Icons.home, 'color': Color(0xFFFF8A65)},
    {'name': 'Fees', 'icon': Icons.school, 'color': Color(0xFF9575CD)},
  ];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4ECDC4),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['name'];
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: category['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _selectedCategory == category['name']
                              ? const Color(0xFF4ECDC4)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'],
                            size: 40,
                            color: category['color'],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _goalTitleController.dispose();
    _targetAmountController.dispose();
    _finePercentageController.dispose();
    super.dispose();
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
            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Create Goal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 36), // Balance the back button
                  ],
                ),
              ),

              // Form content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(25),
                      children: [
                        const SizedBox(height: 10),

                        // Goal Title
                        _buildInputField(
                          label: 'Goal Title',
                          controller: _goalTitleController,
                          hint: 'e.g., New iPhone, Vacation Trip',
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a goal title';
                            }
                            if (value!.length < 3) {
                              return 'Goal title must be at least 3 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Goal Target Amount
                        _buildInputField(
                          label: 'Target Amount',
                          controller: _targetAmountController,
                          hint: '0',
                          keyboardType: TextInputType.number,
                          prefixText: 'FCFA ',
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          ],
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter target amount';
                            }
                            final amount = double.tryParse(value!);
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
                            }
                            if (amount < 1000) {
                              return 'Minimum target amount is FCFA 1,000';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Withdraw Date
                        GestureDetector(
                          onTap: _selectDate,
                          child: _buildDisplayField(
                            label: 'Withdraw Date',
                            value: _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Select date',
                            icon: Icons.calendar_today,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Breaking Plan Fine (Percentage)
                        _buildInputField(
                          label: 'Breaking Plan Fine (%)',
                          controller: _finePercentageController,
                          hint: '2',
                          keyboardType: TextInputType.number,
                          suffixText: '%',
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          ],
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter fine percentage';
                            }
                            final percentage = double.tryParse(value!);
                            if (percentage == null) {
                              return 'Please enter a valid percentage';
                            }
                            if (percentage < 2) {
                              return 'Minimum fine is 2%';
                            }
                            if (percentage > 50) {
                              return 'Maximum fine is 50%';
                            }
                            return null;
                          },
                        ),

                        // Fine amount display
                        if (_targetAmountController.text.isNotEmpty &&
                            _finePercentageController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Builder(
                              builder: (context) {
                                final target = double.tryParse(_targetAmountController.text) ?? 0;
                                final percentage = double.tryParse(_finePercentageController.text) ?? 0;
                                final fineAmount = (target * percentage / 100);
                                return Text(
                                  'Fine amount: FCFA ${fineAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Savings Category
                        GestureDetector(
                          onTap: _showCategoryPicker,
                          child: _buildDisplayField(
                            label: 'Savings Category',
                            value: _selectedCategory ?? 'Select category',
                            icon: _selectedCategory != null
                                ? _categories.firstWhere(
                                  (cat) => cat['name'] == _selectedCategory,
                            )['icon']
                                : Icons.category,
                            iconColor: _selectedCategory != null
                                ? _categories.firstWhere(
                                  (cat) => cat['name'] == _selectedCategory,
                            )['color']
                                : Colors.grey[400],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Create Goal Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleCreateGoal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4ECDC4),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Text(
                              'Create Goal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? prefixText,
    String? suffixText,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            suffixText: suffixText,
            prefixStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            suffixStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayField({
    required String label,
    required String value,
    required IconData icon,
    Color? iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? Colors.grey[400], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: value.contains('Select')
                        ? Colors.grey[500]
                        : Colors.grey[800],
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
            ],
          ),
        ),
      ],
    );
  }

  void _handleCreateGoal() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null) {
        _showErrorSnackBar('Please select a withdraw date');
        return;
      }
      if (_selectedCategory == null) {
        _showErrorSnackBar('Please select a category');
        return;
      }
      _createGoal();
    }
  }

  void _createGoal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final targetAmount = double.parse(_targetAmountController.text);
      final finePercentage = double.parse(_finePercentageController.text);

      // Calculate fine amount just for display/logging purposes
      final fineAmount = (targetAmount * finePercentage / 100);

      print({
        'name': _goalTitleController.text.trim(),
        'objective': targetAmount,
        'deadline': _selectedDate,
        'fine_percentage': finePercentage, // Log percentage
        'fine_amount_display': fineAmount, // Log calculated amount for reference
        'category': _selectedCategory
      });

      // Pass the percentage to the API, not the calculated amount
      final result = await UserService.createTarget(
        name: _goalTitleController.text.trim(),
        objective: targetAmount,
        deadline: _selectedDate!,
        finePercentage: finePercentage, // Pass percentage
        category: _selectedCategory!,
      );

      if (result['success'] == true) {
        _showSuccessSnackBar(result['message'] ?? 'Goal created successfully!');
        Navigator.pop(context, true);
      } else {
        _showErrorSnackBar(result['message'] ?? 'Failed to create goal');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}