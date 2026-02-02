import '../../domain/entities/operator_entity.dart';

/// Data model for operator
///
/// Handles JSON serialization/deserialization.
/// Note: operator_id is INTEGER in production schema (not UUID).
class OperatorModel {
  final int id;
  final String name;
  final bool isActive;

  const OperatorModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  /// Create from JSON (API response)
  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    return OperatorModel(
      id: json['id'] as int,
      name: json['name'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
    };
  }

  /// Convert to domain entity
  OperatorEntity toEntity() {
    return OperatorEntity(
      id: id,
      name: name,
      isActive: isActive,
    );
  }

  /// Create from domain entity
  factory OperatorModel.fromEntity(OperatorEntity entity) {
    return OperatorModel(
      id: entity.id,
      name: entity.name,
      isActive: entity.isActive,
    );
  }

  /// Create a copy with modified fields
  OperatorModel copyWith({
    int? id,
    String? name,
    bool? isActive,
  }) {
    return OperatorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }
}
