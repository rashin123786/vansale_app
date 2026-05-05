import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/invoice_bloc.dart';

class CartItemTile extends StatelessWidget {
  final item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '₹${item.product.basePrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Qty controls
          Row(
            children: [
              _QtyBtn(Icons.remove, onDecrement, item.quantity <= 1),
              Container(
                width: 32,
                alignment: Alignment.center,
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              _QtyBtn(Icons.add, onIncrement, false),
            ],
          ),

          const SizedBox(width: 8),

          // Subtotal + remove
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${item.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppTheme.primary,
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close, size: 16, color: AppTheme.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool disabled;

  const _QtyBtn(this.icon, this.onTap, this.disabled);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: disabled
              ? Colors.grey.shade100
              : AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: disabled ? Colors.grey : AppTheme.primary,
        ),
      ),
    );
  }
}

class InvoiceSummary extends StatelessWidget {
  final InvoiceState state;
  const InvoiceSummary({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _Row('Subtotal', '₹${state.subtotal.toStringAsFixed(2)}'),
          _Row('VAT (5%)', '₹${state.taxAmount.toStringAsFixed(2)}'),
          if (state.discount > 0)
            _Row(
              'Discount',
              '-₹${state.discount.toStringAsFixed(2)}',
              color: AppTheme.success,
            ),
          const Divider(height: 20),
          _Row(
            'Grand Total',
            '₹${state.grandTotal.toStringAsFixed(2)}',
            bold: true,
            color: AppTheme.primary,
            large: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;
  final bool large;

  const _Row(
    this.label,
    this.value, {
    this.bold = false,
    this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
      fontSize: large ? 16 : 14,
      color: color ?? AppTheme.textPrimary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style.copyWith(color: AppTheme.textSecondary)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
