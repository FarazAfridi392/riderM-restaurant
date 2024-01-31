import 'dart:convert';

import 'package:efood_multivendor_restaurant/data/api/api_client.dart';
import 'package:efood_multivendor_restaurant/data/model/response/product_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/profile_model.dart';
import 'package:efood_multivendor_restaurant/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class RestaurantRepo {
  final ApiClient apiClient;
  RestaurantRepo({required this.apiClient});

  Future<Response> getProductList(String offset, String type) async {
    return await apiClient.getData('${AppConstants.productListUri}?offset=$offset&limit=10&type=$type');
  }

  Future<Response> getAttributeList() async {
    return apiClient.getData(AppConstants.attributeUri);
  }

  Future<Response> getCategoryList() async {
    return await apiClient.getData(AppConstants.categoryUri);
  }

  Future<Response> getSubCategoryList(int? parentID) async {
    return await apiClient.getData('${AppConstants.subCategoryUri}$parentID');
  }

  Future<Response> updateRestaurant(Restaurant restaurant, List<String> cuisines, XFile? logo, XFile? cover, String token, List<Translation> translation) async {
    Map<String, String> fields = {};
    fields.addAll(<String, String>{
      '_method': 'put', 'name': restaurant.name!, 'contact_number': restaurant.phone!, 'schedule_order': restaurant.scheduleOrder! ? '1' : '0',
      'address': restaurant.address!, 'minimum_order': restaurant.minimumOrder.toString(), 'delivery': restaurant.delivery! ? '1' : '0',
      'take_away': restaurant.takeAway! ? '1' : '0', 'gst_status': restaurant.gstStatus! ? '1' : '0', 'gst': restaurant.gstCode!,
      'veg': restaurant.veg.toString(), 'non_veg': restaurant.nonVeg.toString(), 'cuisine_ids': jsonEncode(cuisines), 'order_subscription_active': restaurant.orderSubscriptionActive! ? '1' : '0',
      'translations': jsonEncode(translation), 'cutlery': restaurant.cutlery! ? '1' : '0',
    });
    if(restaurant.minimumShippingCharge != null && restaurant.perKmShippingCharge != null && restaurant.maximumShippingCharge != null) {
      fields.addAll(<String, String>{
        'minimum_delivery_charge': restaurant.minimumShippingCharge.toString(),
        'maximum_delivery_charge': restaurant.maximumShippingCharge.toString(),
        'per_km_delivery_charge': restaurant.perKmShippingCharge.toString(),
      });
    }
    return apiClient.postMultipartData(
      AppConstants.restaurantUpdateUri, fields, [MultipartBody('logo', logo), MultipartBody('cover_photo', cover)],
    );
  }

  Future<Response> addProduct(Product product, XFile? image, bool isAdd, String tags) async {
    Map<String, String> fields = {};
    fields.addAll(<String, String>{
      'price': product.price.toString(), 'discount': product.discount.toString(),
      'discount_type': product.discountType!, 'category_id': product.categoryIds![0].id!,
      'available_time_starts': product.availableTimeStarts!,
      'available_time_ends': product.availableTimeEnds!, 'veg': product.veg.toString(),
      'translations': jsonEncode(product.translations), 'tags': tags, 'maximum_cart_quantity': product.maxOrderQuantity.toString(),
      'options': jsonEncode(product.variations),
    });
    String addon = '';
    for(int index=0; index<product.addOns!.length; index++) {
      addon = '$addon${index == 0 ? product.addOns![index].id : ',${product.addOns![index].id}'}';
    }
    fields.addAll(<String, String> {'addon_ids': addon});
    if(product.categoryIds!.length > 1) {
      fields.addAll(<String, String> {'sub_category_id': product.categoryIds![1].id!});
    }
    if(!isAdd) {
      fields.addAll(<String, String> {'_method': 'put', 'id': product.id.toString()});
    }
    return apiClient.postMultipartData(
      isAdd ? AppConstants.addProductUri : AppConstants.updateProductUri, fields, [MultipartBody('image', image)],
    );
  }

  Future<Response> deleteProduct(int? productID) async {
    return await apiClient.deleteData('${AppConstants.deleteProductUri}?id=$productID');
  }

  Future<Response> getRestaurantReviewList(int? restaurantID) async {
    return await apiClient.getData('${AppConstants.restaurantReviewUri}?restaurant_id=$restaurantID');
  }

  Future<Response> getProductReviewList(int? productID) async {
    return await apiClient.getData('${AppConstants.productReviewUri}/$productID');
  }

  Future<Response> updateProductStatus(int? productID, int status) async {
    return await apiClient.getData('${AppConstants.updateProductStatusUri}?id=$productID&status=$status');
  }

  Future<Response> updateRecommendedProductStatus(int? productID, int status) async {
    return await apiClient.getData('${AppConstants.updateProductRecommendedUri}?id=$productID&status=$status');
  }

  Future<Response> addSchedule(Schedules schedule) async {
    return await apiClient.postData(AppConstants.addSchedule, schedule.toJson());
  }

  Future<Response> deleteSchedule(int? scheduleID) async {
    return await apiClient.deleteData('${AppConstants.deleteSchedule}$scheduleID');
  }

  Future<Response> getCuisineList() async {
    return await apiClient.getData(AppConstants.cuisineUri);
  }

  Future<Response> getProductDetails(int productId) async {
    return await apiClient.getData('${AppConstants.productDetailsUri}/$productId');
  }

}