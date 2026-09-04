import '../../core/utils/json_utils.dart';

class Customer {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? gender;
  final bool emailVerified;
  final bool phoneVerified;
  final bool acceptsMarketing;
  final bool hasPassword;
  final int ordersCount;
  final double totalSpent;
  final String? dateOfBirth;

  Customer({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.gender,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.acceptsMarketing = false,
    this.hasPassword = false,
    this.ordersCount = 0,
    this.totalSpent = 0,
    this.dateOfBirth,
  });

  String get displayName {
    final n = [firstName, lastName].where((e) => e != null && e.isNotEmpty).join(' ');
    return n.isEmpty ? (phone ?? email ?? 'Shopper') : n;
  }

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: asInt(j['id']),
        firstName: j['first_name'],
        lastName: j['last_name'],
        email: j['email'],
        phone: j['phone'],
        gender: j['gender'],
        emailVerified: asBool(j['email_verified'] ?? (j['email_verified_at'] != null)),
        phoneVerified: asBool(j['phone_verified'] ?? (j['phone_verified_at'] != null)),
        acceptsMarketing: asBool(j['accepts_marketing']),
        hasPassword: asBool(j['has_password'], true),
        ordersCount: asInt(j['orders_count']),
        totalSpent: asDouble(j['total_spent']),
        dateOfBirth: j['date_of_birth'],
      );
}

class AuthDevice {
  final String tokenId;
  final String? deviceName;
  final DateTime? lastUsedAt;
  final bool isCurrent;

  AuthDevice({required this.tokenId, this.deviceName, this.lastUsedAt, this.isCurrent = false});

  factory AuthDevice.fromJson(Map<String, dynamic> j) => AuthDevice(
        tokenId: asString(j['id'] ?? j['token']),
        deviceName: j['device_name'] ?? j['name'],
        lastUsedAt: j['last_used_at'] == null ? null : DateTime.tryParse(j['last_used_at']),
        isCurrent: asBool(j['is_current']),
      );
}
