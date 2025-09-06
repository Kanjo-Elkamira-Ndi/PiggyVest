import 'package:flutter/material.dart';
import 'package:piggyvest/apiCalls/userService.dart';

class PersonalGoalsScreen extends StatefulWidget {
  const PersonalGoalsScreen({Key? key}) : super(key: key);

  @override
  State<PersonalGoalsScreen> createState() => _PersonalGoalsScreenState();
}

class _PersonalGoalsScreenState extends State<PersonalGoalsScreen> {
  List<Map<String, dynamic>>? userTargets;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserTarget();
  }

  void _fetchUserTarget() async {
    try {
      print('Loading user goals');
      final data = await UserService.getTarget();
      setState(() {
        userTargets = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        userTargets = [];
      });
      print('Error fetching user goals: $e');
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return 'FCFA 0';
    final numAmount = double.tryParse(amount.toString()) ?? 0.0;
    return 'FCFA ${numAmount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )}';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No deadline';
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  double _calculateProgress(dynamic currentAmount, dynamic objective) {
    if (currentAmount == null || objective == null) return 0.0;
    try {
      final current = double.parse(currentAmount.toString());
      final target = double.parse(objective.toString());
      if (target == 0) return 0.0;
      final progress = current / target;
      print(progress);
      return progress > 1.0 ? 1.0 : progress;
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4ECDC4),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button and Home
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[100],
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/dashboard');
                          },
                          child: const Text(
                            'Home',
                            style: TextStyle(
                              color: Color(0xFF4ECDC4),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Personal Goals Title
                    const Text(
                      'Personal Goals',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Discipline subtitle with target icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4ECDC4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.track_changes,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Discipline is the new trend with Goals',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4ECDC4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Tab Navigation
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTabButton(
                            'Ongoing Goals',
                            Icons.bar_chart,
                            true,
                            const Color(0xFF4ECDC4),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/completedGoals');
                            },
                            child: _buildTabButton(
                              'Completed Goals',
                              Icons.check,
                              false,
                              Colors.grey[600]!,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // My Goals section
                    const Text(
                      'My Goals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Goals list
                    Expanded(
                      child: userTargets == null || userTargets!.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                        itemCount: userTargets!.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final goal = userTargets![index];
                          return _buildGoalCard(
                            goal['id'] ?? 0,
                            goal['name'] ?? 'Unnamed Goal',
                            _formatAmount(goal['objective']),
                            _formatDate(goal['deadline']),
                            _calculateProgress(goal['current_amount'], goal['objective']),
                            goal,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/createGoal');
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFF4ECDC4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No goals yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first goal to start saving!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/createGoal');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Create Goal'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
      String text,
      IconData icon,
      bool isActive,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4ECDC4).withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
      int id,
      String title,
      String amount,
      String duration,
      double progress,
      Map<String, dynamic> goalData,
      ) {
    return GestureDetector(
      onTap: () {
        // Check if goal is completed (100% progress)
        if (progress >= 1.0) {
          // Navigate to completed goal screen
          Navigator.pushNamed(
            context,
            '/completedGoals',
            arguments: goalData,
          );
        } else {
          // Navigate to normal deposit page for ongoing goals
          Navigator.pushNamed(
            context,
            '/depositPage',
            arguments: goalData,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: progress >= 1.0
              ? const Color(0xFFE8F5E8) // Light green background for completed goals
              : const Color(0xFFF5F4F9),
          borderRadius: BorderRadius.circular(12),
          border: progress >= 1.0
              ? Border.all(color: const Color(0xFF4ECDC4), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      progress >= 1.0 ? Icons.check_circle : Icons.flag,
                      size: 24,
                      color: const Color(0xFF4ECDC4),
                    ),
                  ),
                  if (progress < 1.0) ...[
                    Positioned(
                      top: 6,
                      right: 8,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ECDC4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.eco, size: 8, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 20,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ECDC4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.eco, size: 6, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Goal details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (progress >= 1.0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ECDC4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'COMPLETED',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Target Amount',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4ECDC4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Deadline',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    duration,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Progress indicator
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0
                            ? const Color(0xFF4ECDC4)
                            : const Color(0xFF4ECDC4),
                      ),
                    ),
                  ),
                  Center(
                    child: progress >= 1.0
                        ? const Icon(
                      Icons.check,
                      color: Color(0xFF4ECDC4),
                      size: 16,
                    )
                        : Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}