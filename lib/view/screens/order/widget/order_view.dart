import 'package:efood_multivendor_restaurant/controller/order_controller.dart';
import 'package:efood_multivendor_restaurant/helper/custom_print.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/view/base/order_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderView extends StatefulWidget {
  const OrderView({Key? key}) : super(key: key);

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<OrderController>().setOffset(1);
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<OrderController>().historyOrderList != null
          && !Get.find<OrderController>().paginate) {
        int pageSize = (Get.find<OrderController>().pageSize! / 10).ceil();
        if (Get.find<OrderController>().offset < pageSize) {
          Get.find<OrderController>().setOffset(Get.find<OrderController>().offset+1);
          customPrint('end of the page');
          Get.find<OrderController>().showBottomLoader();
          Get.find<OrderController>().getPaginatedOrders(Get.find<OrderController>().offset, false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      return Column(children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => await orderController.getPaginatedOrders(1, true),
            child: ListView.builder(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: orderController.historyOrderList!.length,
              itemBuilder: (context, index) {
                return OrderWidget(
                  orderModel: orderController.historyOrderList![index],
                  hasDivider: index != orderController.historyOrderList!.length-1, isRunning: false,
                  showStatus: orderController.historyIndex == 0,
                );
              },
            ),
          ),
        ),

        orderController.paginate ? const Center(child: Padding(
          padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: CircularProgressIndicator(),
        )) : const SizedBox(),
      ]);
    });
  }
}
