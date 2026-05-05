import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_card_widget.dart';

class SelectedProductUnit {
  final ProductEntity product;
  final ProductUnitEntity unit;
  const SelectedProductUnit({required this.product, required this.unit});
}

/// Browse-only product list (from Dashboard)
class ProductListPage extends StatelessWidget {
  final UserEntity user;
  const ProductListPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductBloc>()..add(LoadProducts(user.storeId)),
      child: const _ProductListView(selectable: false),
    );
  }
}

/// Selectable product picker (from Create Invoice)
/// Returns [SelectedProductUnit] on pop
class SelectProductPage extends StatelessWidget {
  final UserEntity user;
  const SelectProductPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductBloc>()..add(LoadProducts(user.storeId)),
      child: const _ProductListView(selectable: true),
    );
  }
}

// ─────────────────────────────────────────────

class _ProductListView extends StatefulWidget {
  final bool selectable;
  const _ProductListView({required this.selectable});

  @override
  State<_ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<_ProductListView> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(widget.selectable ? 'Select Product' : 'Products'),
      ),
      body: Column(
        children: [
          // ── Search bar ────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: StatefulBuilder(
              builder: (ctx, setInner) => TextField(
                controller: _searchCtrl,
                onChanged: (q) {
                  setInner(() {});
                  context.read<ProductBloc>().add(SearchProducts(q));
                },
                decoration: InputDecoration(
                  hintText: 'Search by name or code…',
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setInner(() {});
                            context.read<ProductBloc>().add(SearchProducts(''));
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // ── List ──────────────────────────────
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ProductError) {
                  return AppErrorWidget(
                    message: state.message,
                    isNetworkError: state.isNetwork,
                    onRetry: () =>
                        context.read<ProductBloc>().add(LoadProducts('112')),
                  );
                }
                if (state is ProductLoaded) {
                  if (state.filtered.isEmpty) {
                    return const AppEmptyWidget(
                      message: 'No products found',
                      icon: Icons.inventory_2_outlined,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final product = state.filtered[i];

                      return ProductCard(
                        product: product,
                        selectable: widget.selectable,
                        onUnitSelected: (unit) {
                          print("prdocut----${product.id}");
                          Navigator.pop(
                            ctx,
                            SelectedProductUnit(product: product, unit: unit),
                          );
                        },
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
