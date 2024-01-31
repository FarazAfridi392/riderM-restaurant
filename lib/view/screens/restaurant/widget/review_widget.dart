import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/review_model.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_image.dart';
import 'package:efood_multivendor_restaurant/view/base/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewWidget extends StatelessWidget {
  final ReviewModel review;
  final bool hasDivider;
  final bool fromRestaurant;
  const ReviewWidget({Key? key, required this.review, required this.hasDivider, required this.fromRestaurant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [

      Row(children: [

        ClipOval(
          child: CustomImage(
            image: '${fromRestaurant ? Get.find<SplashController>().configModel!.baseUrls!.productImageUrl
                : Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}/${fromRestaurant
                ? review.foodImage : review.customer != null ? review.customer!.image : ''}',
            height: 60, width: 60, fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

          Text(
            fromRestaurant ? review.foodName! : review.customer != null ? '${review.customer != null ? review.customer!.fName : ''} ${review.customer
                != null ? review.customer!.lName : ''}' : 'customer_not_found'.tr,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: review.customer != null ? Theme.of(context).textTheme.displayLarge!.backgroundColor : Theme.of(context).disabledColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          RatingBar(rating: review.rating!.toDouble(), ratingCount: null, size: 15),

          fromRestaurant ? Text(
            review.customerName != null ? review.customerName! : 'customer_not_found'.tr,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: review.customer != null ? Theme.of(context).textTheme.displayLarge as Color? : Theme.of(context).disabledColor),
          ) : const SizedBox(),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Text(review.comment!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),

        ])),

      ]),

      hasDivider ? Padding(
        padding: const EdgeInsets.only(left: 70),
        child: Divider(color: Theme.of(context).disabledColor),
      ) : const SizedBox(),

    ]);
  }
}
