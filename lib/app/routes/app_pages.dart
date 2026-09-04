import 'package:get/get.dart';
import '../modules/account/about/about_view.dart';
import '../modules/account/address_form/address_form_view.dart';
import '../modules/account/addresses/addresses_view.dart';
import '../modules/account/change_password/change_password_view.dart';
import '../modules/account/coupons/coupons_view.dart';
import '../modules/account/devices/devices_view.dart';
import '../modules/account/help/help_view.dart';
import '../modules/account/my_reviews_view.dart';
import '../modules/account/notification_settings/notification_settings_view.dart';
import '../modules/account/payments/payments_info_view.dart';
import '../modules/account/profile/profile_view.dart';
import '../modules/account/wishlist/wishlist_view.dart';
import '../modules/auth/email_login/email_login_view.dart';
import '../modules/auth/forgot_password/forgot_password_view.dart';
import '../modules/auth/otp/otp_view.dart';
import '../modules/cart/cart_controller.dart';
import '../modules/cart/cart_view.dart';
import '../modules/categories/categories_controller.dart';
import '../modules/categories/categories_view.dart';
import '../modules/checkout/address/checkout_address_view.dart';
import '../modules/checkout/delivery/checkout_delivery_view.dart';
import '../modules/checkout/payment/checkout_payment_view.dart';
import '../modules/checkout/success/checkout_success_view.dart';
import '../modules/home/home_controller.dart';
import '../modules/home/home_view.dart';
import '../modules/nav/nav_controller.dart';
import '../modules/nav/nav_view.dart';
import '../modules/notifications/notifications_view.dart';
import '../modules/orders/detail/order_detail_view.dart';
import '../modules/orders/list/orders_list_controller.dart';
import '../modules/orders/list/orders_list_view.dart';
import '../modules/orders/track/order_track_view.dart';
import '../modules/product_detail/product_detail_view.dart';
import '../modules/requests/cancel_form/cancel_form_view.dart';
import '../modules/requests/detail/request_detail_view.dart';
import '../modules/requests/list/requests_list_view.dart';
import '../modules/requests/return_form/return_form_view.dart';
import '../modules/results/results_view.dart';
import '../modules/reviews/reviews_view.dart';
import '../modules/search/search_view.dart';
import '../modules/seller/seller_view.dart';
import '../modules/splash/splash_view.dart';
import 'app_routes.dart';
import 'initial_binding.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.nav,
      page: () => const NavView(),
      // The nav shell keeps all 5 tabs alive in an IndexedStack, so every
      // tab's controller must exist before that first build — not lazily
      // self-registered inside each tab's build(), which races with
      // IndexedStack building every child eagerly on the first frame.
      binding: BindingsBuilder(() {
        Get.put(NavController());
        Get.put(HomeController());
        Get.put(CategoriesController());
        Get.put(OrdersListController());
        Get.put(CartController());
      }),
    ),

    // Auth
    GetPage(name: AppRoutes.login, page: () => const OtpView()),
    GetPage(name: AppRoutes.otp, page: () => const OtpView()),
    GetPage(name: AppRoutes.emailLogin, page: () => const EmailLoginView()),
    GetPage(name: AppRoutes.register, page: () => const EmailLoginView()),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
    ),

    // Browse
    GetPage(name: AppRoutes.home, page: () => const HomeView()),
    GetPage(name: AppRoutes.categories, page: () => const CategoriesView()),
    GetPage(name: AppRoutes.search, page: () => const SearchView()),
    GetPage(name: AppRoutes.results, page: () => const ResultsView()),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailView(),
    ),
    GetPage(name: AppRoutes.reviews, page: () => const ReviewsView()),
    GetPage(name: AppRoutes.seller, page: () => const SellerView()),

    // Cart / checkout
    GetPage(name: AppRoutes.cart, page: () => const CartView()),
    GetPage(
      name: AppRoutes.checkoutAddress,
      page: () => const CheckoutAddressView(),
    ),
    GetPage(
      name: AppRoutes.checkoutDelivery,
      page: () => const CheckoutDeliveryView(),
    ),
    GetPage(
      name: AppRoutes.checkoutPayment,
      page: () => const CheckoutPaymentView(),
    ),
    GetPage(
      name: AppRoutes.checkoutSuccess,
      page: () => const CheckoutSuccessView(),
    ),

    // Orders
    GetPage(name: AppRoutes.orders, page: () => const OrdersListView()),
    GetPage(name: AppRoutes.orderDetail, page: () => const OrderDetailView()),
    GetPage(name: AppRoutes.orderTrack, page: () => const OrderTrackView()),

    // Requests
    GetPage(name: AppRoutes.requests, page: () => const RequestsListView()),
    GetPage(
      name: AppRoutes.requestDetail,
      page: () => const RequestDetailView(),
    ),
    GetPage(name: AppRoutes.cancelForm, page: () => const CancelFormView()),
    GetPage(name: AppRoutes.returnForm, page: () => const ReturnFormView()),

    // Account
    GetPage(name: AppRoutes.profile, page: () => const ProfileView()),
    GetPage(name: AppRoutes.addresses, page: () => const AddressesView()),
    GetPage(name: AppRoutes.addressForm, page: () => const AddressFormView()),
    GetPage(name: AppRoutes.paymentsInfo, page: () => const PaymentsInfoView()),
    GetPage(name: AppRoutes.coupons, page: () => const CouponsView()),
    GetPage(
      name: AppRoutes.notificationSettings,
      page: () => const NotificationSettingsView(),
    ),
    GetPage(name: AppRoutes.devices, page: () => const DevicesView()),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
    ),
    GetPage(name: AppRoutes.help, page: () => const HelpView()),
    GetPage(name: AppRoutes.about, page: () => const AboutView()),
    GetPage(name: AppRoutes.wishlist, page: () => const WishlistView()),
    GetPage(name: AppRoutes.myReviews, page: () => const MyReviewsView()),

    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
    ),
  ];
}
