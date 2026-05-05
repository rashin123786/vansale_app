import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/customer_bloc.dart';
import '../widgets/customer_tile_widget.dart';

/// Full customer list (Dashboard → Customers)
class CustomerListPage extends StatelessWidget {
  final UserEntity user;
  const CustomerListPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<CustomerBloc>()
            ..add(LoadCustomers(routeId: user.routeId, storeId: user.storeId)),
      child: const _CustomerListView(selectable: false),
    );
  }
}

/// Selectable customer picker (used from Create Invoice)
class SelectCustomerPage extends StatelessWidget {
  final UserEntity user;
  const SelectCustomerPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<CustomerBloc>()
            ..add(LoadCustomers(routeId: user.routeId, storeId: user.storeId)),
      child: const _CustomerListView(selectable: true),
    );
  }
}

class _CustomerListView extends StatefulWidget {
  final bool selectable;
  const _CustomerListView({required this.selectable});

  @override
  State<_CustomerListView> createState() => _CustomerListViewState();
}

class _CustomerListViewState extends State<_CustomerListView> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectable ? 'Select Customer' : 'Customers'),
      ),
      body: Column(
        children: [
          // ── Search bar ────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (q) =>
                  context.read<CustomerBloc>().add(SearchCustomers(q)),
              decoration: InputDecoration(
                hintText: 'Search by name, phone...',
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
                          context.read<CustomerBloc>().add(SearchCustomers(''));
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ── List ──────────────────────────────
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CustomerError) {
                  return AppErrorWidget(
                    message: state.message,
                    isNetworkError: state.isNetwork,
                    onRetry: () {
                      // Retry needs original args — stored in bloc first event
                      context.read<CustomerBloc>().add(
                        LoadCustomers(routeId: '84', storeId: '112'),
                      );
                    },
                  );
                }
                if (state is CustomerLoaded) {
                  if (state.filtered.isEmpty) {
                    return const AppEmptyWidget(
                      message: 'No customers found',
                      icon: Icons.people_outline,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final c = state.filtered[i];
                      return CustomerTile(
                        customer: c,
                        selectable: widget.selectable,
                        onTap: () {
                          if (widget.selectable) Navigator.pop(ctx, c);
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
