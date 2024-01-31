import 'dart:async';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/localization_controller.dart';
import 'package:efood_multivendor_restaurant/controller/order_controller.dart';
import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/body/notification_body.dart';
import 'package:efood_multivendor_restaurant/data/model/response/conversation_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/order_details_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/order_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/profile_model.dart';
import 'package:efood_multivendor_restaurant/helper/date_converter.dart';
import 'package:efood_multivendor_restaurant/helper/price_converter.dart';
import 'package:efood_multivendor_restaurant/helper/responsive_helper.dart';
import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/confirmation_dialog.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_app_bar.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_button.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_image.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_snackbar.dart';
import 'package:efood_multivendor_restaurant/view/base/input_dialog.dart';
import 'package:efood_multivendor_restaurant/view/screens/order/invoice_print_screen.dart';
import 'package:efood_multivendor_restaurant/view/screens/order/widget/camera_button_sheet.dart';
import 'package:efood_multivendor_restaurant/view/screens/order/widget/cancellation_dialogue.dart';
import 'package:efood_multivendor_restaurant/view/screens/order/widget/collect_money_delivery_sheet.dart';
import 'package:efood_multivendor_restaurant/view/screens/order/widget/dialogue_image.dart';
import 'package:efood_multivendor_restaurant/view/screens/order/widget/order_product_widget.dart';
import 'package:efood_multivendor_restaurant/view/screens/order/widget/slider_button.dart';
import 'package:efood_multivendor_restaurant/view/screens/order/widget/verify_delivery_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel orderModel;
  final bool isRunningOrder;
  const OrderDetailsScreen({Key? key, required this.orderModel, required this.isRunningOrder}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> with WidgetsBindingObserver {
  late Timer _timer;

  void _startApiCalling(){
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Get.find<OrderController>().setOrderDetails(OrderModel(id: widget.orderModel.id));
    });
  }

  @override
  void initState() {
    super.initState();

    if(Get.find<OrderController>().showDeliveryImageField){
      Get.find<OrderController>().changeDeliveryImageStatus(isUpdate: false);
    }
    Get.find<OrderController>().pickPrescriptionImage(isRemove: true, isCamera: false);

    Get.find<OrderController>().setOrderDetails(widget.orderModel);
    if(Get.find<AuthController>().profileModel == null){
      Get.find<AuthController>().getProfile();
    }

    Get.find<OrderController>().getOrderDetails(widget.orderModel.id);

    _startApiCalling();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startApiCalling();
    }else if(state == AppLifecycleState.paused){
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);

    _timer.cancel();
  }
  
  @override
  Widget build(BuildContext context) {
    bool? cancelPermission = Get.find<SplashController>().configModel!.canceledByRestaurant;
    late bool selfDelivery;
    if(Get.find<AuthController>().profileModel != null && Get.find<AuthController>().profileModel!.restaurants != null){
      selfDelivery = Get.find<AuthController>().profileModel!.restaurants![0].selfDeliverySystem == 1;
    }

    return GetBuilder<OrderController>(
      builder: (orderController) {
        OrderModel? controllerOrderModel = orderController.orderModel;

        bool restConfModel = Get.find<SplashController>().configModel!.orderConfirmationModel != 'deliveryman';
        bool showSlider = controllerOrderModel != null ? (controllerOrderModel.orderStatus == 'pending' && (controllerOrderModel.orderType == 'take_away' || restConfModel || selfDelivery))
            || controllerOrderModel.orderStatus == 'confirmed' || controllerOrderModel.orderStatus == 'processing'
            || (controllerOrderModel.orderStatus == 'accepted' && controllerOrderModel.confirmed != null)
            || (controllerOrderModel.orderStatus == 'handover' && (selfDelivery || controllerOrderModel.orderType == 'take_away')) : false;
        bool showBottomView = controllerOrderModel != null ? showSlider || controllerOrderModel.orderStatus == 'picked_up' || widget.isRunningOrder : false;
        bool showDeliveryConfirmImage = orderController.showDeliveryImageField && Get.find<SplashController>().configModel!.dmPictureUploadStatus!;


        double? deliveryCharge = 0;
        double itemsPrice = 0;
        double? discount = 0;
        double? couponDiscount = 0;
        double? dmTips = 0;
        double? tax = 0;
        bool? taxIncluded = false;
        double addOns = 0;
        double additionalCharge = 0;
        OrderModel? order = controllerOrderModel;
        Restaurant? restaurant;
        bool subscription = false;
        if(Get.find<AuthController>().profileModel != null){
          restaurant = Get.find<AuthController>().profileModel!.restaurants![0];
        }

        if(order != null && orderController.orderDetailsModel != null ) {
          subscription = order.subscriptionId != null && orderController.subscriptionModel != null;

          if(order.orderType == 'delivery') {
            deliveryCharge = order.deliveryCharge;
            dmTips = order.dmTips;
          }
          discount = order.restaurantDiscountAmount;
          tax = order.totalTaxAmount;
          taxIncluded = order.taxStatus;
          couponDiscount = order.couponDiscountAmount;
          additionalCharge = order.additionalCharge ?? 0;
          for(OrderDetailsModel orderDetails in orderController.orderDetailsModel!) {
            for(AddOn addOn in orderDetails.addOns!) {
              addOns = addOns + (addOn.price! * addOn.quantity!);
            }
            itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.quantity!);
          }
        }
        double subTotal = itemsPrice + addOns;
        double total = itemsPrice + addOns - discount! + (taxIncluded! ? 0 : tax!) + deliveryCharge! - couponDiscount! + dmTips! + additionalCharge;

        return Scaffold(
          appBar: CustomAppBar(title: subscription ? 'subscription_order'.tr : 'order_details'.tr),
          body: (orderController.orderDetailsModel != null && controllerOrderModel != null && restaurant != null) ? Column(children: [

            Expanded(child: Scrollbar(child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Center(child: SizedBox(width: 1170, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                DateConverter.isBeforeTime(controllerOrderModel.scheduleAt) ? (controllerOrderModel.orderStatus != 'delivered'
                && controllerOrderModel.orderStatus != 'failed' && controllerOrderModel.orderStatus != 'canceled'
                && controllerOrderModel.orderStatus != 'refunded' && controllerOrderModel.orderStatus != 'refund_request_canceled') ? Column(children: [

                  ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(Images.animateDeliveryMan, fit: BoxFit.contain)),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Text('food_need_to_delivered_within'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Center(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [

                      Text(
                        DateConverter.differenceInMinute(restaurant.deliveryTime, controllerOrderModel.createdAt, controllerOrderModel.processingTime, controllerOrderModel.scheduleAt) < 5 ? '1 - 5'
                            : '${DateConverter.differenceInMinute(restaurant.deliveryTime, controllerOrderModel.createdAt, controllerOrderModel.processingTime, controllerOrderModel.scheduleAt)-5} '
                            '- ${DateConverter.differenceInMinute(restaurant.deliveryTime, controllerOrderModel.createdAt, controllerOrderModel.processingTime, controllerOrderModel.scheduleAt)}',
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Text('min'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                ]) : const SizedBox() : const SizedBox(),

                Row(children: [
                  Text('${'order_id'.tr}:', style: robotoRegular),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(order!.id.toString(), style: robotoMedium),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  const Expanded(child: SizedBox()),
                  const Icon(Icons.watch_later, size: 17),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    DateConverter.dateTimeStringToDateTime(order.createdAt!),
                    style: robotoRegular,
                  ),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                order.scheduled == 1 ? Row(children: [
                  Text('${'scheduled_at'.tr}:', style: robotoRegular),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(DateConverter.dateTimeStringToDateTime(order.scheduleAt!), style: robotoMedium),
                ]) : const SizedBox(),
                SizedBox(height: order.scheduled == 1 ? Dimensions.paddingSizeSmall : 0),

                Row(children: [
                  Text(order.orderType!.tr, style: robotoMedium),
                  const Expanded(child: SizedBox()),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: Text(
                      order.paymentMethod == 'cash_on_delivery' ? 'cash_on_delivery'.tr : order.paymentMethod == 'wallet'
                          ? 'wallet_payment'.tr : 'digital_payment'.tr,
                      style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall),
                    ),
                  ),
                ]),
                const Divider(height: Dimensions.paddingSizeLarge),

                subscription ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Row(children: [
                    Text('${'subscription_date'.tr}:', style: robotoRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(
                      '${DateConverter.convertDateToDate(orderController.subscriptionModel!.startAt!)} '
                          '- ${DateConverter.convertDateToDate(orderController.subscriptionModel!.endAt!)}',
                      style: robotoMedium,
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Row(children: [
                    Text('${'subscription_type'.tr}:', style: robotoRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(orderController.subscriptionModel!.type!.tr, style: robotoMedium),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  const Divider(height: Dimensions.paddingSizeLarge),
                ]) : const SizedBox(),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                  child: Row(children: [
                    Text('${'item'.tr}:', style: robotoRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      orderController.orderDetailsModel!.length.toString(),
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                    ),
                    const Expanded(child: SizedBox()),
                    Container(height: 7, width: 7, decoration: BoxDecoration(
                        color: (order.orderStatus == 'failed' || order.orderStatus == 'canceled' || order.orderStatus == 'refund_request_canceled')
                            ? Colors.red : order.orderStatus == 'refund_requested' ? Colors.yellow : Colors.green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      order.orderStatus == 'delivered' ? '${'delivered_at'.tr} ${order.delivered != null ? DateConverter.dateTimeStringToDateTime(order.delivered!) : ''}'
                          : order.orderStatus!.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ),
                  ]),
                ),
                const Divider(height: Dimensions.paddingSizeLarge),

                order.cutlery != null ? Row(children: [
                  Text('${'cutlery'.tr}: ', style: robotoRegular),
                  const Expanded(child: SizedBox()),

                  Text(
                    order.cutlery! ? 'yes'.tr : 'no'.tr,
                    style: robotoRegular,
                  ),
                ]) : const SizedBox(),
                const Divider(height: Dimensions.paddingSizeLarge),

                order.unavailableItemNote != null ? Row(children: [
                  Text('${'if_item_is_not_available'.tr}: ', style: robotoMedium),

                  Text(
                    order.unavailableItemNote!.tr,
                    style: robotoRegular,
                  ),
                ]) : const SizedBox(),
                order.unavailableItemNote != null ? const Divider(height: Dimensions.paddingSizeLarge) : const SizedBox(),

                order.deliveryInstruction != null ? Row(children: [
                  Text('${'delivery_instruction'.tr}: ', style: robotoMedium),

                  Text(
                    order.deliveryInstruction!.tr,
                    style: robotoRegular,
                  ),
                ]) : const SizedBox(),
                order.deliveryInstruction != null ? const Divider(height: Dimensions.paddingSizeLarge) : const SizedBox(),

                SizedBox(height: order.deliveryInstruction != null ? Dimensions.paddingSizeSmall : 0),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderController.orderDetailsModel!.length,
                  itemBuilder: (context, index) {
                    return OrderProductWidget(order: order, orderDetails: orderController.orderDetailsModel![index]);
                  },
                ),

                (order.orderNote  != null && order.orderNote!.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('additional_note'.tr, style: robotoRegular),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Container(
                    width: 1170,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(width: 1, color: Theme.of(context).disabledColor),
                    ),
                    child: Text(
                      order.orderNote!.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                ]) : const SizedBox(),

                Text('customer_details'.tr, style: robotoRegular),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(children: [
                  ClipOval(child: CustomImage(
                    image: order.customer != null ?'${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}/${order.customer!.image}' : '',
                    height: 35, width: 35, fit: BoxFit.cover,
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: order.deliveryAddress != null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      order.deliveryAddress!.contactPersonName!, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ),
                    Text(
                      order.deliveryAddress!.address != null ? order.deliveryAddress!.address! : '', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    ),

                    Wrap(children: [
                      (order.deliveryAddress?.streetNumber != null && order.deliveryAddress!.streetNumber!.isNotEmpty)
                        ? Text(
                        '${'street_number'.tr}: ${order.deliveryAddress!.streetNumber!}${(order.deliveryAddress?.house != null && order.deliveryAddress!.house!.isNotEmpty) ? ', ' : ' '}',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ) : const SizedBox(),

                      (order.deliveryAddress?.house != null && order.deliveryAddress!.house!.isNotEmpty) ? Text('${'house'.tr}: ${order.deliveryAddress!.house!}${(order.deliveryAddress!.floor != null && order.deliveryAddress!.floor!.isNotEmpty) ? ', ' : ' '}',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor), maxLines: 1, overflow: TextOverflow.ellipsis,
                      ) : const SizedBox(),

                      (order.deliveryAddress?.floor != null && order.deliveryAddress!.floor!.isNotEmpty) ? Text('${'floor'.tr}: ${order.deliveryAddress!.floor!}' ,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor), maxLines: 1, overflow: TextOverflow.ellipsis,
                      ) : const SizedBox(),
                    ]),

                  ]) : Text('walking_customer'.tr, style: robotoMedium)),

                  (order.orderType == 'take_away' && (order.orderStatus == 'pending' || order.orderStatus == 'confirmed'
                  || order.orderStatus == 'processing')) ? TextButton.icon(
                    onPressed: () async {
                      String url ='https://www.google.com/maps/dir/?api=1&destination=${order.deliveryAddress?.latitude}'
                          ',${order.deliveryAddress?.longitude}&mode=d';
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url, mode: LaunchMode.externalApplication);
                      }else {
                        showCustomSnackBar('unable_to_launch_google_map'.tr);
                      }
                    },
                    icon: const Icon(Icons.directions), label: Text('direction'.tr),
                  ) : const SizedBox(),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  (controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'failed'
                  && controllerOrderModel.orderStatus != 'canceled' && controllerOrderModel.orderStatus != 'refunded') ? TextButton.icon(
                    onPressed: () async {
                      if(Get.find<AuthController>().profileModel!.subscription != null && Get.find<AuthController>().profileModel!.subscription!.chat == 0 && Get.find<AuthController>().profileModel!.restaurants![0].restaurantModel == 'subscription') {

                        showCustomSnackBar('you_have_no_available_subscription'.tr);

                      }else{
                        _timer.cancel();
                        await Get.toNamed(RouteHelper.getChatRoute(
                          notificationBody: NotificationBody(
                            orderId: orderController.orderModel!.id,
                            customerId: orderController.orderModel!.customer!.id,
                          ),
                          user: User(
                            id: orderController.orderModel!.customer!.id,
                            fName: orderController.orderModel!.customer!.fName,
                            lName: orderController.orderModel!.customer!.lName,
                            image: orderController.orderModel!.customer!.image,
                          ),
                        ));
                        _startApiCalling();
                      }
                    },
                    icon: Icon(Icons.chat_bubble_outline, color: Theme.of(context).primaryColor, size: 20),
                    label: Text(
                      'chat'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                    ),
                  ) : const SizedBox(),
                ]),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                order.deliveryMan != null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text('delivery_man'.tr, style: robotoRegular),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Row(children: [

                    ClipOval(child: CustomImage(
                      image: order.deliveryMan != null ?'${Get.find<SplashController>().configModel!.baseUrls!.deliveryManImageUrl}/${order.deliveryMan!.image}' : '',
                      height: 35, width: 35, fit: BoxFit.cover,
                    )),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        '${order.deliveryMan!.fName} ${order.deliveryMan!.lName}', maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                      ),
                      Text(
                        order.deliveryMan!.email!, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      ),
                    ])),

                    (controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'failed'
                    && controllerOrderModel.orderStatus != 'canceled' && controllerOrderModel.orderStatus != 'refunded') ? TextButton.icon(
                      onPressed: () async {
                        if(await canLaunchUrlString('tel:${order.deliveryMan!.phone ?? '' }')) {
                          launchUrlString('tel:${order.deliveryMan!.phone ?? '' }', mode: LaunchMode.externalApplication);
                        }else {
                          showCustomSnackBar('${'can_not_launch'.tr} ${order.deliveryMan!.phone ?? ''}');
                        }
                      },
                      icon: Icon(Icons.call, color: Theme.of(context).primaryColor, size: 20),
                      label: Text(
                        'call'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                      ),
                    ) : const SizedBox(),

                    (controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'failed'
                    && controllerOrderModel.orderStatus != 'canceled' && controllerOrderModel.orderStatus != 'refunded') ? TextButton.icon(
                      onPressed: () async {
                        if(Get.find<AuthController>().profileModel!.subscription != null && Get.find<AuthController>().profileModel!.subscription!.chat == 0
                            && Get.find<AuthController>().profileModel!.restaurants![0].restaurantModel == 'subscription') {
                          showCustomSnackBar('you_have_no_available_subscription'.tr);

                        }else{
                          _timer.cancel();
                          await Get.toNamed(RouteHelper.getChatRoute(
                            notificationBody: NotificationBody(
                              orderId: orderController.orderModel!.id, deliveryManId: order.deliveryMan!.id,
                            ),
                            user: User(
                              id: orderController.orderModel!.deliveryMan!.id, fName: orderController.orderModel!.deliveryMan!.fName,
                              lName: orderController.orderModel!.deliveryMan!.lName, image: orderController.orderModel!.deliveryMan!.image,
                            ),
                          ));
                          _startApiCalling();
                        }
                      },
                      icon: Icon(Icons.chat_bubble_outline, color: Theme.of(context).primaryColor, size: 20),
                      label: Text(
                        'chat'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                      ),
                    ) : const SizedBox(),

                  ]),
                ],
                ) : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                (controllerOrderModel.orderStatus == 'delivered' && controllerOrderModel.orderProof != null
                && controllerOrderModel.orderProof!.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('order_proof'.tr, style: robotoRegular),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1.5,
                        crossAxisCount: ResponsiveHelper.isTab(context) ? 5 : 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 5,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controllerOrderModel.orderProof!.length,
                      itemBuilder: (BuildContext context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => openDialog(context, '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${controllerOrderModel.orderProof![index]}'),
                            child: Center(child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImage(
                                image: '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${controllerOrderModel.orderProof![index]}',
                                width: 100, height: 100,
                              ),
                            )),
                          ),
                        );
                      }),

                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ]) : const SizedBox(),

                // Total
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('item_price'.tr, style: robotoRegular),
                  Text(PriceConverter.convertPrice(itemsPrice), style: robotoRegular, textDirection: TextDirection.ltr),
                ]),
                const SizedBox(height: 10),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('addons'.tr, style: robotoRegular),
                  Text('(+) ${PriceConverter.convertPrice(addOns)}', style: robotoRegular, textDirection: TextDirection.ltr,),
                ]),

                Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${'subtotal'.tr} ${taxIncluded ? '(${'tax_included'.tr})' : ''}', style: robotoMedium),
                  Text(PriceConverter.convertPrice(subTotal), style: robotoMedium, textDirection: TextDirection.ltr),
                ]),
                const SizedBox(height: 10),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('discount'.tr, style: robotoRegular),
                  Text('(-) ${PriceConverter.convertPrice(discount)}', style: robotoRegular, textDirection: TextDirection.ltr),
                ]),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('delivery_man_tips'.tr, style: robotoRegular),
                  Text('(+) ${PriceConverter.convertPrice(dmTips)}', style: robotoRegular, textDirection: TextDirection.ltr),
                ],
                ),
                const SizedBox(height: 10),

                couponDiscount > 0 ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('coupon_discount'.tr, style: robotoRegular),
                  Text(
                    '(-) ${PriceConverter.convertPrice(couponDiscount)}',
                    style: robotoRegular, textDirection: TextDirection.ltr,
                  ),
                ]) : const SizedBox(),
                SizedBox(height: couponDiscount > 0 ? 10 : 0),

                !taxIncluded ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('vat_tax'.tr, style: robotoRegular),
                  Text('(+) ${PriceConverter.convertPrice(tax)}', style: robotoRegular, textDirection: TextDirection.ltr),
                ]) : const SizedBox(),
                SizedBox(height: taxIncluded ? 0 : 10),

                (order.additionalCharge != null && order.additionalCharge! > 0) ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(Get.find<SplashController>().configModel!.additionalChargeName!, style: robotoRegular),
                  Text('(+) ${PriceConverter.convertPrice(order.additionalCharge)}', style: robotoRegular, textDirection: TextDirection.ltr),
                ]) : const SizedBox(),
                (order.additionalCharge != null && order.additionalCharge! > 0) ? const SizedBox(height: 10) : const SizedBox(),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('delivery_fee'.tr, style: robotoRegular),
                  Text('(+) ${PriceConverter.convertPrice(deliveryCharge)}', style: robotoRegular, textDirection: TextDirection.ltr),
                ]),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                ),

                order.paymentMethod == 'partial_payment' ? DottedBorder(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 1,
                  strokeCap: StrokeCap.butt,
                  dashPattern: const [8, 5],
                  padding: const EdgeInsets.all(0),
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(Dimensions.radiusDefault),
                  child: Ink(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    color: restConfModel ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent,
                    child: Column(children: [

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('total_amount'.tr, style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor,
                        )),
                        Text(
                          PriceConverter.convertPrice(total),
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                        ),
                      ]),
                      const SizedBox(height: 10),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('paid_by_wallet'.tr, style: restConfModel ? robotoMedium : robotoRegular),
                        Text(
                          PriceConverter.convertPrice(order.payments![0].amount),
                          style: restConfModel ? robotoMedium : robotoRegular,
                        ),
                      ]),
                      const SizedBox(height: 10),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('${order.payments![1].paymentStatus == 'paid' ? 'paid_by'.tr : 'due_amount'.tr} (${order.payments![1].paymentMethod?.tr})', style: restConfModel ? robotoMedium : robotoRegular),
                        Text(
                          PriceConverter.convertPrice(order.payments![1].amount),
                          style: restConfModel ? robotoMedium : robotoRegular,
                        ),
                      ]),
                    ]),
                  ),
                ) : const SizedBox(),

                order.paymentMethod != 'partial_payment' ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('total_amount'.tr, style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor,
                  )),
                  Text(
                    PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                  ),
                ]) : const SizedBox(),


              ]))),
            ))),

            showDeliveryConfirmImage && controllerOrderModel.orderStatus != 'delivered' ? Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.fontSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Text('completed_after_delivery_picture'.tr, style: robotoRegular),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: orderController.pickedPrescriptions.length+1,
                    itemBuilder: (context, index) {
                      XFile? file = index == orderController.pickedPrescriptions.length ? null : orderController.pickedPrescriptions[index];
                      if(index < 5 && index == orderController.pickedPrescriptions.length) {
                        return InkWell(
                          onTap: () {
                            Get.bottomSheet(const CameraButtonSheet());
                          },
                          child: Container(
                            height: 60, width: 60, alignment: Alignment.center, decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                            child:  Icon(Icons.camera_alt_sharp, color: Theme.of(context).primaryColor, size: 32),
                          ),
                        );
                      }
                      return file != null ? Container(
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: GetPlatform.isWeb ? Image.network(
                              file.path, width: 60, height: 60, fit: BoxFit.cover,
                            ) : Image.file(
                              File(file.path), width: 60, height: 60, fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0, top: 0,
                            child: InkWell(
                              onTap: () => orderController.removePrescriptionImage(index),
                              child: const Padding(
                                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                                child: Icon(Icons.delete_forever, color: Colors.red),
                              ),
                            ),
                          ),
                        ]),
                      ) : const SizedBox();
                    },
                  ),
                ),
              ]),
            ) : const SizedBox(),

            SafeArea(
              child:  showDeliveryConfirmImage && controllerOrderModel.orderStatus != 'delivered' ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: CustomButton(
                  buttonText: 'complete_delivery'.tr,
                  onPressed: () {
                    if(Get.find<SplashController>().configModel!.orderDeliveryVerification!) {
                      orderController.sendDeliveredNotification(controllerOrderModel.id);

                      Get.bottomSheet(VerifyDeliverySheet(
                        orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                        cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                      ), isScrollControlled: true).then((isSuccess) {

                        if(isSuccess && controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery')){
                          Get.bottomSheet(CollectMoneyDeliverySheet(
                            orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                            orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                            cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                          ), isScrollControlled: true, isDismissible: false);
                        }
                      });
                    } else {
                      Get.bottomSheet(CollectMoneyDeliverySheet(
                        orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                        cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                      ), isScrollControlled: true);
                    }

                  },
                ),
              ) : showBottomView ? (controllerOrderModel.orderStatus == 'picked_up') ? Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(width: 1),
                ),
                alignment: Alignment.center,
                child: Text('food_is_on_the_way'.tr, style: robotoMedium),
              ) : showSlider ? (controllerOrderModel.orderStatus == 'pending' && (controllerOrderModel.orderType == 'take_away'
              || restConfModel || selfDelivery) && cancelPermission!) ? Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Row(children: [
                  Expanded(child: TextButton(
                    onPressed: () {
                      orderController.setOrderCancelReason('');
                      Get.dialog(CancellationDialogue(orderId: order.id));
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(1170, 40), padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        side: BorderSide(width: 1, color: Theme.of(context).textTheme.bodyLarge!.color!),
                      ),
                    ),
                    child: Text('cancel'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontSize: Dimensions.fontSizeLarge,
                    )),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(child: CustomButton(
                    buttonText: 'confirm'.tr, height: 40,
                    onPressed: () {
                      Get.dialog(ConfirmationDialog(
                        icon: Images.warning, title: 'are_you_sure_to_confirm'.tr, description: 'you_want_to_confirm_this_order'.tr,
                        onYesPressed: () {
                          orderController.updateOrderStatus(controllerOrderModel.id, 'confirmed', back: true).then((success) {
                            if(success) {
                              Get.find<AuthController>().getProfile();
                              Get.find<OrderController>().getCurrentOrders();
                            }
                          });
                        },
                      ), barrierDismissible: false);
                    },
                  )),
                ]),
              ) : SliderButton(
                action: () {
                  if(controllerOrderModel.orderStatus == 'pending' && (controllerOrderModel.orderType == 'take_away'
                      || restConfModel || selfDelivery))  {
                    Get.dialog(ConfirmationDialog(
                      icon: Images.warning, title: 'are_you_sure_to_confirm'.tr, description: 'you_want_to_confirm_this_order'.tr,
                      onYesPressed: () {
                        orderController.updateOrderStatus(controllerOrderModel.id, 'confirmed', back: true).then((success) {
                          if(success) {
                            Get.find<AuthController>().getProfile();
                            Get.find<OrderController>().getCurrentOrders();
                          }
                        });
                      },
                      onNoPressed: () {
                        if(cancelPermission!) {
                          orderController.updateOrderStatus(controllerOrderModel.id, 'canceled', back: true).then((success) {
                            if(success) {
                              Get.find<AuthController>().getProfile();
                              Get.find<OrderController>().getCurrentOrders();
                            }
                          });
                        }else {
                          Get.back();
                        }
                      },
                    ), barrierDismissible: false);
                  }else if(controllerOrderModel.orderStatus == 'processing') {
                    Get.find<OrderController>().updateOrderStatus(controllerOrderModel.id, 'handover').then((success) {
                      if(success) {
                        Get.find<AuthController>().getProfile();
                        Get.find<OrderController>().getCurrentOrders();
                      }
                    });
                  }else if(controllerOrderModel.orderStatus == 'confirmed' || (controllerOrderModel.orderStatus == 'accepted'
                      && controllerOrderModel.confirmed != null)) {
                    Get.dialog(InputDialog(
                      icon: Images.warning,
                      title: 'are_you_sure_to_confirm'.tr,
                      description: 'enter_processing_time_in_minutes'.tr, onPressed: (String? time){
                      Get.back();
                      Get.find<OrderController>().updateOrderStatus(controllerOrderModel.id, 'processing', processingTime: time).then((success) {
                        if(success) {
                          Get.find<AuthController>().getProfile();
                          Get.find<OrderController>().getCurrentOrders();
                        }
                      });
                    },
                    ));
                  }else if((controllerOrderModel.orderStatus == 'handover' && (controllerOrderModel.orderType == 'take_away' || selfDelivery))) {
                    if (Get.find<SplashController>().configModel!.orderDeliveryVerification!
                        || controllerOrderModel.paymentMethod == 'cash_on_delivery') {
                      orderController.changeDeliveryImageStatus();
                      if(Get.find<SplashController>().configModel!.dmPictureUploadStatus!) {
                        Get.dialog(const DialogImage(), barrierDismissible: false);
                      } else {
                        if(Get.find<SplashController>().configModel!.orderDeliveryVerification!){
                          orderController.sendDeliveredNotification(controllerOrderModel.id);

                          Get.bottomSheet(VerifyDeliverySheet(
                            orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                            orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                            cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                          ), isScrollControlled: true).then((isSuccess) {


                            if(isSuccess && controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery')){
                              Get.bottomSheet(CollectMoneyDeliverySheet(
                                orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                                orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                                cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                              ), isScrollControlled: true, isDismissible: false);
                            }
                          });
                        } else {
                          Get.bottomSheet(CollectMoneyDeliverySheet(
                            orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                            orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                            cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                          ), isScrollControlled: true);
                        }
                      }
                    } else {
                      Get.find<OrderController>().updateOrderStatus(controllerOrderModel.id, 'delivered').then((success) {
                        if (success) {
                          Get.find<AuthController>().getProfile();
                          Get.find<OrderController>().getCurrentOrders();
                        }
                      });
                    }
                  }
                },
                label: Text(
                  (controllerOrderModel.orderStatus == 'pending' && (controllerOrderModel.orderType == 'take_away'
                      || restConfModel || selfDelivery))
                      ? 'swipe_to_confirm_order'.tr : (controllerOrderModel.orderStatus == 'confirmed' || (controllerOrderModel.orderStatus == 'accepted'
                      && controllerOrderModel.confirmed != null)) ? 'swipe_to_cooking'.tr
                      : (controllerOrderModel.orderStatus == 'processing') ? 'swipe_if_ready_for_handover'.tr
                      : (controllerOrderModel.orderStatus == 'handover' && (controllerOrderModel.orderType == 'take_away' || selfDelivery))
                      ? 'swipe_to_deliver_order'.tr : '',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                ),
                dismissThresholds: 0.5, dismissible: false, shimmer: true,
                width: 1170, height: 60, buttonSize: 50, radius: 10,
                icon: Center(child: Icon(
                  Get.find<LocalizationController>().isLtr ? Icons.double_arrow_sharp : Icons.keyboard_arrow_left,
                  color: Colors.white, size: 20.0,
                )),
                isLtr: Get.find<LocalizationController>().isLtr,
                boxShadow: const BoxShadow(blurRadius: 0),
                buttonColor: Theme.of(context).primaryColor,
                backgroundColor: const Color(0xffF4F7FC),
                baseColor: Theme.of(context).primaryColor,
              ) : const SizedBox() : const SizedBox(),
            ),

            (!GetPlatform.isWeb) ? Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: CustomButton(
                onPressed: () {
                  Get.dialog(Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                    insetPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: InVoicePrintScreen(order: order, orderDetails: orderController.orderDetailsModel),
                  ));
                },
                icon: Icons.local_print_shop,
                buttonText: 'print_invoice'.tr,
              ),
            ) : const SizedBox(),

          ]) : const Center(child: CircularProgressIndicator()),
        );
      }
    );
  }

  void openDialog(BuildContext context, String imageUrl) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
        child: Stack(children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: PhotoView(
              tightMode: true,
              imageProvider: NetworkImage(imageUrl),
              heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            ),
          ),

          Positioned(top: 0, right: 0, child: IconButton(
            splashRadius: 5,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.cancel, color: Colors.red),
          )),

        ]),
      );
    },
  );
}
