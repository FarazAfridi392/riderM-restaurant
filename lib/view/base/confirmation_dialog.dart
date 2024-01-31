import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/campaign_controller.dart';
import 'package:efood_multivendor_restaurant/controller/coupon_controller.dart';
import 'package:efood_multivendor_restaurant/controller/delivery_man_controller.dart';
import 'package:efood_multivendor_restaurant/controller/order_controller.dart';
import 'package:efood_multivendor_restaurant/controller/restaurant_controller.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmationDialog extends StatelessWidget {
  final String icon;
  final String? title;
  final String description;
  final String? adminText;
  final Function onYesPressed;
  final Function? onNoPressed;
  final bool isLogOut;
  const ConfirmationDialog({Key? key, 
    required this.icon, this.title, required this.description, this.adminText, required this.onYesPressed,
    this.onNoPressed, this.isLogOut = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(width: 500, child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Image.asset(icon, width: 50, height: 50),
          ),

          title != null ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: Text(
              title!, textAlign: TextAlign.center,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
            ),
          ) : const SizedBox(),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Text(description, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center),
          ),

          adminText != null && adminText!.isNotEmpty ? Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Text('[$adminText]', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center),
          ) : const SizedBox(),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          GetBuilder<DeliveryManController>(builder: (dmController) {
            return GetBuilder<RestaurantController>(builder: (restController) {
              return GetBuilder<CampaignController>(builder: (campaignController) {
                return GetBuilder<AuthController>(builder: (authController) {
                    return GetBuilder<CouponController>(builder: (couponController) {
                        return GetBuilder<OrderController>(builder: (orderController) {
                          return (couponController.isLoading || authController.isLoading || orderController.isLoading || campaignController.isLoading || restController.isLoading
                          || dmController.isLoading) ? const Center(child: CircularProgressIndicator()) : Row(children: [

                            Expanded(child: TextButton(
                              onPressed: () => isLogOut ? onYesPressed() : onNoPressed != null ? onNoPressed!() : Get.back(),
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).disabledColor.withOpacity(0.3), minimumSize: const Size(1170, 40), padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                              ),
                              child: Text(
                                isLogOut ? 'yes'.tr : 'no'.tr, textAlign: TextAlign.center,
                                style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                              ),
                            )),
                            const SizedBox(width: Dimensions.paddingSizeLarge),

                            Expanded(child: CustomButton(
                              buttonText: isLogOut ? 'no'.tr : 'yes'.tr,
                              onPressed: () => isLogOut ? Get.back() : onYesPressed(),
                              height: 40,
                            )),

                          ]);
                        });
                      }
                    );
                  }
                );
              });
            });
          }),

        ]),
      )),
    );
  }
}