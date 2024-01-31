import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/menu_model.dart';
import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/view/screens/menu/widget/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<MenuModel> menuList = [
      MenuModel(icon: '', title: 'profile'.tr, backgroundColor: const Color(0xFF4389FF), route: RouteHelper.getProfileRoute()),
      // MenuModel(icon: Images.restaurant, title: 'restaurant'.tr, backgroundColor: Color(0xFFA9B9F1), route: RouteHelper.getRestaurantRoute()),
      // MenuModel(icon: Images.dollar, title: 'wallet'.tr, backgroundColor: Color(0xFFF7BC7E), route: RouteHelper.getWalletRoute()),
      MenuModel(icon: Images.creditCard, title: 'bank_info'.tr, backgroundColor: const Color(0xFF448AFF), route: RouteHelper.getBankInfoRoute()),
      //MenuModel(icon: Images.pos, title: 'pos'.tr, backgroundColor: Color(0xFF448AFF), route: RouteHelper.getPosRoute()),
      MenuModel(
        icon: Images.addFood, title: 'add_food'.tr, backgroundColor: const Color(0xFFFF8A80), route: RouteHelper.getProductRoute(null),
        isBlocked: !Get.find<AuthController>().profileModel!.restaurants![0].foodSection!,
      ),
      MenuModel(icon: Images.campaign, title: 'campaign'.tr, backgroundColor: const Color(0xFFFF8A80), route: RouteHelper.getCampaignRoute()),
      MenuModel(icon: Images.addon, title: 'addons'.tr, backgroundColor: const Color(0xFFFF8A80), route: RouteHelper.getAddonsRoute()),
      MenuModel(icon: Images.categories, title: 'categories'.tr, backgroundColor: const Color(0xFFFF8A80), route: RouteHelper.getCategoriesRoute()),
      MenuModel(icon: Images.coupon, title: 'coupon'.tr, backgroundColor: const Color(0xFFFF8A80), route: RouteHelper.getCouponRoute()),
      MenuModel(icon: Images.language, title: 'language'.tr, backgroundColor: const Color(0xFF62889C), route: RouteHelper.getLanguageRoute('menu')),
      MenuModel(icon: Images.expense, title: 'expense_report'.tr, backgroundColor: const Color(0xFF62889C), route: RouteHelper.getExpenseRoute()),
      MenuModel(icon: Images.policy, title: 'privacy_policy'.tr, backgroundColor: const Color(0xFF62889C), route: RouteHelper.getPrivacyRoute()),
      MenuModel(icon: Images.terms, title: 'terms_condition'.tr, backgroundColor: const Color(0xFF62889C), route: RouteHelper.getTermsRoute()),
      MenuModel(
        icon: Images.chat, title: 'conversation'.tr, backgroundColor: const Color(0xFF62889C), route: RouteHelper.getConversationListRoute(),
        isNotSubscribe: (Get.find<AuthController>().profileModel!.restaurants![0].restaurantModel == 'subscription'
           && Get.find<AuthController>().profileModel!.subscription != null && Get.find<AuthController>().profileModel!.subscription!.chat == 0) ,
      ),
      MenuModel(icon: Images.logOut, title: 'logout'.tr, backgroundColor: const Color(0xFFFF4B55), route: ''),
    ];

    if(Get.find<AuthController>().profileModel!.subscription != null) {
      menuList.insert(10, MenuModel(
        icon: Images.subscription, title: 'my_subscription'.tr, backgroundColor: const Color(0xFF62889C), route: RouteHelper.getSubscriptionViewRoute(),
      ));
    }

    if(Get.find<AuthController>().profileModel!.restaurants![0].selfDeliverySystem == 1) {
      menuList.insert(5, MenuModel(
        icon: Images.deliveryMan, title: 'delivery_man'.tr, backgroundColor: const Color(0xFF448AFF), route: RouteHelper.getDeliveryManRoute(),
      ));
    }

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
        color: Theme.of(context).cardColor,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, childAspectRatio: (1/1.2),
            crossAxisSpacing: Dimensions.paddingSizeExtraSmall, mainAxisSpacing: Dimensions.paddingSizeExtraSmall,
          ),
          itemCount: menuList.length,
          itemBuilder: (context, index) {
            return MenuButton(menu: menuList[index], isProfile: index == 0, isLogout: index == menuList.length-1);
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

      ]),
    );
  }
}
