import 'package:flutter/material.dart';
import 'package:vansale_app/core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'features/auth/domain/entities/user_entity.dart';
import 'features/auth/presentation/screens/login_page.dart';
import 'features/customers/presentation/screens/customer_list_page.dart';
import 'features/dashboard/presentation/screens/dashboard_page.dart';
import 'features/invoices/presentation/screens/create_invoice_page.dart';
import 'features/invoices/presentation/screens/invoice_list_page.dart';
import 'features/products/presentation/screens/product_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDI();
  runApp(const VanSaleApp());
}

class VanSaleApp extends StatelessWidget {
  const VanSaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Van Sale',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        // Extract UserEntity from route arguments where needed
        final user = settings.arguments as UserEntity?;

        switch (settings.name) {
          case '/login':
            return _fade(const LoginPage());

          case '/dashboard':
            if (user == null) return _redirect('/login');
            return _fade(DashboardPage(user: user));

          case '/customers':
            if (user == null) return _redirect('/login');
            return _slide(CustomerListPage(user: user));

          case '/products':
            if (user == null) return _redirect('/login');
            return _slide(ProductListPage(user: user));

          case '/create-invoice':
            if (user == null) return _redirect('/login');
            return _slide(CreateInvoicePage(user: user));

          case '/invoices':
            if (user == null) return _redirect('/login');
            return _slide(InvoiceListPage(user: user));

          default:
            return _fade(const LoginPage());
        }
      },
    );
  }

  Route _fade(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 200),
  );

  Route _slide(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 250),
  );

  Route _redirect(String route) =>
      MaterialPageRoute(builder: (_) => const LoginPage());
}
