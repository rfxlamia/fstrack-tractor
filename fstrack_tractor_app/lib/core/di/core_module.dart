import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

import '../storage/hive_service.dart';

/// Core module for dependency injection registration
@module
abstract class CoreModule {
  @lazySingleton
  HiveService get hiveService => HiveService();

  /// Register Connectivity from connectivity_plus package
  @lazySingleton
  Connectivity get connectivity => Connectivity();
}
