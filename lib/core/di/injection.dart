import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/customers/data/repositories/customer_repository.dart';
import '../../features/customers/presentation/bloc/customer_bloc.dart';
import '../../features/invoices/data/repositories/invoice_repository.dart';
import '../../features/invoices/presentation/bloc/invoice_bloc.dart';
import '../../features/products/data/repositories/product_repository.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';
import '../network/app_storage.dart';
import '../network/dio_client.dart';
import '../network/connectivity_service.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  // ── External ──────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // ── Core ──────────────────────────────────
  sl.registerLazySingleton<AppStorage>(() => AppStorage(sl()));
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));

  // ── Repositories ──────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepository(sl(), sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepository(sl(), sl()),
  );
  sl.registerLazySingleton<InvoiceRepository>(
    () => InvoiceRepository(sl(), sl()),
  );

  // ── BLoCs (factory = new instance per page) ──
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
  sl.registerFactory<CustomerBloc>(() => CustomerBloc(sl()));
  sl.registerFactory<ProductBloc>(() => ProductBloc(sl()));
  sl.registerFactory<InvoiceBloc>(() => InvoiceBloc(sl()));
  sl.registerFactory<InvoiceListBloc>(() => InvoiceListBloc(sl()));
}
