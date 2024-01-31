import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/restaurant_controller.dart';
import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/config_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/product_model.dart';
import 'package:efood_multivendor_restaurant/helper/date_converter.dart';
import 'package:efood_multivendor_restaurant/helper/price_converter.dart';
import 'package:efood_multivendor_restaurant/helper/responsive_helper.dart';
import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/confirmation_dialog.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_image.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_snackbar.dart';
import 'package:efood_multivendor_restaurant/view/base/discount_tag.dart';
import 'package:efood_multivendor_restaurant/view/base/not_available_widget.dart';
import 'package:efood_multivendor_restaurant/view/base/rating_bar.dart';
import 'package:efood_multivendor_restaurant/view/screens/restaurant/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductWidget extends StatelessWidget {
  final Product product;
  final int index;
  final int length;
  final bool inRestaurant;
  final bool isCampaign;
  const ProductWidget({Key? key, required this.product, required this.index,
   required this.length, this.inRestaurant = false, this.isCampaign = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BaseUrls? baseUrls = Get.find<SplashController>().configModel!.baseUrls;
    bool desktop = ResponsiveHelper.isDesktop(context);
    double? discount;
    String? discountType;
    bool isAvailable;
    discount = (product.restaurantDiscount == 0 || isCampaign) ? product.discount : product.restaurantDiscount;
    discountType = (product.restaurantDiscount == 0 || isCampaign) ? product.discountType : 'percent';
    isAvailable = DateConverter.isAvailable(product.availableTimeStarts, product.availableTimeEnds)
        && DateConverter.isAvailable(product.restaurantOpeningTime, product.restaurantClosingTime);


    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.getProductDetailsRoute(product), arguments: ProductDetailsScreen(product: product)),
      child: Container(
        padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.all(Dimensions.paddingSizeSmall) : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).cardColor : null,
          boxShadow: ResponsiveHelper.isDesktop(context) ? [BoxShadow(
            color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5,
          )] : null,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

          Expanded(child: Padding(
            padding: EdgeInsets.symmetric(vertical: desktop ? 0 : Dimensions.paddingSizeExtraSmall),
            child: Row(children: [

              (product.image != null && product.image!.isNotEmpty) ? Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: CustomImage(
                    image: '${isCampaign ? baseUrls!.campaignImageUrl : baseUrls!.productImageUrl}/${product.image}',
                    height: desktop ? 120 : 65, width: desktop ? 120 : 80, fit: BoxFit.cover,
                  ),
                ),
                DiscountTag(
                  discount: discount, discountType: discountType,
                  freeDelivery: false,
                ),
                isAvailable ? const SizedBox() : const NotAvailableWidget(isRestaurant: false),
              ]) : const SizedBox(),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                  Text(
                    product.name!,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                    maxLines: desktop ? 2 : 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  RatingBar(
                    rating: product.avgRating, size: desktop ? 15 : 12,
                    ratingCount: product.ratingCount,
                  ),

                  Row(children: [

                    Text(
                      PriceConverter.convertPrice(product.price, discount: discount, discountType: discountType),
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr,
                    ),

                    SizedBox(width: discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                    discount > 0 ? Text(
                      PriceConverter.convertPrice(product.price), textDirection: TextDirection.ltr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).disabledColor,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ) : const SizedBox(),

                    (product.image != null && product.image!.isNotEmpty) ? const SizedBox()
                        :  Text(
                      '(${discount > 0 ? '$discount${discountType == 'percent' ? '%' : Get.find<SplashController>().configModel!.currencySymbol}${'off'.tr}' : 'free_delivery'.tr})',
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: ResponsiveHelper.isMobile(context) ? 8 : 12),
                      textAlign: TextAlign.center,
                    ),

                  ]),

                ]),
              ),

              // IconButton(
              //   onPressed: () {
              //     if(Get.find<AuthController>().profileModel!.restaurants![0].foodSection!) {
              //       Get.find<RestaurantController>().getProductDetails(product.id!).then((itemDetails) {
              //         if(itemDetails != null){
              //           Get.toNamed(RouteHelper.getProductRoute(itemDetails));
              //         }
              //       });
              //     }else {
              //       showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
              //     }
              //   },
              //   icon: const Icon(Icons.edit, color: Colors.blue),
              // ),
              IconButton(
                onPressed: () {
                  if (Get.find<AuthController>()
                      .profileModel!
                      .restaurants![0]
                      .foodSection ?? false) {
                    Get.toNamed(RouteHelper.getProductRoute(product));
                  } else {
                    showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
                  }
                },
                icon: Icon(Icons.edit, color: Colors.blue),
              ),

              IconButton(
                onPressed: () {
                  if(Get.find<AuthController>().profileModel!.restaurants![0].foodSection!) {
                    Get.dialog(ConfirmationDialog(
                      icon: Images.warning, description: 'are_you_sure_want_to_delete_this_product'.tr,
                      onYesPressed: () => Get.find<RestaurantController>().deleteProduct(product.id),
                    ));
                  }else {
                    showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
                  }
                },
                icon: const Icon(Icons.delete_forever, color: Colors.red),
              ),

            ]),
          )),

          desktop ? const SizedBox() : Padding(
            padding: EdgeInsets.only(left: desktop ? 130 : 90),
            child: Divider(color: index == length-1 ? Colors.transparent : Theme.of(context).disabledColor),
          ),

        ]),
      ),
    );
  }
}
