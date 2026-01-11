import 'package:injectable/injectable.dart';

import '../storage/hive_service.dart';

/// Core module for dependency injection registration
@module
abstract class CoreModule {
  @lazySingleton
  HiveService get hiveService => HiveService();
}
