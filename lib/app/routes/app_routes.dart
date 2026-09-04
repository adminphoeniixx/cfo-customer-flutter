class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const nav =
      '/nav'; // bottom-nav shell: home/categories/orders/cart/account

  static const login = '/login';
  static const otp = '/otp';
  static const emailLogin = '/email-login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  static const home = '/home';
  static const categories = '/categories';
  static const search = '/search';
  static const results = '/results';
  static const productDetail = '/product';
  static const reviews = '/reviews';
  static const writeReview = '/write-review';
  static const seller = '/seller';

  static const cart = '/cart';
  static const checkoutAddress = '/checkout/address';
  static const checkoutDelivery = '/checkout/delivery';
  static const checkoutPayment = '/checkout/payment';
  static const checkoutSuccess = '/checkout/success';

  static const orders = '/orders';
  static const orderDetail = '/orders/detail';
  static const orderTrack = '/orders/track';

  static const requests = '/requests';
  static const requestDetail = '/requests/detail';
  static const cancelForm = '/requests/cancel';
  static const returnForm = '/requests/return';

  static const account = '/account';
  static const profile = '/account/profile';
  static const addresses = '/account/addresses';
  static const addressForm = '/account/addresses/form';
  static const paymentsInfo = '/account/payments';
  static const coupons = '/account/coupons';
  static const notificationSettings = '/account/notification-settings';
  static const devices = '/account/devices';
  static const changePassword = '/account/change-password';
  static const help = '/account/help';
  static const about = '/account/about';
  static const wishlist = '/account/wishlist';
  static const myReviews = '/account/reviews';

  static const notifications = '/notifications';
}
