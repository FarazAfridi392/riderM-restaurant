import 'dart:io';
import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/restaurant_controller.dart';
import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/config_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/product_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/profile_model.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_app_bar.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_button.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_snackbar.dart';
import 'package:efood_multivendor_restaurant/view/base/my_text_field.dart';
import 'package:efood_multivendor_restaurant/view/base/switch_button.dart';
import 'package:efood_multivendor_restaurant/view/screens/restaurant/widget/daily_time_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantSettingsScreen extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantSettingsScreen({Key? key, required this.restaurant}) : super(key: key);

  @override
  State<RestaurantSettingsScreen> createState() => _RestaurantSettingsScreenState();
}

class _RestaurantSettingsScreenState extends State<RestaurantSettingsScreen> {
  final List<TextEditingController> _nameController = [];
  final TextEditingController _contactController = TextEditingController();
  final List<TextEditingController> _addressController = [];
  final TextEditingController _orderAmountController = TextEditingController();
  final TextEditingController _minimumChargeController = TextEditingController();
  final TextEditingController _maximumChargeController = TextEditingController();
  final TextEditingController _perKmChargeController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  TextEditingController _c = TextEditingController();
  final List<TextEditingController> _metaTitleController = [];
  final List<TextEditingController> _metaDescriptionController = [];
  final List<FocusNode> _nameNode = [];
  final FocusNode _contactNode = FocusNode();
  final List<FocusNode> _addressNode = [];
  final FocusNode _orderAmountNode = FocusNode();
  final FocusNode _minimumChargeNode = FocusNode();
  final FocusNode _maximumChargeNode = FocusNode();
  final FocusNode _perKmChargeNode = FocusNode();
  final List<FocusNode> _metaTitleNode = [];
  final List<FocusNode> _metaDescriptionNode = [];
  final FocusNode _metaKeyWordNode = FocusNode();
  late Restaurant _restaurant;
  final List<Language>? _languageList = Get.find<SplashController>().configModel!.language;
  final List<Translation> translation = Get.find<AuthController>().profileModel!.translations ?? [];

  @override
  void initState() {
    super.initState();

    Get.find<RestaurantController>().initRestaurantData(widget.restaurant);

    for(int index=0; index<_languageList!.length; index++) {

      _nameController.add(TextEditingController());
      _addressController.add(TextEditingController());
      _metaTitleController.add(TextEditingController());
      _metaDescriptionController.add(TextEditingController());
      _nameNode.add(FocusNode());
      _addressNode.add(FocusNode());
      _metaTitleNode.add(FocusNode());
      _metaDescriptionNode.add(FocusNode());

      for (var trans in translation!) {
        if(_languageList![index].key == trans.locale && trans.key == 'name') {
          _nameController[index] = TextEditingController(text: trans.value);
        }else if(_languageList![index].key == trans.locale && trans.key == 'address') {
          _addressController[index] = TextEditingController(text: trans.value);
        }else if (_languageList![index].key == trans.locale && trans.key == 'meta_title') {
          _metaTitleController[index] = TextEditingController(text: trans.value);
        }  else if (_languageList![index].key == trans.locale && trans.key == 'meta_description') {
          _metaDescriptionController[index] = TextEditingController(text: trans.value);

        }
      }
    }

    // _nameController.text = widget.restaurant.name!;
    // _addressController.text = widget.restaurant.address!;
    _contactController.text = widget.restaurant.phone!;
    _orderAmountController.text = widget.restaurant.minimumOrder.toString();
    _minimumChargeController.text = widget.restaurant.minimumShippingCharge != null ? widget.restaurant.minimumShippingCharge.toString() : '';
    _maximumChargeController.text = widget.restaurant.maximumShippingCharge != null ? widget.restaurant.maximumShippingCharge.toString() : '';
    _perKmChargeController.text = widget.restaurant.perKmShippingCharge != null ? widget.restaurant.perKmShippingCharge.toString() : '';
    _gstController.text = widget.restaurant.gstCode!;
    _restaurant = widget.restaurant;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'restaurant_settings'.tr),
      body: GetBuilder<RestaurantController>(builder: (restController) {

        List<int> cuisines0 = [];
        if(restController.cuisineModel != null) {
          for(int index=0; index<restController.cuisineModel!.cuisines!.length; index++) {
            if(restController.cuisineModel!.cuisines![index].status == 1 && !restController.selectedCuisines!.contains(index)) {
              cuisines0.add(index);
            }
          }
        }
        return Column(children: [

          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            physics: const BouncingScrollPhysics(),
            child: Column(children: [

              Text(
                'logo'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Align(alignment: Alignment.center, child: Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: restController.pickedLogo != null ? GetPlatform.isWeb ? Image.network(
                    restController.pickedLogo!.path, width: 150, height: 120, fit: BoxFit.cover,
                  ) : Image.file(
                    File(restController.pickedLogo!.path), width: 150, height: 120, fit: BoxFit.cover,
                  ) : FadeInImage.assetNetwork(
                    placeholder: Images.placeholder,
                    image: '${Get.find<SplashController>().configModel!.baseUrls!.restaurantImageUrl}/${widget.restaurant.logo}',
                    height: 120, width: 150, fit: BoxFit.cover,
                    imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder, height: 120, width: 150, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0, top: 0, left: 0,
                  child: InkWell(
                    onTap: () => restController.pickImage(true, false),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.white),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ])),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              ListView.builder(
                  itemCount: _languageList!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                      child: MyTextField(
                        hintText: '${'restaurant_name'.tr} (${_languageList![index].value!})',
                        controller: _nameController[index],
                        focusNode: _nameNode[index],
                        nextFocus: index != _languageList!.length-1 ? _nameNode[index+1] : _contactNode,
                        capitalization: TextCapitalization.words,
                        inputType: TextInputType.name,
                      ),
                    );
                  }
              ),

              MyTextField(
                hintText: 'contact_number'.tr,
                controller: _contactController,
                focusNode: _contactNode,
                nextFocus: _addressNode[0],
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // MyTextField(
              //   hintText: 'address'.tr,
              //   controller: _addressController,
              //   focusNode: _addressNode,
              //   nextFocus: _orderAmountNode,
              //   inputType: TextInputType.streetAddress,
              // ),
              // const SizedBox(height: Dimensions.paddingSizeLarge),


              ListView.builder(
                  itemCount: _languageList!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraLarge),
                      child: MyTextField(
                        hintText: '${'address'.tr} (${_languageList![index].value!})',
                        controller: _addressController[index],
                        focusNode: _addressNode[index],
                        nextFocus: index != _languageList!.length-1 ? _addressNode[index+1] : _orderAmountNode,
                        inputType: TextInputType.streetAddress,
                      ),
                    );
                  }
              ),

              Row(children: [
                Expanded(
                  child: MyTextField(
                    hintText: 'minimum_order_amount'.tr,
                    controller: _orderAmountController,
                    focusNode: _orderAmountNode,
                    nextFocus: _restaurant.selfDeliverySystem == 1 ? _perKmChargeNode : null,
                    inputAction: _restaurant.selfDeliverySystem == 0 ? null : TextInputAction.done,
                    inputType: TextInputType.number,
                    isAmount: true,
                  ),
                ),
                SizedBox(width: _restaurant.selfDeliverySystem == 1 ? Dimensions.paddingSizeSmall : 0),

                _restaurant.selfDeliverySystem == 1 ? Expanded(
                  child: MyTextField(
                    hintText: 'per_km_delivery_charge'.tr,
                    controller: _perKmChargeController,
                    focusNode: _restaurant.selfDeliverySystem == 1 ? _perKmChargeNode : null,
                    nextFocus: _restaurant.selfDeliverySystem == 1 ? _minimumChargeNode : null,
                    inputType: TextInputType.number,
                    isAmount: true,
                  ),
                ) : const SizedBox(),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              _restaurant.selfDeliverySystem == 1 ? Row(children: [
                Expanded(child: MyTextField(
                  hintText: 'minimum_delivery_charge'.tr,
                  controller: _minimumChargeController,
                  focusNode: _minimumChargeNode,
                  nextFocus: _maximumChargeNode,
                  inputType: TextInputType.number,
                  isAmount: true,
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: MyTextField(
                  hintText: 'maximum_delivery_charge'.tr,
                  controller: _maximumChargeController,
                  focusNode: _maximumChargeNode,
                  inputAction: TextInputAction.done,
                  inputType: TextInputType.number,
                  isAmount: true,
                )),
              ]) : const SizedBox(),
              SizedBox(height: _restaurant.selfDeliverySystem == 1 ? Dimensions.paddingSizeLarge : 0),

              ListView.builder(
                  itemCount: _languageList!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                      child: MyTextField(
                        hintText:  '${'meta_title'.tr}  (${_languageList![index].value!})',
                        controller: _metaTitleController[index],
                        focusNode: _metaTitleNode[index],
                        nextFocus: index != _languageList!.length-1 ? _metaTitleNode[index+1] : _metaDescriptionNode[0],
                        capitalization: TextCapitalization.words,
                        inputType: TextInputType.name,
                      ),
                    );
                  }
              ),

              ListView.builder(
                  itemCount: _languageList!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                      child: MyTextField(
                        hintText:  '${'meta_description'.tr}  (${_languageList![index].value!})',
                        controller: _metaDescriptionController[index],
                        focusNode: _metaDescriptionNode[index],
                        nextFocus: index != _languageList!.length-1 ? _metaDescriptionNode[index+1] : _metaKeyWordNode,
                        capitalization: TextCapitalization.words,
                        inputType: TextInputType.name,
                      ),
                    );
                  }
              ),

              // MyTextField(
              //   hintText: 'meta_key_word'.tr,
              //   controller: _metaKeywordController,
              //   focusNode: _metaKeyWordNode,
              //   inputAction: TextInputAction.done,
              // ),
              // const SizedBox(height: Dimensions.paddingSizeLarge),

              Column(children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'cuisines'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Autocomplete<int>(
                  optionsBuilder: (TextEditingValue value) {
                    if(value.text.isEmpty) {
                      return const Iterable<int>.empty();
                    }else {
                      return cuisines0.where((cuisine) => restController.cuisineModel!.cuisines![cuisine].name!.toLowerCase().contains(value.text.toLowerCase()));
                    }
                  },
                  fieldViewBuilder: (context, controller, node, onComplete) {
                    _c = controller;
                    return Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        // boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 2, blurRadius: 5, offset: Offset(0, 5))],
                      ),
                      child: TextField(
                        controller: controller,
                        focusNode: node,
                        onEditingComplete: () {
                          onComplete();
                          controller.text = '';
                        },
                        decoration: InputDecoration(
                          hintText: 'cuisines'.tr,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), borderSide: BorderSide.none),
                        ),
                      ),
                    );
                  },
                  displayStringForOption: (value) => restController.cuisineModel!.cuisines![value].name!,
                  onSelected: (int value) {
                    _c.text = '';
                    restController.setSelectedCuisineIndex(value, true);
                  },
                ),

                SizedBox(height: restController.selectedCuisines!.isNotEmpty ? Dimensions.paddingSizeSmall : 0),
                SizedBox(
                  height: restController.selectedCuisines!.isNotEmpty ? 40 : 0,
                  child: ListView.builder(
                    itemCount: restController.selectedCuisines!.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Row(children: [
                          Text(
                            restController.cuisineModel!.cuisines![restController.selectedCuisines![index]].name!,
                            style: robotoRegular.copyWith(color: Theme.of(context).cardColor),
                          ),
                          InkWell(
                            onTap: () => restController.removeCuisine(index),
                            child: Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: Icon(Icons.close, size: 15, color: Theme.of(context).cardColor),
                            ),
                          ),
                        ]),
                      );
                    },
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Align(alignment: Alignment.centerLeft, child: Text(
                'food_type'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              )) : const SizedBox(),
              Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Row(children: [
                Expanded(child: InkWell(
                  onTap: () => restController.setRestVeg(!restController.isRestVeg!, true),
                  child: Row(children: [
                    Checkbox(
                      value: restController.isRestVeg,
                      onChanged: (bool? isActive) => restController.setRestVeg(isActive, true),
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    Text('veg'.tr),
                  ]),
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(child: InkWell(
                  onTap: () => restController.setRestNonVeg(!restController.isRestNonVeg!, true),
                  child: Row(children: [
                    Checkbox(
                      value: restController.isRestNonVeg,
                      onChanged: (bool? isActive) => restController.setRestNonVeg(isActive, true),
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    Text('non_veg'.tr),
                  ]),
                )),
              ]) : const SizedBox(),
              SizedBox(height: Get.find<SplashController>().configModel!.toggleVegNonVeg! ? Dimensions.paddingSizeLarge : 0),

              Row(children: [
                Expanded(child: Text(
                  'gst'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                )),
                Switch(
                  value: restController.isGstEnabled!,
                  activeColor: Theme.of(context).primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (bool isActive) => restController.toggleGst(),
                ),
              ]),
              MyTextField(
                hintText: 'gst'.tr,
                controller: _gstController,
                inputAction: TextInputAction.done,
                title: false,
                isEnabled: restController.isGstEnabled,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Align(alignment: Alignment.centerLeft, child: Text(
                'daily_schedule_time'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              )),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 7,
                itemBuilder: (context, index) {
                  return DailyTimeWidget(weekDay: index);
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Get.find<SplashController>().configModel!.scheduleOrder! ? SwitchButton(icon: Icons.alarm_add, title: 'schedule_order'.tr, isButtonActive: widget.restaurant.scheduleOrder, onTap: () {
                _restaurant.scheduleOrder = !_restaurant.scheduleOrder!;
              }) : const SizedBox(),
              SizedBox(height: Get.find<SplashController>().configModel!.scheduleOrder! ? Dimensions.paddingSizeSmall : 0),

              SwitchButton(icon: Icons.delivery_dining, title: 'delivery'.tr, isButtonActive: widget.restaurant.delivery, onTap: () {
                _restaurant.delivery = !_restaurant.delivery!;
              }),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              SwitchButton(icon: Icons.flatware, title: 'cutlery'.tr, isButtonActive: widget.restaurant.cutlery, onTap: () {
                _restaurant.cutlery = !_restaurant.cutlery!;
              }),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Get.find<SplashController>().configModel!.takeAway ?? false ? SwitchButton(icon: Icons.house_siding, title: 'take_away'.tr, isButtonActive: widget.restaurant.takeAway, onTap: () {
                _restaurant.takeAway = !_restaurant.takeAway!;
              }) : const SizedBox(),
              SizedBox(height: Get.find<SplashController>().configModel!.takeAway ?? false ? Dimensions.paddingSizeSmall : 0),

              SwitchButton(icon: Icons.subscriptions_outlined, title: 'subscription_order'.tr, isButtonActive: widget.restaurant.orderSubscriptionActive, onTap: () {
                _restaurant.orderSubscriptionActive = !_restaurant.orderSubscriptionActive!;
              }),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: restController.pickedCover != null ? GetPlatform.isWeb ? Image.network(
                    restController.pickedCover!.path, width: context.width, height: 170, fit: BoxFit.cover,
                  ) : Image.file(
                    File(restController.pickedCover!.path), width: context.width, height: 170, fit: BoxFit.cover,
                  ) : FadeInImage.assetNetwork(
                    placeholder: Images.restaurantCover,
                    image: '${Get.find<SplashController>().configModel!.baseUrls!.restaurantCoverPhotoUrl}/${widget.restaurant.coverPhoto}',
                    height: 170, width: context.width, fit: BoxFit.cover,
                    imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder, height: 170, width: context.width, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0, top: 0, left: 0,
                  child: InkWell(
                    onTap: () => restController.pickImage(false, false),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          border: Border.all(width: 3, color: Colors.white),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 50),
                      ),
                    ),
                  ),
                ),
              ]),

            ]),
          )),

          SafeArea(
            child: !restController.isLoading ? CustomButton(
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              onPressed: () {
                bool defaultNameNull = false;
                bool defaultAddressNull = false;
                bool defaultMetaTitleNull = false;
                bool defaultMetaDescriptionNull = false;
                for(int index=0; index<_languageList!.length; index++) {
                  if(_languageList![index].key == 'en') {
                    if (_nameController[index].text.trim().isEmpty) {
                      defaultNameNull = true;
                    }
                    if(_addressController[index].text.trim().isEmpty){
                      defaultAddressNull = true;
                    }
                    if(_metaTitleController[index].text.trim().isEmpty){
                      defaultMetaTitleNull = true;
                    }
                    if(_metaDescriptionController[index].text.trim().isEmpty){
                      defaultMetaDescriptionNull = true;
                    }
                    break;
                  }
                }
                String contact = _contactController.text.trim();
                String minimumOrder = _orderAmountController.text.trim();
                String minimumFee = _minimumChargeController.text.trim();
                String perKmFee = _perKmChargeController.text.trim();
                String gstCode = _gstController.text.trim();
                String maximumFee = _maximumChargeController.text.trim();

                if(defaultNameNull) {
                  showCustomSnackBar('enter_your_restaurant_name'.tr);
                }else if(contact.isEmpty) {
                  showCustomSnackBar('enter_restaurant_contact_number'.tr);
                }else if(defaultAddressNull) {
                  showCustomSnackBar('enter_restaurant_address'.tr);
                }else if(minimumOrder.isEmpty) {
                  showCustomSnackBar('enter_minimum_order_amount'.tr);
                }else if(_restaurant.selfDeliverySystem == 1 && perKmFee.isNotEmpty && minimumFee.isEmpty /*&& maximumFee.isNotEmpty*/) {
                  showCustomSnackBar('enter_minimum_delivery_fee'.tr);
                }else if(_restaurant.selfDeliverySystem == 1 && minimumFee.isNotEmpty && perKmFee.isEmpty /*&& maximumFee.isNotEmpty*/) {
                  showCustomSnackBar('enter_per_km_delivery_fee'.tr);
                }else if(_restaurant.selfDeliverySystem == 1 && minimumFee.isNotEmpty && (maximumFee.isNotEmpty ? (double.parse(perKmFee) > double.parse(maximumFee)) : false) && double.parse(maximumFee) != 0) {
                  showCustomSnackBar('minimum_charge_can_not_be_more_then_maximum_charge'.tr);
                }else if(defaultMetaTitleNull) {
                  showCustomSnackBar('enter_meta_title'.tr);
                }else if(defaultMetaDescriptionNull) {
                  showCustomSnackBar('enter_meta_description'.tr);
                }else if(!restController.isRestVeg! && !restController.isRestNonVeg!){
                  showCustomSnackBar('select_at_least_one_food_type'.tr);
                }else if(restController.isGstEnabled! && gstCode.isEmpty){
                  showCustomSnackBar('enter_gst_code'.tr);
                }else if(_restaurant.selfDeliverySystem == 1 && minimumFee.isNotEmpty && perKmFee.isNotEmpty && maximumFee.isEmpty) {
                  showCustomSnackBar('enter_maximum_delivery_fee'.tr);
                }else {
                  List<String> cuisines = [];
                  List<Translation> translation = [];

                  for (var index in restController.selectedCuisines!) {
                    cuisines.add(restController.cuisineModel!.cuisines![index].id.toString());
                  }

                  for(int index=0; index<_languageList!.length; index++) {
                    translation.add(Translation(
                      locale: _languageList![index].key, key: 'name',
                      value: _nameController[index].text.trim().isNotEmpty ? _nameController[index].text.trim()
                          : _nameController[0].text.trim(),
                    ));
                    translation.add(Translation(
                      locale: _languageList![index].key, key: 'address',
                      value: _addressController[index].text.trim().isNotEmpty ? _addressController[index].text.trim()
                          : _addressController[0].text.trim(),
                    ));
                    translation.add(Translation(
                      locale: _languageList![index].key, key: 'meta_title',
                      value: _metaTitleController[index].text.trim().isNotEmpty ? _metaTitleController[index].text.trim()
                          : _metaTitleController[0].text.trim(),
                    ));
                    translation.add(Translation(
                      locale: _languageList![index].key, key: 'meta_description',
                      value: _metaDescriptionController[index].text.trim().isNotEmpty ? _metaDescriptionController[index].text.trim()
                          : _metaDescriptionController[0].text.trim(),
                    ));
                  }

                  _restaurant.phone = contact;
                  _restaurant.minimumOrder = double.parse(minimumOrder);
                  _restaurant.gstStatus = restController.isGstEnabled;
                  _restaurant.gstCode = gstCode;
                  _restaurant.minimumShippingCharge = minimumFee.isNotEmpty ? double.parse(minimumFee) : null;
                  _restaurant.maximumShippingCharge = maximumFee.isNotEmpty ? double.parse(maximumFee) : null;
                  _restaurant.perKmShippingCharge = perKmFee.isNotEmpty ? double.parse(perKmFee) : null;
                  _restaurant.veg = restController.isRestVeg! ? 1 : 0;
                  _restaurant.nonVeg = restController.isRestNonVeg! ? 1 : 0;
                  restController.updateRestaurant(_restaurant, cuisines, Get.find<AuthController>().getUserToken(), translation);
                }
              },
              buttonText: 'update'.tr,
            ) : const Center(child: CircularProgressIndicator()),
          ),

        ]);
      }),
    );
  }
}
