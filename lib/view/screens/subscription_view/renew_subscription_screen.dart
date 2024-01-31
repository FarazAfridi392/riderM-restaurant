import 'package:card_swiper/card_swiper.dart';
import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/package_model.dart';
import 'package:efood_multivendor_restaurant/helper/color_coverter.dart';
import 'package:efood_multivendor_restaurant/helper/custom_print.dart';
import 'package:efood_multivendor_restaurant/helper/price_converter.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_app_bar.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_button.dart';
import 'package:efood_multivendor_restaurant/view/screens/auth/business_plan/widgets/subscription_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RenewSubscriptionScreen extends StatefulWidget {
  const RenewSubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<RenewSubscriptionScreen> createState() => _RenewSubscriptionScreenState();
}

class _RenewSubscriptionScreenState extends State<RenewSubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().getPackageList();
    Get.find<AuthController>().initializeRenew();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'change_subscription_plan'.tr, onBackPressed: (){
        if(Get.find<AuthController>().renewStatus != 'packages') {
          Get.find<AuthController>().renewChangePackage('packages');
        }else{
          Get.back();
        }
       }
      ),
      body: GetBuilder<AuthController>(
        builder: (authController) {
          int activePackageIndex = -1;
          if(authController.packageModel != null){
            for (var element in authController.packageModel!.packages!) {
              if(authController.profileModel!.subscription!.package!.id == element.id){
                activePackageIndex = authController.packageModel!.packages!.indexOf(element);
                customPrint('active package : $activePackageIndex');
              }
            }
          }
          return authController.packageModel != null ? Column(children: [

            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  authController.renewStatus == 'packages' ? SizedBox(
                    height: 600,
                    child: (authController.packageModel!.packages!.isNotEmpty && authController.packageModel!.packages!.isNotEmpty) ? Swiper(
                      itemCount: authController.packageModel!.packages!.length,
                      itemWidth: context.width * 0.8,
                      itemHeight: 600.0,
                      index: activePackageIndex,
                      layout: SwiperLayout.STACK,
                      onIndexChanged: (index){
                        authController.selectSubscriptionCard(index);
                        authController.activePackage(activePackageIndex == index);
                      },
                      itemBuilder: (BuildContext context, int index){
                        Packages package = authController.packageModel!.packages![index];

                        Color color = ColorConverter.stringToColor(package.color);

                        return GetBuilder<AuthController>(
                            builder: (authController) {

                              return Stack(clipBehavior: Clip.none, children: [

                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                                    boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 10)],
                                  ),
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                  margin: const EdgeInsets.only(top: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeExtraSmall),
                                  child: SubscriptionCard(index: index, authController: authController, package: package, color: color),
                                ),

                                authController.activeSubscriptionIndex == index ? Positioned(
                                  top: 5, right: -10,
                                  child: Container(
                                    height: 40, width: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: color, border: Border.all(color: Theme.of(context).cardColor, width: 2),
                                    ),
                                    child: Icon(Icons.check, color: Theme.of(context).cardColor),
                                  ),
                                ) : const SizedBox(),

                              ]);
                            }
                        );
                      },
                    ) : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(Images.emptyBox, height: 150),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          Text('no_package_available'.tr),
                        ]),
                    ),
                  ) : Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Column(children: [
                      refundPaymentCart(
                        title: 'pay_from_restaurant_wallet'.tr,
                        subTitle: '${PriceConverter.convertPrice(authController.profileModel!.balance)} ${'payable_amount_in_your_wallet'.tr}',
                        index: 0,
                        onTap: (){
                          authController.setRefundPaymentIndex(0);
                        },
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      // refundPaymentCart(title: 'pay_manually'.tr, index: 1, onTap: ()=> authController.setPaymentIndex(1)),
                    ]),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.fontSizeLarge, vertical: Dimensions.paddingSizeSmall),
              child: (authController.packageModel!.packages!.isNotEmpty && authController.packageModel!.packages!.isNotEmpty)
                  ? !authController.isLoading ? CustomButton(
                buttonText: (authController.isActivePackage! && activePackageIndex != -1) ? 'renew'.tr : 'shift_this_plan'.tr,
                onPressed: (){
                  if(authController.renewStatus == 'packages') {
                    authController.renewChangePackage('payment');
                  }else{
                    authController.renewBusinessPlan(authController.profileModel!.restaurants![0].id.toString());
                  }
                },
              ) : const Center(child: CircularProgressIndicator()) : const SizedBox(),
            )
          ]) : const Center(child: CircularProgressIndicator());
        }
      ),
    );
  }
  Widget refundPaymentCart({required String title, required String subTitle, required int index, required Function onTap}){
    return GetBuilder<AuthController>(
        builder: (authController) {
          return Stack( clipBehavior: Clip.none, children: [
            InkWell(
              onTap: onTap as void Function()?,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: authController.refundPaymentIndex == index ? Border.all(color: Theme.of(context).primaryColor, width: 1) : null,
                  boxShadow: authController.refundPaymentIndex != index ? [BoxShadow(color: Colors.grey[300]!, blurRadius: 10)] : null,
                  color: authController.refundPaymentIndex == index ? Theme.of(context).primaryColor.withOpacity(0.05) : Theme.of(context).cardColor,
                ),
                alignment: Alignment.center,
                width: context.width,
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      title, style: robotoBold.copyWith(color: authController.refundPaymentIndex == index ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Text(
                      subTitle, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),

                ]),
              ),
            ),

            authController.paymentIndex == index ? Positioned(
              top: -8, right: -8,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                child: Icon(Icons.check, size: 18, color: Theme.of(context).cardColor),
              ),
            ) : const SizedBox(),
          ],
          );
        }
    );
  }
}

