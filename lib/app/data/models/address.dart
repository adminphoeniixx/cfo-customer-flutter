import '../../core/utils/json_utils.dart';

class Address {
  final int id;
  final String? label;
  final String firstName;
  final String? lastName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postcode;
  final String? country;
  final bool isDefaultShipping;
  final bool isDefaultBilling;

  bool get isDefault => isDefaultShipping;

  Address({
    required this.id,
    this.label,
    required this.firstName,
    this.lastName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postcode,
    this.country,
    this.isDefaultShipping = false,
    this.isDefaultBilling = false,
  });

  String get fullName => [firstName, lastName].where((e) => e != null && e.isNotEmpty).join(' ');

  String get singleLine =>
      [addressLine1, addressLine2, city, state, postcode].where((e) => e != null && e.isNotEmpty).join(', ');

  factory Address.fromJson(Map<String, dynamic> j) => Address(
        id: asInt(j['id']),
        label: j['label'],
        firstName: asString(j['first_name']),
        lastName: j['last_name'],
        phone: asString(j['phone']),
        addressLine1: asString(j['address_line1']),
        addressLine2: j['address_line2'],
        city: asString(j['city']),
        state: asString(j['state']),
        postcode: asString(j['postcode']),
        country: j['country'],
        isDefaultShipping: asBool(j['is_default_shipping'] ?? j['is_default']),
        isDefaultBilling: asBool(j['is_default_billing'] ?? j['is_default']),
      );

  Map<String, dynamic> toJson() => {
        if (label != null) 'label': label,
        'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        'phone': phone,
        'address_line1': addressLine1,
        if (addressLine2 != null) 'address_line2': addressLine2,
        'city': city,
        'state': state,
        'postcode': postcode,
        if (country != null) 'country': country,
      };
}
