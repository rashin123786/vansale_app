import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../customers/presentation/screens/customer_list_page.dart';
import '../../../products/presentation/screens/product_list_page.dart';
import '../bloc/invoice_bloc.dart';
import '../widgets/create_invoice_widget.dart';
import '../widgets/custom_card_widget.dart';

class CreateInvoicePage extends StatelessWidget {
  final UserEntity user;
  const CreateInvoicePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InvoiceBloc>(),
      child: _CreateInvoiceView(user: user),
    );
  }
}

class _CreateInvoiceView extends StatefulWidget {
  final UserEntity user;
  const _CreateInvoiceView({required this.user});

  @override
  State<_CreateInvoiceView> createState() => _CreateInvoiceViewState();
}

class _CreateInvoiceViewState extends State<_CreateInvoiceView> {
  final _discountCtrl = TextEditingController(text: '0');
  final _remarksCtrl = TextEditingController();

  @override
  void dispose() {
    _discountCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvoiceBloc, InvoiceState>(
      listener: (context, state) {
        if (state.status == InvoiceStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Invoice created successfully!'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Reset after success
          context.read<InvoiceBloc>().add(ClearInvoice());
          _discountCtrl.text = '0';
          _remarksCtrl.clear();
        } else if (state.status == InvoiceStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    state.isNetwork ? Icons.wifi_off : Icons.error_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.errorMessage!)),
                ],
              ),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == InvoiceStatus.submitting;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Create Invoice'),
            actions: [
              if (state.items.isNotEmpty || state.customer != null)
                TextButton.icon(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.error,
                    size: 18,
                  ),
                  label: const Text(
                    'Clear',
                    style: TextStyle(color: AppTheme.error),
                  ),
                  onPressed: () {
                    context.read<InvoiceBloc>().add(ClearInvoice());
                    _discountCtrl.text = '0';
                    _remarksCtrl.clear();
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Customer Section ──────────────
                _SectionHeader(
                  title: 'Customer',
                  action: TextButton.icon(
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: Text(state.customer == null ? 'Select' : 'Change'),
                    onPressed: () => _pickCustomer(context),
                  ),
                ),
                const SizedBox(height: 8),
                state.customer == null
                    ? _EmptySelector(
                        icon: Icons.people_outline,
                        label: 'No customer selected',
                        buttonLabel: 'Select Customer',
                        onTap: () => _pickCustomer(context),
                      )
                    : CustomerCard(customer: state.customer!),

                const SizedBox(height: 20),

                // ── 2. Products Section ──────────────
                _SectionHeader(
                  title: 'Products  (${state.totalItems} items)',
                  action: TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                    onPressed: () => _pickProduct(context),
                  ),
                ),
                const SizedBox(height: 8),
                state.items.isEmpty
                    ? _EmptySelector(
                        icon: Icons.inventory_2_outlined,
                        label: 'No products added',
                        buttonLabel: 'Add Product',
                        onTap: () => _pickProduct(context),
                      )
                    : Column(
                        children: state.items
                            .map(
                              (item) => CartItemTile(
                                item: item,
                                onIncrement: () =>
                                    context.read<InvoiceBloc>().add(
                                      IncrementQty(item.product.id.toString()),
                                    ),
                                onDecrement: () =>
                                    context.read<InvoiceBloc>().add(
                                      DecrementQty(item.product.id.toString()),
                                    ),
                                onRemove: () => context.read<InvoiceBloc>().add(
                                  RemoveProduct(item.product.id.toString()),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                const SizedBox(height: 20),

                // ── 3. Discount & Remarks ────────────
                if (state.items.isNotEmpty) ...[
                  _SectionHeader(title: 'Extra Details'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _discountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Discount',
                            prefixIcon: Icon(Icons.discount_outlined, size: 18),
                            prefixText: '₹ ',
                          ),
                          onChanged: (v) => context.read<InvoiceBloc>().add(
                            UpdateDiscount(double.tryParse(v) ?? 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _remarksCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Remarks (optional)',
                      hintText: 'Add notes about this sale...',
                      prefixIcon: Icon(Icons.note_outlined, size: 18),
                    ),
                    onChanged: (v) =>
                        context.read<InvoiceBloc>().add(UpdateRemarks(v)),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── 4. Summary ───────────────────────
                if (state.items.isNotEmpty) ...[
                  InvoiceSummary(state: state),
                  const SizedBox(height: 16),

                  // ── Submit Button ──────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (isSubmitting ||
                              state.customer == null ||
                              state.items.isEmpty)
                          ? null
                          : () {
                              context.read<InvoiceBloc>().add(
                                SubmitInvoice(
                                  userId: widget.user.userId,
                                  storeId: widget.user.storeId,
                                  vanId: widget.user.vanId,
                                ),
                              );
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Create Invoice'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickCustomer(BuildContext context) async {
    final customer = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SelectCustomerPage(user: widget.user)),
    );
    if (customer != null && context.mounted) {
      context.read<InvoiceBloc>().add(SelectCustomer(customer));
    }
  }

  Future<void> _pickProduct(BuildContext context) async {
    final product = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SelectProductPage(user: widget.user)),
    );
    if (product != null && context.mounted) {
      final selected = product as SelectedProductUnit;

      context.read<InvoiceBloc>().add(AddProduct(selected.product));
    }
  }
}

// ── Sub-widgets ──────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }
}

class _EmptySelector extends StatelessWidget {
  final IconData icon;
  final String label;
  final String buttonLabel;
  final VoidCallback onTap;

  const _EmptySelector({
    required this.icon,
    required this.label,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppTheme.primary.withOpacity(0.4)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onTap, child: Text(buttonLabel)),
        ],
      ),
    );
  }
}
