import '../../core/utils/json_utils.dart';

class AccountSummary {
  final int ordersCount;
  final double ordersSpent;
  final int wishlistCount;
  final int couponCount;
  final int reviewsWrittenCount;
  final int reviewsPendingCount;
  final int addressesCount;
  final int devicesCount;
  final int requestsCount;

  AccountSummary({
    required this.ordersCount,
    required this.ordersSpent,
    required this.wishlistCount,
    required this.couponCount,
    required this.reviewsWrittenCount,
    required this.reviewsPendingCount,
    required this.addressesCount,
    required this.devicesCount,
    required this.requestsCount,
  });

  factory AccountSummary.fromJson(Map<String, dynamic> j) => AccountSummary(
        ordersCount: asInt(j['orders_count']),
        ordersSpent: asDouble(j['orders_spent']),
        wishlistCount: asInt(j['wishlist_count']),
        couponCount: asInt(j['coupon_count']),
        reviewsWrittenCount: asInt(j['reviews_written_count']),
        reviewsPendingCount: asInt(j['reviews_pending_count']),
        addressesCount: asInt(j['addresses_count']),
        devicesCount: asInt(j['devices_count']),
        requestsCount: asInt(j['requests_count']),
      );
}

class WalletSummary {
  final double balance;
  final String currency;
  final String? source;
  final String? expiresAt;

  WalletSummary({
    required this.balance,
    required this.currency,
    this.source,
    this.expiresAt,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> j) => WalletSummary(
        balance: asDouble(j['balance']),
        currency: asString(j['currency'], 'INR'),
        source: j['source']?.toString(),
        expiresAt: j['expires_at']?.toString(),
      );
}

class SavedPaymentMethod {
  final int id;
  final String type;
  final String label;
  final String maskedValue;
  final String? provider;
  final bool verified;
  final String? expiresAt;
  final bool isExpired;
  final bool isDefault;

  SavedPaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    required this.maskedValue,
    this.provider,
    required this.verified,
    this.expiresAt,
    required this.isExpired,
    required this.isDefault,
  });

  factory SavedPaymentMethod.fromJson(Map<String, dynamic> j) =>
      SavedPaymentMethod(
        id: asInt(j['id']),
        type: asString(j['type']),
        label: asString(j['label']),
        maskedValue: asString(j['masked_value']),
        provider: j['provider']?.toString(),
        verified: asBool(j['verified']),
        expiresAt: j['expires_at']?.toString(),
        isExpired: asBool(j['is_expired']),
        isDefault: asBool(j['is_default']),
      );
}

class NotificationPreferences {
  final bool pushEnabled;
  final bool orderUpdates;
  final bool dealsPriceDrops;
  final bool emailMarketing;
  final bool smsOrderUpdates;

  NotificationPreferences({
    required this.pushEnabled,
    required this.orderUpdates,
    required this.dealsPriceDrops,
    required this.emailMarketing,
    required this.smsOrderUpdates,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> j) =>
      NotificationPreferences(
        pushEnabled: asBool(j['push_enabled'], true),
        orderUpdates: asBool(j['order_updates'], true),
        dealsPriceDrops: asBool(j['deals_price_drops'], true),
        emailMarketing: asBool(j['email_marketing'], true),
        smsOrderUpdates: asBool(j['sms_order_updates'], true),
      );

  Map<String, dynamic> toJson() => {
        'push_enabled': pushEnabled,
        'order_updates': orderUpdates,
        'deals_price_drops': dealsPriceDrops,
        'email_marketing': emailMarketing,
        'sms_order_updates': smsOrderUpdates,
      };

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? orderUpdates,
    bool? dealsPriceDrops,
    bool? emailMarketing,
    bool? smsOrderUpdates,
  }) =>
      NotificationPreferences(
        pushEnabled: pushEnabled ?? this.pushEnabled,
        orderUpdates: orderUpdates ?? this.orderUpdates,
        dealsPriceDrops: dealsPriceDrops ?? this.dealsPriceDrops,
        emailMarketing: emailMarketing ?? this.emailMarketing,
        smsOrderUpdates: smsOrderUpdates ?? this.smsOrderUpdates,
      );
}

class SupportConfig {
  final bool chatEnabled;
  final String? chatSessionUrl;
  final String? phone;
  final String? email;
  final String? hours;
  final List<SupportFaq> faqs;

  SupportConfig({
    required this.chatEnabled,
    this.chatSessionUrl,
    this.phone,
    this.email,
    this.hours,
    required this.faqs,
  });

  factory SupportConfig.fromJson(Map<String, dynamic> j) => SupportConfig(
        chatEnabled: asBool(j['chat_enabled']),
        chatSessionUrl: j['chat_session_url']?.toString(),
        phone: j['phone']?.toString(),
        email: j['email']?.toString(),
        hours: j['hours']?.toString(),
        faqs: (j['faq'] as List? ?? j['faqs'] as List? ?? [])
            .map((e) => SupportFaq.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class SupportFaq {
  final int id;
  final String question;
  final String answer;

  SupportFaq({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory SupportFaq.fromJson(Map<String, dynamic> j) => SupportFaq(
        id: asInt(j['id']),
        question: asString(j['question']),
        answer: asString(j['answer']),
      );
}

class LegalPageRef {
  final String slug;
  final String title;

  LegalPageRef({required this.slug, required this.title});

  factory LegalPageRef.fromJson(Map<String, dynamic> j) =>
      LegalPageRef(slug: asString(j['slug']), title: asString(j['title']));
}

class HomeBanner {
  final int id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? deeplinkRoute;
  final Map<String, dynamic> deeplinkParams;
  final int sortOrder;
  final bool active;

  HomeBanner({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.deeplinkRoute,
    this.deeplinkParams = const {},
    this.sortOrder = 0,
    this.active = true,
  });

  factory HomeBanner.fromJson(Map<String, dynamic> j) => HomeBanner(
        id: asInt(j['id']),
        title: asString(j['title']),
        subtitle: j['subtitle']?.toString(),
        imageUrl: j['image_url']?.toString(),
        deeplinkRoute: j['deeplink_route']?.toString(),
        deeplinkParams: j['deeplink_params'] == null
            ? const {}
            : Map<String, dynamic>.from(j['deeplink_params']),
        sortOrder: asInt(j['sort_order']),
        active: asBool(j['active'], true),
      );
}

class AppConfig {
  final String storeName;
  final String? sellerOnboardingUrl;
  final String? supportEmail;
  final String? supportPhone;

  AppConfig({
    required this.storeName,
    this.sellerOnboardingUrl,
    this.supportEmail,
    this.supportPhone,
  });

  factory AppConfig.fromJson(Map<String, dynamic> j) => AppConfig(
        storeName: asString(j['store_name'], 'CFO Shop'),
        sellerOnboardingUrl: j['seller_onboarding_url']?.toString(),
        supportEmail: j['support_email']?.toString(),
        supportPhone: j['support_phone']?.toString(),
      );
}
