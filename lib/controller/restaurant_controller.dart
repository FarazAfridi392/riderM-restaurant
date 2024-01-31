import 'package:efood_multivendor_restaurant/controller/addon_controller.dart';
import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/data/api/api_checker.dart';
import 'package:efood_multivendor_restaurant/data/model/body/variation_model_body.dart';
import 'package:efood_multivendor_restaurant/data/model/response/category_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/cuisine_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/product_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/profile_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/review_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/variant_type_model.dart';
import 'package:efood_multivendor_restaurant/data/repository/restaurant_repo.dart';
import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class RestaurantController extends GetxController implements GetxService {
  final RestaurantRepo restaurantRepo;
  RestaurantController({required this.restaurantRepo});

  List<Product>? _productList;
  List<ReviewModel>? _restaurantReviewList;
  List<ReviewModel>? _productReviewList;
  bool _isLoading = false;
  int? _pageSize;
  List<String> _offsetList = [];
  int _offset = 1;
  int _discountTypeIndex = 0;
  List<CategoryModel>? _categoryList;
  List<CategoryModel>? _subCategoryList;
  XFile? _pickedLogo;
  XFile? _pickedCover;
  int? _categoryIndex = 0;
  int? _subCategoryIndex = 0;
  List<int>? _selectedAddons;
  List<VariantTypeModel>? _variantTypeList;
  bool _isAvailable = true;
  bool _isRecommended = true;
  List<Schedules>? _scheduleList;
  bool _scheduleLoading = false;
  bool? _isGstEnabled;
  List<int?> _categoryIds = [];
  List<int?> _subCategoryIds = [];
  int _tabIndex = 0;
  bool _isVeg = false;
  bool? _isRestVeg = true;
  bool? _isRestNonVeg = true;
  String _type = 'all';
  static final List<String> _productTypeList = ['all', 'veg', 'non_veg'];
  List<VariationModelBody>? _variationList;
  List<String?> _tagList = [];
  CuisineModel? _cuisineModel;
  List<int>? _selectedCuisines;
  Product? _product;

  List<Product>? get productList => _productList;
  List<ReviewModel>? get restaurantReviewList => _restaurantReviewList;
  List<ReviewModel>? get productReviewList => _productReviewList;
  bool get isLoading => _isLoading;
  int? get pageSize => _pageSize;
  int get offset => _offset;
  int get discountTypeIndex => _discountTypeIndex;
  List<CategoryModel>? get categoryList => _categoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;
  XFile? get pickedLogo => _pickedLogo;
  XFile? get pickedCover => _pickedCover;
  int? get categoryIndex => _categoryIndex;
  int? get subCategoryIndex => _subCategoryIndex;
  List<int>? get selectedAddons => _selectedAddons;
  List<VariantTypeModel>? get variantTypeList => _variantTypeList;
  bool get isAvailable => _isAvailable;
  List<Schedules>? get scheduleList => _scheduleList;
  bool get scheduleLoading => _scheduleLoading;
  bool? get isGstEnabled => _isGstEnabled;
  List<int?> get categoryIds => _categoryIds;
  List<int?> get subCategoryIds => _subCategoryIds;
  int get tabIndex => _tabIndex;
  bool get isVeg => _isVeg;
  bool? get isRestVeg => _isRestVeg;
  bool? get isRestNonVeg => _isRestNonVeg;
  String get type => _type;
  List<String> get productTypeList => _productTypeList;

  List<VariationModelBody>? get variationList => _variationList;
  List<String?> get tagList => _tagList;
  bool get isRecommended => _isRecommended;
  CuisineModel? get cuisineModel => _cuisineModel;
  List<int>? get selectedCuisines => _selectedCuisines;
  Product? get product => _product;

  void initRestaurantData(Restaurant restaurant) {
    _pickedLogo = null;
    _pickedCover = null;
    _isGstEnabled = restaurant.gstStatus;
    _scheduleList = [];
    _scheduleList!.addAll(restaurant.schedules!);
    _isRestVeg = restaurant.veg == 1;
    _isRestNonVeg = restaurant.nonVeg == 1;
    getCuisineList(restaurant.cuisines);
  }

  Future<void> getCuisineList(List<Cuisine>? cuisines) async {
    _selectedCuisines = [];
    Response response = await restaurantRepo.getCuisineList();
    if (response.statusCode == 200) {
      _cuisineModel = CuisineModel.fromJson(response.body);
      for (var modelCuisine in _cuisineModel!.cuisines!) {
        for(Cuisine cuisine in cuisines!){
          if(modelCuisine.id == cuisine.id){
            _selectedCuisines!.add(_cuisineModel!.cuisines!.indexOf(modelCuisine));
          }
        }
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void setSelectedCuisineIndex(int index, bool notify) {
    if(!_selectedCuisines!.contains(index)) {
      _selectedCuisines!.add(index);
      if(notify) {
        update();
      }
    }
  }

  void removeCuisine(int index) {
    _selectedCuisines!.removeAt(index);
    update();
  }

  void setTag(String? name, {bool isUpdate = true}){
    _tagList.add(name);
    if(isUpdate) {
      update();
    }
  }

  void initializeTags(){
    _tagList = [];
  }

  void removeTag(int index){
    _tagList.removeAt(index);
    update();
  }

  void setEmptyVariationList(){
    _variationList = [];
  }
  void setExistingVariation(List<Variation>? variationList){
    _variationList = [];
    if(variationList != null && variationList.isNotEmpty) {
      for (var variation in variationList) {
        List<Option> options = [];

        for (var option in variation.variationValues!) {
          options.add(Option(
              optionNameController: TextEditingController(text: option.level),
              optionPriceController: TextEditingController(text: option.optionPrice)),
          );
        }

        _variationList!.add(VariationModelBody(
            nameController: TextEditingController(text: variation.name),
            isSingle: variation.type == 'single' ? true : false,
            minController: TextEditingController(text: variation.min),
            maxController: TextEditingController(text: variation.max),
            required: variation.required == 'on' ? true : false,
            options: options),
        );
      }
    }
  }

  void changeSelectVariationType(int index){
    _variationList![index].isSingle = !_variationList![index].isSingle;
    update();
  }

  void setVariationRequired(int index){
    _variationList![index].required = !_variationList![index].required;
    update();
  }

  void addVariation(){
    _variationList!.add(VariationModelBody(
      nameController: TextEditingController(), required: false, isSingle: true, maxController: TextEditingController(), minController: TextEditingController(),
        options: [Option(optionNameController: TextEditingController(), optionPriceController: TextEditingController())],
    ));
    update();
  }

  void removeVariation(int index){
    _variationList!.removeAt(index);
    update();
  }

  void addOptionVariation(int index){
    _variationList![index].options!.add(Option(optionNameController: TextEditingController(), optionPriceController: TextEditingController()));
    update();
  }

  void removeOptionVariation(int vIndex, int oIndex){
    _variationList![vIndex].options!.removeAt(oIndex);
    update();
  }

  Future<void> getProductList(String offset, String type) async {
    if(offset == '1') {
      _offsetList = [];
      _offset = 1;
      _type = type;
      _productList = null;
      update();
    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      Response response = await restaurantRepo.getProductList(offset, type);
      if (response.statusCode == 200) {
        if (offset == '1') {
          _productList = [];
        }
        _productList!.addAll(ProductModel.fromJson(response.body).products!);
        _pageSize = ProductModel.fromJson(response.body).totalSize;
        _isLoading = false;
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      if(isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void setOffset(int offset) {
    _offset = offset;
  }

  void getAttributeList(Product? product) async {
    _discountTypeIndex = 0;
    _categoryIndex = 0;
    _subCategoryIndex = 0;
    _pickedLogo = null;
    _selectedAddons = [];
    _variantTypeList = [];
    List<int?> addonsIds = await Get.find<AddonController>().getAddonList();
    if(product != null && product.addOns != null) {
      for(int index=0; index<product.addOns!.length; index++) {
        setSelectedAddonIndex(addonsIds.indexOf(product.addOns![index].id), false);
      }
    }
    await getCategoryList(product);
  }

  void setDiscountTypeIndex(int index, bool notify) {
    _discountTypeIndex = index;
    if(notify) {
      update();
    }
  }

  Future<void> getCategoryList(Product? product) async {
    _categoryIds = [];
    _subCategoryIds = [];
    _categoryIds.add(0);
    _subCategoryIds.add(0);
    Response response = await restaurantRepo.getCategoryList();
    if (response.statusCode == 200) {
      _categoryList = [];
      response.body.forEach((category) => _categoryList!.add(CategoryModel.fromJson(category)));
      if(_categoryList != null) {
        for(int index=0; index<_categoryList!.length; index++) {
          _categoryIds.add(_categoryList![index].id);
        }
        if(product != null) {
          setCategoryIndex(_categoryIds.indexOf(int.parse(product.categoryIds![0].id!)), false);
          await getSubCategoryList(int.parse(product.categoryIds![0].id!), product);
        }
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getSubCategoryList(int? categoryID, Product? product) async {
    _subCategoryIndex = 0;
    _subCategoryList = [];
    _subCategoryIds = [];
    _subCategoryIds.add(0);
    if(categoryID != 0) {
      Response response = await restaurantRepo.getSubCategoryList(categoryID);
      if (response.statusCode == 200) {
        _subCategoryList = [];
        response.body.forEach((category) => _subCategoryList!.add(CategoryModel.fromJson(category)));
        if(_subCategoryList != null) {
          for(int index=0; index<_subCategoryList!.length; index++) {
            _subCategoryIds.add(_subCategoryList![index].id);
          }
          if(product != null && product.categoryIds!.length > 1) {
            setSubCategoryIndex(_subCategoryIds.indexOf(int.parse(product.categoryIds![1].id!)), false);
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    }
    update();
  }

  Future<void> updateRestaurant(Restaurant restaurant, List<String> cuisines, String token,List<Translation> translation) async {
    _isLoading = true;
    update();
    Response response = await restaurantRepo.updateRestaurant(restaurant, cuisines, _pickedLogo, _pickedCover, token, translation);
    if(response.statusCode == 200) {
      Get.back();
      Get.find<AuthController>().getProfile();
      showCustomSnackBar('restaurant_settings_updated_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  void pickImage(bool isLogo, bool isRemove) async {
    if(isRemove) {
      _pickedLogo = null;
      _pickedCover = null;
    }else {
      if (isLogo) {
        _pickedLogo = await ImagePicker().pickImage(source: ImageSource.gallery);
      } else {
        _pickedCover = await ImagePicker().pickImage(source: ImageSource.gallery);
      }
      update();
    }
  }

  void setCategoryIndex(int? index, bool notify) {
    _categoryIndex = index;
    if(notify) {
      update();
    }
  }

  void setSubCategoryIndex(int? index, bool notify) {
    _subCategoryIndex = index;
    if(notify) {
      update();
    }
  }

  void setSelectedAddonIndex(int index, bool notify) {
    if(!_selectedAddons!.contains(index)) {
      _selectedAddons!.add(index);
      if(notify) {
        update();
      }
    }
  }

  void removeAddon(int index) {
    _selectedAddons!.removeAt(index);
    update();
  }

  Future<void> addProduct(Product product, bool isAdd) async {
    _isLoading = true;
    update();

    String tags = '';
    for (var element in _tagList) {
      tags = tags + (tags.isEmpty ? '' : ',') + element!.replaceAll(' ', '');
    }

    Response response = await restaurantRepo.addProduct(product, _pickedLogo, isAdd, tags);
    if(response.statusCode == 200) {
      Get.offAllNamed(RouteHelper.getInitialRoute());
      showCustomSnackBar(isAdd ? 'product_added_successfully'.tr : 'product_updated_successfully'.tr, isError: false);
      getProductList('1', 'all');
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> deleteProduct(int? productID) async {
    _isLoading = true;
    update();
    Response response = await restaurantRepo.deleteProduct(productID);
    if(response.statusCode == 200) {
      Get.back();
      showCustomSnackBar('product_deleted_successfully'.tr, isError: false);
      getProductList('1', 'all');
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> getRestaurantReviewList(int? restaurantID) async {
    _tabIndex = 0;
    Response response = await restaurantRepo.getRestaurantReviewList(restaurantID);
    if(response.statusCode == 200) {
      _restaurantReviewList = [];
      response.body.forEach((review) => _restaurantReviewList!.add(ReviewModel.fromJson(review)));
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getProductReviewList(int? productID) async {
    _productReviewList = null;
    Response response = await restaurantRepo.getProductReviewList(productID);
    if(response.statusCode == 200) {
      _productReviewList = [];
      response.body.forEach((review) => _productReviewList!.add(ReviewModel.fromJson(review)));
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void setAvailability(bool isAvailable) {
    _isAvailable = isAvailable;
  }

  void toggleAvailable(int? productID) async {
    Response response = await restaurantRepo.updateProductStatus(productID, _isAvailable ? 0 : 1);
    if(response.statusCode == 200) {
      getProductList('1', 'all');
      _isAvailable = !_isAvailable;
      showCustomSnackBar('food_status_updated_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void setRecommended(bool isRecommended) {
    _isRecommended = isRecommended;
  }

  void toggleRecommendedProduct(int? productID) async {
    Response response = await restaurantRepo.updateRecommendedProductStatus(productID, _isRecommended ? 0 : 1);
    if(response.statusCode == 200) {
      getProductList('1', 'all');
      _isRecommended = !_isRecommended;
      showCustomSnackBar('food_status_updated_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void toggleGst() {
    _isGstEnabled = !_isGstEnabled!;
    update();
  }

  Future<void> addSchedule(Schedules schedule) async {
    schedule.openingTime = '${schedule.openingTime!}:00';
    schedule.closingTime = '${schedule.closingTime!}:00';
    _scheduleLoading = true;
    update();
    Response response = await restaurantRepo.addSchedule(schedule);
    if(response.statusCode == 200) {
      schedule.id = int.parse(response.body['id'].toString());
      _scheduleList!.add(schedule);
      Get.back();
      showCustomSnackBar('schedule_added_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _scheduleLoading = false;
    update();
  }

  Future<void> deleteSchedule(int? scheduleID) async {
    _scheduleLoading = true;
    update();
    Response response = await restaurantRepo.deleteSchedule(scheduleID);
    if(response.statusCode == 200) {
      _scheduleList!.removeWhere((schedule) => schedule.id == scheduleID);
      Get.back();
      showCustomSnackBar('schedule_removed_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _scheduleLoading = false;
    update();
  }

  void setTabIndex(int index) {
    bool notify = true;
    if(_tabIndex == index) {
      notify = false;
    }
    _tabIndex = index;
    if(notify) {
      update();
    }
  }

  void setVeg(bool isVeg, bool notify) {
    _isVeg = isVeg;
    if(notify) {
      update();
    }
  }

  void setRestVeg(bool? isVeg, bool notify) {
    _isRestVeg = isVeg;
    if(notify) {
      update();
    }
  }

  void setRestNonVeg(bool? isNonVeg, bool notify) {
    _isRestNonVeg = isNonVeg;
    if(notify) {
      update();
    }
  }

  Future<Product?> getProductDetails(int productId) async {
    _isLoading = true;
    update();
    Response response = await restaurantRepo.getProductDetails(productId);
    if (response.statusCode == 200) {
      _product = Product.fromJson(response.body);
      if(_product?.translations == null || _product!.translations!.isEmpty) {
        _product!.translations = [];
        _product!.translations!.add(Translation(
          locale: Get.find<SplashController>().configModel!.language!.first.key,
          key: 'name', value: _product!.name,
        ));
        _product!.translations!.add(Translation(
          locale: Get.find<SplashController>().configModel!.language!.first.key,
          key: 'description', value: _product!.description,
        ));
      }
      _isLoading = false;
      update();
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
    return _product;
  }

}