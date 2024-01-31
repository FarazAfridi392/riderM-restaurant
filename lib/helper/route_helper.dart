import 'dart:convert';

import 'package:efood_multivendor_restaurant/data/model/body/notification_body.dart';
import 'package:efood_multivendor_restaurant/data/model/response/campaign_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/category_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/conversation_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/delivery_man_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/order_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/product_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/profile_model.dart';
import 'package:efood_multivendor_restaurant/view/screens/addon/addon_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/auth/business_plan/payment_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/auth/business_plan/payment_successful_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/auth/restaurant_registration_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/auth/sign_in_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/bank/bank_info_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/bank/wallet_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/bank/withdraw_history_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/campaign/campaign_details_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/campaign/campaign_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/category/category_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/chat/chat_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/chat/conversation_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/coupon/coupon_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/dashboard/dashboard_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/deliveryman/add_delivery_man_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/deliveryman/delivery_man_details_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/deliveryman/delivery_man_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/expence/expense_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/forget/forget_pass_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/forget/new_pass_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/forget/verification_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/html/html_viewer_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/language/language_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/notification/notification_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/order/order_details_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/pos/pos_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/profile/profile_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/profile/update_profile_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/restaurant/add_name_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/restaurant/add_product_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/restaurant/product_details_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/restaurant/restaurant_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/restaurant/restaurant_settings_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/splash/splash_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/subscription_view/renew_subscription_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/subscription_view/subscription_view_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/update/update_screen.dart';
import 'package:get/get.dart';

class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String language = '/language';
  static const String signIn = '/sign-in';
  static const String verification = '/verification';
  static const String main = '/main';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String orderDetails = '/order-details';
  static const String profile = '/profile';
  static const String updateProfile = '/update-profile';
  static const String notification = '/notification';
  static const String bankInfo = '/bank-info';
  static const String wallet = '/wallet';
  static const String withdrawHistory = '/withdraw-history';
  static const String restaurant = '/restaurant';
  static const String campaign = '/campaign';
  static const String campaignDetails = '/campaign-details';
  static const String product = '/product';
  static const String addProduct = '/add-product';
  static const String categories = '/categories';
  static const String subCategories = '/sub-categories';
  static const String restaurantSettings = '/restaurant-settings';
  static const String addons = '/addons';
  static const String productDetails = '/product-details';
  static const String pos = '/pos';
  static const String deliveryMan = '/delivery-man';
  static const String addDeliveryMan = '/add-delivery-man';
  static const String deliveryManDetails = '/delivery-man-details';
  static const String terms = '/terms-and-condition';
  static const String privacy = '/privacy-policy';
  static const String update = '/update';
  static const String chatScreen = '/chat-screen';
  static const String conversationListScreen = '/chat-list-screen';
  static const String restaurantRegistration = '/restaurant-registration';
  static const String subscriptionView = '/subscriptionView';
  static const String renewSubscription = '/renew-subscription';
  static const String coupon = '/coupon';
  static const String expense = '/expense';
  static const String payment = '/payment';
  static const String success = '/success';

  static String getInitialRoute() => initial;
  static String getSplashRoute(NotificationBody? body) {
    String data = 'null';
    if(body != null) {
      List<int> encoded = utf8.encode(jsonEncode(body.toJson()));
      data = base64Encode(encoded);
    }
    return '$splash?data=$data';
  }
  static String getLanguageRoute(String page) => '$language?page=$page';
  static String getSignInRoute() => signIn;
  static String getVerificationRoute(String email) => '$verification?email=$email';
  static String getMainRoute(String page) => '$main?page=$page';
  static String getForgotPassRoute() => forgotPassword;
  static String getResetPasswordRoute(String? phone, String token, String page) => '$resetPassword?phone=$phone&token=$token&page=$page';
  static String getOrderDetailsRoute(int? orderID) => '$orderDetails?id=$orderID';
  static String getProfileRoute() => profile;
  static String getUpdateProfileRoute() => updateProfile;
  static String getNotificationRoute({bool fromNotification = false}) => '$notification?from_notification=${fromNotification.toString()}';
  static String getBankInfoRoute() => bankInfo;
  static String getWalletRoute() => wallet;
  static String getWithdrawHistoryRoute() => withdrawHistory;
  static String getRestaurantRoute() => restaurant;
  static String getCampaignRoute() => campaign;
  static String getCampaignDetailsRoute(int? id) => '$campaignDetails?id=$id';
  static String getUpdateRoute(bool isUpdate) => '$update?update=${isUpdate.toString()}';
  static String getProductRoute(Product? productModel) {
    if(productModel == null) {
      return '$product?data=null';
    }
    List<int> encoded = utf8.encode(jsonEncode(productModel.toJson()));
    String data = base64Encode(encoded);
    return '$product?data=$data';
  }
  static String getAddProductRoute(Product? productModel, List<Translation> translations) {
    String translations0 = base64Encode(utf8.encode(jsonEncode(translations)));
    if(productModel == null) {
      return '$addProduct?data=null&translations=$translations0';
    }
    String data = base64Encode(utf8.encode(jsonEncode(productModel.toJson())));
    return '$addProduct?data=$data&translations=$translations0';
  }
  static String getCategoriesRoute() => categories;
  static String getCouponRoute() => coupon;
  static String getSubCategoriesRoute(CategoryModel categoryModel) {
    List<int> encoded = utf8.encode(jsonEncode(categoryModel.toJson()));
    String data = base64Encode(encoded);
    return '$subCategories?data=$data';
  }
  static String getRestaurantSettingsRoute(Restaurant restaurant) {
    List<int> encoded = utf8.encode(jsonEncode(restaurant.toJson()));
    String data = base64Encode(encoded);
    return '$restaurantSettings?data=$data';
  }
  static String getAddonsRoute() => addons;
  static String getProductDetailsRoute(Product product) {
    List<int> encoded = utf8.encode(jsonEncode(product.toJson()));
    String data = base64Encode(encoded);
    return '$productDetails?data=$data';
  }
  static String getPosRoute() => pos;
  static String getDeliveryManRoute() => deliveryMan;
  static String getAddDeliveryManRoute(DeliveryManModel? deliveryMan) {
    if(deliveryMan == null) {
      return '$addDeliveryMan?data=null';
    }
    List<int> encoded = utf8.encode(jsonEncode(deliveryMan.toJson()));
    String data = base64Encode(encoded);
    return '$addDeliveryMan?data=$data';
  }
  static String getDeliveryManDetailsRoute(DeliveryManModel deliveryMan) {
    List<int> encoded = utf8.encode(jsonEncode(deliveryMan.toJson()));
    String data = base64Encode(encoded);
    return '$deliveryManDetails?data=$data';
  }
  static String getTermsRoute() => terms;
  static String getPrivacyRoute() => privacy;
  static String getChatRoute({required NotificationBody? notificationBody, User? user, int? conversationId}) {
    
    String notificationBody0 = 'null';
    String user0 = 'null';
    
    if(notificationBody != null) {
      notificationBody0 = base64Encode(utf8.encode(jsonEncode(notificationBody)));
    }
    if(user != null) {
      user0 = base64Encode(utf8.encode(jsonEncode(user.toJson())));
    }
    return '$chatScreen?notification_body=$notificationBody0&user=$user0&conversation_id=$conversationId';
  }
  static String getConversationListRoute() => conversationListScreen;
  static String getRestaurantRegistrationRoute() => restaurantRegistration;
  static String getSubscriptionViewRoute() => subscriptionView;
  static String getRenewSubscriptionRoute() => renewSubscription;
  static String getExpenseRoute() => expense;
  static String getPaymentRoute(String? paymentMethod, String? redirectUrl) {
    return '$payment?payment-method=$paymentMethod&redirect-url=$redirectUrl';
  }
  static String getSuccessRoute(String status) => '$success?status=$status';

  static List<GetPage> routes = [
    GetPage(name: initial, page: () => const DashboardScreen(pageIndex: 0)),
    GetPage(name: splash, page: () {
      NotificationBody? data;
      if(Get.parameters['data'] != 'null') {
        List<int> decode = base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
        data = NotificationBody.fromJson(jsonDecode(utf8.decode(decode)));
      }
      return SplashScreen(body: data);
    }),
    GetPage(name: language, page: () => LanguageScreen(fromMenu: Get.parameters['page'] == 'menu')),
    GetPage(name: signIn, page: () => SignInScreen()),
    GetPage(name: verification, page: () => VerificationScreen(email: Get.parameters['email'])),
    GetPage(name: main, page: () => DashboardScreen(
      pageIndex: Get.parameters['page'] == 'home' ? 0 : Get.parameters['page'] == 'favourite' ? 1
          : Get.parameters['page'] == 'cart' ? 2 : Get.parameters['page'] == 'order' ? 3 : Get.parameters['page'] == 'menu' ? 4 : 0,
    )),
    GetPage(name: forgotPassword, page: () => const ForgetPassScreen()),
    GetPage(name: resetPassword, page: () => NewPassScreen(
      resetToken: Get.parameters['token'], email: Get.parameters['phone'], fromPasswordChange: Get.parameters['page'] == 'password-change',
    )),
    GetPage(name: orderDetails, page: () {
      return Get.arguments ?? OrderDetailsScreen(
        orderModel: OrderModel(id: int.parse(Get.parameters['id']!)), isRunningOrder: false,
      );
    }),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: updateProfile, page: () => UpdateProfileScreen()),
    GetPage(name: notification, page: () => NotificationScreen(fromNotification: Get.parameters['from_notification'] == 'true')),
    GetPage(name: bankInfo, page: () => const BankInfoScreen()),
    GetPage(name: wallet, page: () => const WalletScreen()),
    GetPage(name: withdrawHistory, page: () => const WithdrawHistoryScreen()),
    GetPage(name: restaurant, page: () => const RestaurantScreen()),
    GetPage(name: campaign, page: () => const CampaignScreen()),
    GetPage(name: campaignDetails, page: () {
      return Get.arguments ?? CampaignDetailsScreen(
        campaignModel: CampaignModel(id: int.parse(Get.parameters['id']!)),
      );
    }),
    GetPage(name: product, page: () {
      if(Get.parameters['data'] == 'null') {
        return const AddNameScreen(product: null);
      }
      List<int> decode = base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
      Product data = Product.fromJson(jsonDecode(utf8.decode(decode)));
      return AddNameScreen(product: data);
    }),
    GetPage(name: addProduct, page: () {
      List<Translation> translations = [];
      jsonDecode(utf8.decode(base64Decode(Get.parameters['translations']!.replaceAll(' ', '+')))).forEach((data) {
        translations.add(Translation.fromJson(data));
      });
      if(Get.parameters['data'] == 'null') {
        return AddProductScreen(product: null, translations: translations);
      }
      List<int> decode = base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
      Product data = Product.fromJson(jsonDecode(utf8.decode(decode)));
      return AddProductScreen(product: data, translations: translations);
    }),
    GetPage(name: categories, page: () => const CategoryScreen(categoryModel: null)),
    GetPage(name: subCategories, page: () {
      List<int> decode = base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
      CategoryModel data = CategoryModel.fromJson(jsonDecode(utf8.decode(decode)));
      return CategoryScreen(categoryModel: data);
    }),
    GetPage(name: restaurantSettings, page: () {
      List<int> decode = base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
      Restaurant data = Restaurant.fromJson(jsonDecode(utf8.decode(decode)));
      return RestaurantSettingsScreen(restaurant: data);
    }),
    GetPage(name: addons, page: () => const AddonScreen()),
    GetPage(name: productDetails, page: () {
      List<int> decode = base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
      Product data = Product.fromJson(jsonDecode(utf8.decode(decode)));
      return ProductDetailsScreen(product: data);
    }),
    GetPage(name: pos, page: () => const PosScreen()),
    GetPage(name: deliveryMan, page: () => const DeliveryManScreen()),
    GetPage(name: addDeliveryMan, page: () {
      if(Get.parameters['data'] == 'null') {
        return const AddDeliveryManScreen(deliveryMan: null);
      }
      List<int> decode = base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
      DeliveryManModel data = DeliveryManModel.fromJson(jsonDecode(utf8.decode(decode)));
      return AddDeliveryManScreen(deliveryMan: data);
    }),
    GetPage(name: deliveryManDetails, page: () {
      List<int> decode = base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
      DeliveryManModel data = DeliveryManModel.fromJson(jsonDecode(utf8.decode(decode)));
      return DeliveryManDetailsScreen(deliveryMan: data);
    }),
    GetPage(name: terms, page: () => const HtmlViewerScreen(isPrivacyPolicy: false)),
    GetPage(name: privacy, page: () => const HtmlViewerScreen(isPrivacyPolicy: true)),
    GetPage(name: update, page: () => UpdateScreen(isUpdate: Get.parameters['update'] == 'true')),
    GetPage(name: chatScreen, page: () {
      
      NotificationBody? notificationBody;
      if(Get.parameters['notification_body'] != 'null') {
        notificationBody = NotificationBody.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['notification_body']!.replaceAll(' ', '+')))));
      }
      User? user;
      if(Get.parameters['user'] != 'null') {
        user = User.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['user']!.replaceAll(' ', '+')))));
      }
      return ChatScreen(
        notificationBody : notificationBody, user: user,
        conversationId: Get.parameters['conversation_id'] != null && Get.parameters['conversation_id'] != 'null' ? int.parse(Get.parameters['conversation_id']!) : null,
      );
    }),
    GetPage(name: conversationListScreen, page: () => const ConversationScreen()),
    GetPage(name: restaurantRegistration, page: () => const RestaurantRegistrationScreen()),
    GetPage(name: subscriptionView, page: () => const SubscriptionViewScreen()),
    GetPage(name: renewSubscription, page: () => const RenewSubscriptionScreen()),
    GetPage(name: coupon, page: () => const CouponScreen()),
    GetPage(name: expense, page: () => const ExpenseScreen()),
    GetPage(name: payment, page: () {
      String paymentMethod = Get.parameters['payment-method']!;
      String addFundUrl = Get.parameters['redirect-url']!;
      return PaymentScreen(paymentMethod: paymentMethod, redirectUrl: addFundUrl);
    }),
    GetPage(name: success, page: () => PaymentSuccessfulScreen(success: Get.parameters['status'] == 'success')),
  ];
}