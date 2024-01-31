
import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/helper/responsive_helper.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_button.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentMethodBottomSheet extends StatefulWidget {
  const PaymentMethodBottomSheet({Key? key}) : super(key: key);

  @override
  State<PaymentMethodBottomSheet> createState() => _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {

  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 550,
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        ResponsiveHelper.isDesktop(context) ? Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () => Get.back(),
            child: Container(
              height: 30, width: 30,
              margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.clear),
            ),
          ),
        ) : const SizedBox(),

        Container(
          width: 550,
          height: !ResponsiveHelper.isDesktop(context)
              ? Get.find<SplashController>().configModel!.activePaymentMethodList!.length > 4 ? context.height * 0.8 : context.height * 0.6
              : context.height * 0.55,
          margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
                : const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
          ),
          child: GetBuilder<AuthController>(
              builder: (authController) {
                return Column(
                  children: [
                    !ResponsiveHelper.isDesktop(context) ? Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 4, width: 35,
                        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
                      ),
                    ) : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Align(alignment: Alignment.center, child: Text('payment_method'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                          Row(children: [
                            Text('pay_via_online'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                            Text(
                              '(${'faster_and_secure_way_to_pay_bill'.tr})',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                            ),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          ListView.builder(
                              itemCount: Get.find<SplashController>().configModel!.activePaymentMethodList!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index){
                                bool isSelected = authController.paymentIndex == 1 && Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == authController.digitalPaymentName;
                                return InkWell(
                                  onTap: (){
                                    authController.setPaymentIndex(1);
                                    authController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                                    child: Row(children: [
                                      Container(
                                        height: 20, width: 20,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                            border: Border.all(color: Theme.of(context).disabledColor)
                                        ),
                                        child: Icon(Icons.check, color: Theme.of(context).cardColor, size: 16),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeDefault),

                                      CustomImage(
                                        height: 20, fit: BoxFit.contain,
                                        image: '${Get.find<SplashController>().configModel!.baseUrls!.gatewayImageUrl}/${Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImage!}',
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),

                                      Text(
                                        Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayTitle!,
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                                      ),
                                    ]),
                                  ),
                                );
                              }),

                          const SizedBox(height: Dimensions.paddingSizeSmall),

                        ]),
                      ),
                    ),

                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                        child: CustomButton(
                          buttonText: 'select'.tr,
                          onPressed: () => Get.back(),
                        ),
                      ),
                    ),
                  ],
                );
              }
          ),
        ),
      ]),
    );
  }
}
