import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/restaurant_controller.dart';
import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/product_model.dart';
import 'package:efood_multivendor_restaurant/helper/date_converter.dart';
import 'package:efood_multivendor_restaurant/helper/price_converter.dart';
import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_app_bar.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_button.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_image.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_snackbar.dart';
import 'package:efood_multivendor_restaurant/view/screens/restaurant/widget/review_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool haveSubscription;
    if(Get.find<AuthController>().profileModel!.restaurants![0].restaurantModel == 'subscription'){
      haveSubscription = Get.find<AuthController>().profileModel!.subscription!.review == 1;
    }else{
      haveSubscription = true;
    }
      Get.find<RestaurantController>().setAvailability(product.status == 1);
      Get.find<RestaurantController>().setRecommended(product.recommendedStatus == 1);
    if(Get.find<AuthController>().profileModel!.restaurants![0].reviewsSection!) {
      Get.find<RestaurantController>().getProductReviewList(product.id);
    }
    return Scaffold(
      appBar: CustomAppBar(title: 'food_details'.tr),
      body: SafeArea(
        child: GetBuilder<RestaurantController>(builder: (restController) {
          return Column(children: [

            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              physics: const BouncingScrollPhysics(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: CustomImage(
                      image: '${Get.find<SplashController>().configModel!.baseUrls!.productImageUrl}/${product.image}',
                      height: 70, width: 80, fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      product.name!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${'price'.tr}: ${product.price}', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: robotoRegular,
                    ),
                    Row(children: [
                      Expanded(child: Text(
                        '${'discount'.tr}: ${product.discount} ${product.discountType == 'percent' ? '%'
                            : Get.find<SplashController>().configModel!.currencySymbol}',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: robotoRegular,
                      )),
                      Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Container(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          product.veg == 0 ? 'non_veg'.tr : 'veg'.tr,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white),
                        ),
                      ) : const SizedBox(),
                    ]),
                  ])),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(children: [
                  Text('daily_time'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Expanded(child: Text(
                    '${DateConverter.convertStringTimeToTime(product.availableTimeStarts!)}'
                        ' - ${DateConverter.convertStringTimeToTime(product.availableTimeEnds!)}',
                    maxLines: 1,
                    style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                  )),

                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(children: [
                  Icon(Icons.star, color: Theme.of(context).primaryColor, size: 20),
                  Text(product.avgRating!.toStringAsFixed(1), style: robotoRegular),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Text(
                    '${product.ratingCount} ${'ratings'.tr}',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                ]),

                Row(children: [
                  Expanded(
                    child: Text(
                      'available'.tr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                    ),
                  ),

                  FlutterSwitch(
                    width: 60, height: 30, valueFontSize: Dimensions.fontSizeExtraSmall, showOnOff: true,
                    activeColor: Theme.of(context).primaryColor,
                    value: restController.isAvailable, onToggle: (bool isActive) {
                    restController.toggleAvailable(product.id);
                  }),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(children: [
                  Expanded(
                    child: Text(
                      'recommended'.tr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                    ),
                  ),

                  FlutterSwitch(
                    width: 60, height: 30, valueFontSize: Dimensions.fontSizeExtraSmall, showOnOff: true,
                    activeColor: Theme.of(context).primaryColor,
                    value: restController.isRecommended, onToggle: (bool isActive) {
                    restController.toggleRecommendedProduct(product.id);
                  },
                  ),

                ]),
                const SizedBox(height: Dimensions.paddingSizeLarge),


                (product.variations != null && product.variations!.isNotEmpty) ? Text('variations'.tr, style: robotoMedium) : const SizedBox(),
                SizedBox(height: (product.variations != null && product.variations!.isNotEmpty) ? Dimensions.paddingSizeExtraSmall : 0),
                (product.variations != null && product.variations!.isNotEmpty) ? ListView.builder(
                  itemCount: product.variations!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Row(children: [
                          Text('${product.variations![index].name!} - ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          Text(
                              ' ${product.variations![index].type == 'multi' ? 'multiple_select'.tr : 'single_select'.tr}'
                                  '(${product.variations![index].required == 'off' ? 'required'.tr : 'optional'.tr})',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                        ]),

                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        ListView.builder(
                            itemCount: product.variations![index].variationValues!.length,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(left: 20),
                            shrinkWrap: true,
                            itemBuilder: (context, i){
                          return Text(
                              '${ product.variations![index].variationValues![i].level} - ${ product.variations![index].variationValues![i].optionPrice}',
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                          );
                        }),

                      ]),
                    );
                  },
                ) : const SizedBox(),
                SizedBox(height: (product.variations != null && product.variations!.isNotEmpty) ? Dimensions.paddingSizeLarge : 0),

                product.addOns!.isNotEmpty ? Text('addons'.tr, style: robotoMedium) : const SizedBox(),
                SizedBox(height: product.addOns!.isNotEmpty ? Dimensions.paddingSizeExtraSmall : 0),
                product.addOns!.isNotEmpty ? ListView.builder(
                  itemCount: product.addOns!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Row(children: [

                      Text('${product.addOns![index].name!}:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        PriceConverter.convertPrice(product.addOns![index].price), textDirection: TextDirection.ltr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                      ),

                    ]);
                  },
                ) : const SizedBox(),
                SizedBox(height: product.addOns!.isNotEmpty ? Dimensions.paddingSizeLarge : 0),

                (product.description != null && product.description!.isNotEmpty) ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('description'.tr, style: robotoMedium),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(product.description!, style: robotoRegular),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ) : const SizedBox(),

                product.tags != null && product.tags!.isNotEmpty ? Text('tags'.tr, style: robotoMedium) : const SizedBox(),
                SizedBox(height: product.tags != null && product.tags!.isNotEmpty ? Dimensions.paddingSizeExtraSmall : 0),

                product.tags != null && product.tags!.isNotEmpty ? ListView.builder(
                  itemCount: product.tags!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Text(product.tags![index].tag!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall));
                  },
                ) : const SizedBox(),
                SizedBox(height: product.tags != null && product.tags!.isNotEmpty ? Dimensions.paddingSizeLarge : 0),

                Get.find<AuthController>().profileModel!.restaurants![0].reviewsSection! ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('reviews'.tr, style: robotoMedium),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    haveSubscription ? restController.productReviewList != null ? restController.productReviewList!.isNotEmpty ? ListView.builder(
                      itemCount: restController.productReviewList!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ReviewWidget(
                          review: restController.productReviewList![index], fromRestaurant: false,
                          hasDivider: index != restController.productReviewList!.length-1,
                        );
                      },
                    ) : Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                      child: Center(child: Text('no_review_found'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor))),
                    ) : const Padding(
                      padding: EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                      child: Center(child: CircularProgressIndicator()),
                    ) : Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                      child: Center(child: Text('not_available_subscription_for_reviews'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor))),
                    ),
                  ],
                ) : const SizedBox(),

              ]),
            )),

            !restController.isLoading ? CustomButton(
              onPressed: () {
                if(Get.find<AuthController>().profileModel!.restaurants![0].foodSection!) {
                  restController.getProductDetails(product.id!).then((itemDetails) {
                    if(itemDetails != null){
                      Get.toNamed(RouteHelper.getProductRoute(itemDetails));
                    }
                  });
                }else {
                  showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
                }
              },
              buttonText: 'update_food'.tr,
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ) : const Center(child: CircularProgressIndicator()),

          ]);
        }),
      ),
    );
  }
}
