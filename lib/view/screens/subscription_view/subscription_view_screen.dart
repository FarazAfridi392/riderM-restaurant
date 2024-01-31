import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/helper/date_converter.dart';
import 'package:efood_multivendor_restaurant/helper/price_converter.dart';
import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class SubscriptionViewScreen extends StatefulWidget {
  const SubscriptionViewScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionViewScreen> createState() => _SubscriptionViewScreenState();
}

class _SubscriptionViewScreenState extends State<SubscriptionViewScreen> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();

    if(!Get.find<AuthController>().showSubscriptionAlertDialog ){
      Get.find<AuthController>().showAlert();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: CustomAppBar(title: 'my_subscription'.tr, isBackButtonExist: Get.find<AuthController>().profileModel!.id != null),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
        child: GetBuilder<AuthController>(
          builder: (authController) {
            return authController.profileModel != null ? SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Stack(children: [
                  Column(children: [
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('billing_details'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),

                      (DateConverter.expireDifferanceInDays(DateTime.parse(authController.profileModel!.subscription!.expiryDate!)) <= 10
                      && authController.profileModel!.id != null && Get.find<SplashController>().configModel!.businessPlan!.subscription != 0) ?
                          IconButton(
                            onPressed: () => authController.showAlert(isUpdate: true),
                            icon:  Icon(Icons.error, color: Theme.of(context).primaryColor),
                          )
                          : const SizedBox(),

                    ]),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        color: Theme.of(context).disabledColor.withOpacity(0.05),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeLarge),
                      child: Column(children: [

                        authController.profileModel!.subscription!.status == 1 ? billingCard(
                          logo: Images.billTime, title: 'next_billing_date'.tr,
                          subTitle: DateConverter.localDateToIsoStringAMPM(DateTime.parse(authController.profileModel!.subscription!.expiryDate!)),
                        ) : billingCard(
                          logo: Images.billTime, title: 'package_expired'.tr, titleBig: true, subtitleSmall: true,
                          subTitle: DateConverter.localDateToIsoStringAMPM(DateTime.parse(authController.profileModel!.subscription!.expiryDate!)),
                        ),

                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                        billingCard(
                          logo: Images.bill, title: 'total_bill'.tr,
                          subTitle: (authController.profileModel!.subscriptionOtherData != null && authController.profileModel!.subscriptionOtherData!.totalBill != null)
                              ? PriceConverter.convertPrice(authController.profileModel!.subscriptionOtherData!.totalBill) : '0',
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                        billingCard(logo: Images.subscriptionLogo, title: 'number_of_uses'.tr, subTitle: '${authController.profileModel!.subscription!.totalPackageRenewed! + 1}'),

                      ]),
                    ),
                  ]),

                  (DateConverter.expireDifferanceInDays(DateTime.parse(authController.profileModel!.subscription!.expiryDate!)) <= 10
                  && authController.showSubscriptionAlertDialog && authController.profileModel!.id != null
                  && Get.find<SplashController>().configModel!.businessPlan!.subscription != 0) ? Container(

                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('attention'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).cardColor)),
                        IconButton(
                          onPressed: () => authController.closeAlertDialog(),
                          icon: Icon(Icons.clear, color: Theme.of(context).cardColor),
                        ),
                      ]),
                      Text(
                        '${'attention_text_1'.tr} ${DateConverter.localDateToIsoStringAMPM(DateTime.parse(authController.profileModel!.subscription!.expiryDate!))} ${'attention_text_2'.tr}',
                        style: robotoRegular.copyWith(color: Theme.of(context).cardColor),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ]),
                  ) : const SizedBox(),
                ]),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('subscription_plan'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),

                  DateConverter.expireDifferanceInDays(DateTime.parse(authController.profileModel!.subscription!.expiryDate!)) <= 10
                  && Get.find<SplashController>().configModel!.businessPlan!.subscription != 0 ? ElevatedButton(
                    child: Text('renew_subscription'.tr),
                    onPressed: ()=> Get.toNamed(RouteHelper.getRenewSubscriptionRoute()),
                  ) : const SizedBox(),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(authController.profileModel!.subscription!.package!.packageName!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.blue)),

                      Row(crossAxisAlignment: CrossAxisAlignment.end,children: [
                        Text(
                            '${PriceConverter.convertPrice(authController.profileModel!.subscription!.package!.price)}/',
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge),
                          textDirection: TextDirection.ltr,
                        ),
                        Text(
                          '${authController.profileModel!.subscription!.package!.validity} ${'days'.tr}',
                          style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.5), fontSize: Dimensions.fontSizeDefault),
                        ),
                      ]),
                    ]),

                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    planTile(
                      title1: 'max_order'.tr,
                      title2: ' ${authController.profileModel!.subscription!.maxOrder == 'unlimited' ? '(${authController.profileModel!.subscription!.maxOrder.toString().tr})' : '(${authController.profileModel!.subscription!.maxOrder} ${'left'.tr})'}',
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    planTile(
                      title1: 'max_product'.tr,
                      title2: ' ${authController.profileModel!.subscription!.maxOrder == 'unlimited' ? '(${authController.profileModel!.subscription!.maxProduct.toString().tr})'
                          : '(${authController.profileModel!.subscriptionOtherData != null ? authController.profileModel!.subscriptionOtherData!.maxProductUpload : 0} ${'left'.tr})'}',
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    authController.profileModel!.subscription!.pos == 1 ? planTile(title1: 'pos_access'.tr, title2: '') : const SizedBox(),
                    SizedBox(height: authController.profileModel!.subscription!.pos == 1 ? Dimensions.paddingSizeSmall : 0),

                    authController.profileModel!.subscription!.mobileApp == 1 ? planTile(title1: 'mobile_app_access'.tr, title2: '') : const SizedBox(),
                    SizedBox(height: authController.profileModel!.subscription!.mobileApp == 1 ? Dimensions.paddingSizeSmall : 0),

                    authController.profileModel!.subscription!.chat == 1 ? planTile(title1: 'chat'.tr, title2: '') : const SizedBox(),
                    SizedBox(height: authController.profileModel!.subscription!.chat == 1 ? Dimensions.paddingSizeSmall : 0),

                    authController.profileModel!.subscription!.review == 1 ? planTile(title1: 'review'.tr, title2: '') : const SizedBox(),
                    SizedBox(height: authController.profileModel!.subscription!.review == 1 ? Dimensions.paddingSizeSmall : 0),

                    authController.profileModel!.subscription!.selfDelivery == 1 ? planTile(title1: 'self_delivery'.tr, title2: '') : const SizedBox(),
                    SizedBox(height: authController.profileModel!.subscription!.selfDelivery == 1 ? Dimensions.paddingSizeSmall : 0),

                  ]),
                ),


              ]),
            ) : const Center(child: CircularProgressIndicator());
          }
        ),
      ),
    );
  }


  Widget planTile({required String title1, required String title2}){
    return Row(children: [
      const Icon(Icons.check_circle, size: 22, color: Colors.blue),
      const SizedBox(width: Dimensions.paddingSizeDefault),

      Text(title1, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
      Text(title2, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.5)))
    ]);
  }

  Widget billingCard({required String logo, required String title, required String subTitle, bool titleBig = false, bool subtitleSmall = false}){
    return Row(children: [
      Image.asset(logo, height: 35, width: 35, fit: BoxFit.contain),
      const SizedBox(width: Dimensions.paddingSizeLarge),

      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: robotoMedium.copyWith(
          color: titleBig ? Colors.red : Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.5),
          fontSize: titleBig ? Dimensions.fontSizeExtraLarge : Dimensions.fontSizeSmall),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Text(subTitle, style: robotoBold.copyWith(fontSize: subtitleSmall ? Dimensions.fontSizeSmall : Dimensions.fontSizeExtraLarge)),
      ]),
    ]);
  }
}
