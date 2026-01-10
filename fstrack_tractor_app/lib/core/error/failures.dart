abstract class Failure {
  String get message;
}

class ServerFailure extends Failure {
  @override
  final String message;
  ServerFailure(this.message);
}

class CacheFailure extends Failure {
  @override
  final String message;
  CacheFailure(this.message);
}

class NetworkFailure extends Failure {
  @override
  String get message => 'Tidak dapat terhubung ke server';
}

class AuthFailure extends Failure {
  @override
  final String message;
  AuthFailure(this.message);
}
