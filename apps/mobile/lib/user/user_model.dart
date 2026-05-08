import 'user_role.dart';
import 'user_status.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.status,
    this.email,
    this.phoneNumber,
    this.facilityId,
    this.organizationId,
    this.patientId,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final UserRole role;
  final UserStatus status;
  final String? facilityId;
  final String? organizationId;
  final String? patientId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  String get fullName => '$firstName $lastName';

  bool get isActive => status == UserStatus.active;

  bool get isPatient => role == UserRole.patient;

  bool get isHealthcareWorker {
    return role == UserRole.doctor ||
        role == UserRole.nurse ||
        role == UserRole.laboratoryTechnician ||
        role == UserRole.pharmacist;
  }

  bool get isAdministrative {
    return role == UserRole.admin ||
        role == UserRole.facilityAdmin ||
        role == UserRole.registrationAgent ||
        role == UserRole.verifier;
  }

  bool get isReadOnly {
    return role == UserRole.auditor ||
        role == UserRole.publicHealthOfficer ||
        role == UserRole.dataAnalyst;
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    UserRole? role,
    UserStatus? status,
    String? facilityId,
    String? organizationId,
    String? patientId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      status: status ?? this.status,
      facilityId: facilityId ?? this.facilityId,
      organizationId: organizationId ?? this.organizationId,
      patientId: patientId ?? this.patientId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      role: UserRole.fromValue(json['role'] as String),
      status: UserStatus.fromValue(json['status'] as String),
      facilityId: json['facility_id'] as String?,
      organizationId: json['organization_id'] as String?,
      patientId: json['patient_id'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      lastLoginAt: _parseDateTime(json['last_login_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'role': role.value,
      'status': status.value,
      'facility_id': facilityId,
      'organization_id': organizationId,
      'patient_id': patientId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.parse(value as String);
  }
}
