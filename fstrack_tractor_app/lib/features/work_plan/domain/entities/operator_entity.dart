import 'package:equatable/equatable.dart';

/// Entity representing an operator in the domain layer
///
/// Maps to the production database schema:
/// - operators.id: INTEGER (NOT UUID!)
/// - operators.name: String
/// - operators.is_active: boolean
class OperatorEntity extends Equatable {
  final int id;
  final String name;
  final bool isActive;

  const OperatorEntity({
    required this.id,
    required this.name,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, isActive];
}
