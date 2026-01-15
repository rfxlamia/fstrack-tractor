import 'package:injectable/injectable.dart';
import '../../../../core/storage/hive_service.dart';

abstract class SessionWarningStorage {
  Future<DateTime?> getLastWarningShownAt();
  Future<void> setLastWarningShownAt(DateTime timestamp);
  Future<void> clearWarningTimestamp();
}

@LazySingleton(as: SessionWarningStorage)
class SessionWarningStorageImpl implements SessionWarningStorage {
  final HiveService _hiveService;
  static const String _lastWarningShownKey = 'lastWarningShownAt';

  SessionWarningStorageImpl(this._hiveService);

  @override
  Future<DateTime?> getLastWarningShownAt() async {
    final timestamp = _hiveService.authBox.get(_lastWarningShownKey) as String?;
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  @override
  Future<void> setLastWarningShownAt(DateTime timestamp) async {
    await _hiveService.authBox
        .put(_lastWarningShownKey, timestamp.toIso8601String());
  }

  @override
  Future<void> clearWarningTimestamp() async {
    await _hiveService.authBox.delete(_lastWarningShownKey);
  }
}
