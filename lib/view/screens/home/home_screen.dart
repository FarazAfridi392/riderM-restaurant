import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/notification_controller.dart';
import 'package:efood_multivendor_restaurant/controller/order_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/order_model.dart';
import 'package:efood_multivendor_restaurant/helper/price_converter.dart';
import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
import 'package:efood_multivendor_restaurant/util/app_constants.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/confirmation_dialog.dart';
import 'package:efood_multivendor_restaurant/view/base/order_shimmer.dart';
import 'package:efood_multivendor_restaurant/view/base/order_widget.dart';
import 'package:efood_multivendor_restaurant/view/screens/home/widget/order_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isVisible = false;

  Future<void> _loadData() async {
    await Get.find<AuthController>().getProfile();
    await Get.find<OrderController>().getCurrentOrders();
    await Get.find<NotificationController>().getNotificationList();
  }

  @override
  Widget build(BuildContext context) {
    _loadData();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        leading: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Image.asset(Images.logo, height: 30, width: 30),
        ),
        titleSpacing: 0, elevation: 0,
        title: Text(AppConstants.appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoMedium.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: Dimensions.fontSizeDefault,
            )),
        // title: Image.asset(Images.logoName, width: 120),
        actions: [
          IconButton(
            icon: GetBuilder<NotificationController>(
                builder: (notificationController) {
              bool hasNewNotification = false;
              if (notificationController.notificationList != null) {
                hasNewNotification =
                    notificationController.notificationList!.length !=
                        notificationController.getSeenNotificationCount();
              }
              return Stack(children: [
                Icon(Icons.notifications,
                    size: 25,
                    color: Theme.of(context).textTheme.bodyLarge!.color),
                hasNewNotification
                    ? Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 1, color: Theme.of(context).cardColor),
                          ),
                        ))
                    : const SizedBox(),
              ]);
            }),
            onPressed: () => Get.toNamed(RouteHelper.getNotificationRoute()),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [
            GetBuilder<AuthController>(builder: (authController) {
              return Column(children: [
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[Get.isDarkMode ? 700 : 200]!,
                          spreadRadius: 1,
                          blurRadius: 5)
                    ],
                  ),
                  child: Row(children: [
                    Expanded(
                        child: Text(
                      'restaurant_temporarily_closed'.tr,
                      style: robotoMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                    authController.profileModel != null
                        ? Switch(
                            value: !authController
                                .profileModel!.restaurants![0].active!,
                            activeColor: Theme.of(context).primaryColor,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onChanged: (bool isActive) {
                              Get.dialog(ConfirmationDialog(
                                icon: Images.warning,
                                description: isActive
                                    ? 'are_you_sure_to_close_restaurant'.tr
                                    : 'are_you_sure_to_open_restaurant'.tr,
                                onYesPressed: () {
                                  Get.back();
                                  authController.toggleRestaurantClosedStatus();
                                },
                              ));
                            },
                          )
                        : Shimmer(
                            duration: const Duration(seconds: 2),
                            child: Container(
                                height: 30,
                                width: 50,
                                color: Colors.grey[300])),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(children: [
                  Row(
                                    children: [
                                      _isVisible
                                          ? SizedBox()
                                          : Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                'Earning is Hidden'.tr,
                                                style: robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeLarge,
                                                    color: Theme.of(context)
                                                        .cardColor),
                                              ),
                                            ),
                                      Spacer(),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                          icon: _isVisible
                                              ? Icon(
                                                  Icons.visibility,
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                )
                                              : Icon(
                                                  Icons.visibility_off,
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                ),
                                          onPressed: () {
                                            setState(() {
                                              _isVisible =
                                                  !_isVisible;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  _isVisible
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(Images.wallet,
                                                width: 60, height: 60),
                                            SizedBox(
                                                width: Dimensions
                                                    .paddingSizeLarge),
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'today'.tr,
                                                    style: robotoMedium.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeSmall,
                                                        color: Theme.of(context)
                                                            .cardColor),
                                                  ),
                                                  const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall),
                                                  Text(
                                                    authController
                                                                .profileModel !=
                                                            null
                                                        ? PriceConverter
                                                            .convertPrice(
                                                                authController
                                                                    .profileModel!
                                                                    .todaysEarning)
                                                        : '0',
                                                    style: robotoBold.copyWith(
                                                        fontSize: 24,
                                                        color: Theme.of(context)
                                                            .cardColor),
                                                  ),
                                                ]),
                                          ],
                                        )
                                      : const SizedBox(),
                                  _isVisible
                                      ? const SizedBox(height: 30)
                                      : const SizedBox(),
                                  _isVisible
                                      ? Row(
                                          children: [
                                            Expanded(
                                                child: Column(children: [
                                              Text(
                                                'this_week'.tr,
                                                style: robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(context)
                                                        .cardColor),
                                              ),
                                              const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeSmall),
                                              Text(
                                                authController.profileModel !=
                                                        null
                                                    ? PriceConverter
                                                        .convertPrice(
                                                            authController
                                                                .profileModel!
                                                                .thisWeekEarning)
                                                    : '0',
                                                style: robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeLarge,
                                                    color: Theme.of(context)
                                                        .cardColor),
                                              ),
                                            ])),
                                            Container(
                                                height: 30,
                                                width: 1,
                                                color: Theme.of(context)
                                                    .cardColor),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'this_month'.tr,
                                                    style: robotoMedium.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeLarge,
                                                        color: Theme.of(context)
                                                            .cardColor),
                                                  ),
                                                  const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeSmall),
                                                  Text(
                                                    authController
                                                                .profileModel !=
                                                            null
                                                        ? PriceConverter
                                                            .convertPrice(
                                                                authController
                                                                    .profileModel!
                                                                    .thisMonthEarning)
                                                        : '0',
                                                    style: robotoMedium.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeExtraLarge,
                                                        color: Theme.of(context)
                                                            .cardColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : SizedBox()
                  ]),
                ),
              ]);
            }),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            GetBuilder<OrderController>(builder: (orderController) {
              List<OrderModel> orderList = [];
              if (orderController.runningOrders != null) {
                orderList = orderController
                    .runningOrders![orderController.orderIndex].orderList;
              }

              return Column(children: [
                orderController.runningOrders != null
                    ? Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).disabledColor, width: 1),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: orderController.runningOrders!.length,
                          itemBuilder: (context, index) {
                            return OrderButton(
                              title: orderController
                                  .runningOrders![index].status.tr,
                              index: index,
                              orderController: orderController,
                              fromHistory: false,
                            );
                          },
                        ),
                      )
                    : const SizedBox(),
                Row(children: [
                  orderController.runningOrders != null
                      ? InkWell(
                          onTap: () => orderController.toggleCampaignOnly(),
                          child: Row(children: [
                            Checkbox(
                              activeColor: Theme.of(context).primaryColor,
                              value: orderController.campaignOnly,
                              onChanged: (isActive) =>
                                  orderController.toggleCampaignOnly(),
                            ),
                            Text(
                              'campaign_order'.tr,
                              style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).disabledColor),
                            ),
                          ]),
                        )
                      : const SizedBox(),
                  orderController.runningOrders != null
                      ? InkWell(
                          onTap: () => orderController.toggleSubscriptionOnly(),
                          child: Row(children: [
                            Checkbox(
                              activeColor: Theme.of(context).primaryColor,
                              value: orderController.subscriptionOnly,
                              onChanged: (isActive) =>
                                  orderController.toggleSubscriptionOnly(),
                            ),
                            Text(
                              'subscription_order'.tr,
                              style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).disabledColor),
                            ),
                          ]),
                        )
                      : const SizedBox(),
                ]),
                orderController.runningOrders != null
                    ? orderList.isNotEmpty
                        ? ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: orderList.length,
                            itemBuilder: (context, index) {
                              return OrderWidget(
                                  orderModel: orderList[index],
                                  hasDivider: index != orderList.length - 1,
                                  isRunning: true);
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Center(child: Text('no_order_found'.tr)),
                          )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return OrderShimmer(
                              isEnabled: orderController.runningOrders == null);
                        },
                      ),
              ]);
            }),
          ]),
        ),
      ),
    );
  }
}
