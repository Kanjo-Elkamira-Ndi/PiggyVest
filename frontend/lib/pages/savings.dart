import 'package:flutter/material.dart';

class SavingsScreen extends StatefulWidget {
  final double amount;
  const SavingsScreen({Key? key, required this.amount}) : super(key: key);

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  bool _showMoreWays = false;

  String _formatAmount(double amount) {
    // Format the amount with commas for thousands
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'Goals',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Motivational quote
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ECDC4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'What You Save Today Saves You Tomorrow.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4ECDC4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Total Balance Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'FCFA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatAmount(widget.amount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.visibility_off_outlined,
                          color: Colors.white.withOpacity(0.8),
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Go-To savings section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      'Go-To savings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE0B2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Popular',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF8F00),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text('🔥', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Savings options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSavingsCard(
                        icon: Icons.flag_outlined,
                        iconColor: const Color(0xFF6366F1),
                        iconBackground: const Color(0xFFF0F0FF),
                        title: 'Personal Goals',
                        subtitle: 'Plan and reach your own goal',
                        amount: 'FCFA 0',
                        onTap: () {
                          // Navigate to personal goals
                          Navigator.pushNamed(context, '/ongoingGoals');
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildSavingsCard(
                        icon: Icons.shopping_bag_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                        iconBackground: const Color(0xFFF5F3FF),
                        title: 'Topup',
                        subtitle: 'Topup your account for future use',
                        amount: 'FCFA 0',
                        onTap: () {
                          // Navigate to reserves
                          Navigator.pushNamed(context, '/reserves');
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),



              // Additional savings options (shown when expanded)
              if (_showMoreWays) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSavingsCard(
                              icon: Icons.groups_outlined,
                              iconColor: const Color(0xFF10B981),
                              iconBackground: const Color(0xFFECFDF5),
                              title: 'Group Savings',
                              subtitle: 'Save together with friends',
                              amount: 'FCFA 0',
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildSavingsCard(
                              icon: Icons.schedule_outlined,
                              iconColor: const Color(0xFFF59E0B),
                              iconBackground: const Color(0xFFFEF3C7),
                              title: 'Auto Save',
                              subtitle: 'Automated savings plan',
                              amount: 'FCFA 0',
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSavingsCard(
                              icon: Icons.trending_up_outlined,
                              iconColor: const Color(0xFFEF4444),
                              iconBackground: const Color(0xFFFEE2E2),
                              title: 'Investment',
                              subtitle: 'Grow your money wisely',
                              amount: 'FCFA 0',
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildSavingsCard(
                              icon: Icons.card_giftcard_outlined,
                              iconColor: const Color(0xFF8B5CF6),
                              iconBackground: const Color(0xFFF5F3FF),
                              title: 'Gift Savings',
                              subtitle: 'Save for special occasions',
                              amount: 'FCFA 0',
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required String amount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),

            const SizedBox(height: 15),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),

            const SizedBox(height: 15),

            // Amount
            Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}