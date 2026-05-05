// ─────────────────────────────────────────────
//  features/invoice/presentation/pages/invoice_list_page.dart
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/invoice_bloc.dart';

class InvoiceListPage extends StatelessWidget {
  final UserEntity user;
  const InvoiceListPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InvoiceListBloc>()
        ..add(
          LoadInvoiceList(
            userId: user.userId,
            storeId: user.storeId,
            vanId: user.vanId,
          ),
        ),
      child: _InvoiceListView(user: user),
    );
  }
}

class _InvoiceListView extends StatelessWidget {
  final UserEntity user;
  const _InvoiceListView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<InvoiceListBloc>().add(
              LoadInvoiceList(
                userId: user.userId,
                storeId: user.storeId,
                vanId: user.vanId,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<InvoiceListBloc, InvoiceListState>(
        builder: (context, state) {
          if (state is InvoiceListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is InvoiceListError) {
            return AppErrorWidget(
              message: state.message,
              isNetworkError: state.isNetwork,
              onRetry: () => context.read<InvoiceListBloc>().add(
                LoadInvoiceList(
                  userId: user.userId,
                  storeId: user.storeId,
                  vanId: user.vanId,
                ),
              ),
            );
          }
          if (state is InvoiceListLoaded) {
            if (state.sales.isEmpty) {
              return const AppEmptyWidget(
                message: 'No invoices found',
                icon: Icons.receipt_long_outlined,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.sales.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final sale = state.sales[i];
                final date = _formatDate(sale.date);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Invoice icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.receipt_outlined,
                            color: AppTheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sale.invoiceNo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sale.customerName,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              if (date.isNotEmpty)
                                Text(
                                  date,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Amount + Status
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${sale.grandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _StatusBadge(sale.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw.replaceFirst(' ', 'T'));
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        status.toLowerCase().contains('complet') ||
        status.toLowerCase().contains('paid');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isCompleted ? AppTheme.success : AppTheme.warning).withOpacity(
          0.1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isCompleted ? AppTheme.success : AppTheme.warning,
        ),
      ),
    );
  }
}
