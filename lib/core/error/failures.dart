import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Connection timed out.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized access.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Input validation failed.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred.']);
}
