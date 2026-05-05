import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/app_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../widgets/welcome_card_widget.dart';

class DashboardPage extends StatelessWidget {
  final UserEntity user;
  const DashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              final storage = sl<AppStorage>();
              await storage.clear();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User Welcome Card ────────────────────
            WelcomeCard(user: user),
            const SizedBox(height: 24),

            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // ── Grid ────────────────────────────────
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                DashCard(
                  icon: Icons.people_alt_outlined,
                  label: 'Customers',
                  count: 'View all',
                  color: const Color(0xFF6366F1),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/customers',
                    arguments: user,
                  ),
                ),
                DashCard(
                  icon: Icons.inventory_2_outlined,
                  label: 'Products',
                  count: 'Browse',
                  color: const Color(0xFFF59E0B),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/products',
                    arguments: user,
                  ),
                ),
                DashCard(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Create Invoice',
                  count: 'New sale',
                  color: AppTheme.success,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/create-invoice',
                    arguments: user,
                  ),
                ),
                DashCard(
                  icon: Icons.receipt_long_outlined,
                  label: 'Invoice List',
                  count: 'History',
                  color: AppTheme.primary,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/invoices',
                    arguments: user,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
