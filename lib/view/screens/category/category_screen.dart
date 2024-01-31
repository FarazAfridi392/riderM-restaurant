import 'package:efood_multivendor_restaurant/controller/restaurant_controller.dart';
import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/category_model.dart';
import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_app_bar.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatelessWidget {
  final CategoryModel? categoryModel;
  const CategoryScreen({Key? key, required this.categoryModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isCategory = categoryModel == null;
    if(isCategory) {
      Get.find<RestaurantController>().getCategoryList(null);
    }else {
      Get.find<RestaurantController>().getSubCategoryList(categoryModel!.id, null);
    }

    return Scaffold(
      appBar: CustomAppBar(title: isCategory ? 'categories'.tr : categoryModel!.name),
      body: GetBuilder<RestaurantController>(builder: (restController) {
        List<CategoryModel>? categories;
        if(isCategory && restController.categoryList != null) {
          categories = [];
          categories.addAll(restController.categoryList!);
        }else if(!isCategory && restController.subCategoryList != null) {
          categories = [];
          categories.addAll(restController.subCategoryList!);
        }
        return categories != null ? categories.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            if(isCategory) {
              await Get.find<RestaurantController>().getCategoryList(null);
            }else {
              await Get.find<RestaurantController>().getSubCategoryList(categoryModel!.id, null);
            }
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  if(isCategory) {
                    Get.toNamed(RouteHelper.getSubCategoriesRoute(categories![index]));
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5)],
                  ),
                  child: Row(children: [

                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: CustomImage(
                        image: '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${categories![index].image}',
                        height: 55, width: 65, fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(categories[index].name!, style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text(
                        '${'id'.tr}: ${categories[index].id}',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      ),
                    ])),

                  ]),
                ),
              );
            },
          ),
        ) : Center(
          child: Text(isCategory ? 'no_category_found'.tr : 'no_subcategory_found'.tr),
        ) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
