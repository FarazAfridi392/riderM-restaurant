import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/body/bluetooth_printer_body.dart';
import 'package:efood_multivendor_restaurant/data/model/response/order_details_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/order_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/product_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/profile_model.dart';
import 'package:efood_multivendor_restaurant/helper/date_converter.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_button.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as i;
import 'package:screenshot/screenshot.dart';

class InVoicePrintScreen extends StatefulWidget {
  final OrderModel? order;
  final List<OrderDetailsModel>? orderDetails;
  const InVoicePrintScreen(
      {Key? key, required this.order, required this.orderDetails})
      : super(key: key);

  @override
  State<InVoicePrintScreen> createState() => _InVoicePrintScreenState();
}

class _InVoicePrintScreenState extends State<InVoicePrintScreen> {
  PrinterType _defaultPrinterType = PrinterType.bluetooth;
  final bool _isBle = GetPlatform.isIOS;
  final PrinterManager _printerManager = PrinterManager.instance;
  final List<BluetoothPrinter> _devices = <BluetoothPrinter>[];
  StreamSubscription<PrinterDevice>? _subscription;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  BTStatus _currentStatus = BTStatus.none;
  List<int>? pendingTask;
  String _ipAddress = '';
  String _port = '9100';
  bool _paper80MM = true;
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  BluetoothPrinter? _selectedPrinter;
  bool _searchingMode = true;

  @override
  void initState() {
    if (Platform.isWindows) _defaultPrinterType = PrinterType.usb;
    super.initState();
    _portController.text = _port;
    _scan();

    // subscription to listen change status of bluetooth connection
    _subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      log(' ----------------- status bt $status ------------------ ');
      _currentStatus = status;

      if (status == BTStatus.connected && pendingTask != null) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          PrinterManager.instance
              .send(type: PrinterType.bluetooth, bytes: pendingTask!);
          pendingTask = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscriptionBtStatus?.cancel();
    _portController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  // method to scan devices according PrinterType
  void _scan() {
    _devices.clear();
    _subscription = _printerManager
        .discovery(type: _defaultPrinterType, isBle: _isBle)
        .listen((device) {
      _devices.add(BluetoothPrinter(
        deviceName: device.name,
        address: device.address,
        isBle: _isBle,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: _defaultPrinterType,
      ));
      setState(() {});
    });
  }

  void _setPort(String value) {
    if (value.isEmpty) value = '9100';
    _port = value;
    var device = BluetoothPrinter(
      deviceName: value,
      address: _ipAddress,
      port: _port,
      typePrinter: PrinterType.network,
      state: false,
    );
    _selectDevice(device);
  }

  void _setIpAddress(String value) {
    _ipAddress = value;
    BluetoothPrinter device = BluetoothPrinter(
      deviceName: value,
      address: _ipAddress,
      port: _port,
      typePrinter: PrinterType.network,
      state: false,
    );
    _selectDevice(device);
  }

  void _selectDevice(BluetoothPrinter device) async {
    if (_selectedPrinter != null) {
      if ((device.address != _selectedPrinter!.address) ||
          (device.typePrinter == PrinterType.usb &&
              _selectedPrinter!.vendorId != device.vendorId)) {
        await PrinterManager.instance
            .disconnect(type: _selectedPrinter!.typePrinter);
      }
    }

    _selectedPrinter = device;
    setState(() {});
  }

  Future _printReceipt(i.Image image) async {
    i.Image resized = i.copyResize(image, width: _paper80MM ? 500 : 365);
    CapabilityProfile profile = await CapabilityProfile.load();
    Generator generator =
        Generator(_paper80MM ? PaperSize.mm80 : PaperSize.mm58, profile);
    List<int> bytes = [];
    bytes += generator.image(resized);
    _printEscPos(bytes, generator);
  }

  /// print ticket
  void _printEscPos(List<int> bytes, Generator generator) async {
    if (_selectedPrinter == null) return;
    var bluetoothPrinter = _selectedPrinter!;

    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        bytes += generator.feed(2);
        bytes += generator.cut();
        await _printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: UsbPrinterInput(
            name: bluetoothPrinter.deviceName,
            productId: bluetoothPrinter.productId,
            vendorId: bluetoothPrinter.vendorId,
          ),
        );
        break;
      case PrinterType.bluetooth:
        bytes += generator.cut();
        await _printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: BluetoothPrinterInput(
            name: bluetoothPrinter.deviceName,
            address: bluetoothPrinter.address!,
            isBle: bluetoothPrinter.isBle,
          ),
        );
        pendingTask = null;
        if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        bytes += generator.feed(2);
        bytes += generator.cut();
        await _printerManager.connect(
          type: bluetoothPrinter.typePrinter,
          model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!),
        );
        break;
      default:
    }
    if (bluetoothPrinter.typePrinter == PrinterType.bluetooth) {
      try {
        if (kDebugMode) {
          print('------$_currentStatus');
        }
        _printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
        pendingTask = null;
      } catch (_) {}
    } else {
      _printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _searchingMode
        ? SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.fontSizeLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('paper_size'.tr, style: robotoMedium),
                Row(children: [
                  Expanded(
                      child: RadioListTile(
                    title: Text('80_mm'.tr),
                    groupValue: _paper80MM,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: true,
                    onChanged: (bool? value) {
                      _paper80MM = true;
                      setState(() {});
                    },
                  )),
                  Expanded(
                      child: RadioListTile(
                    title: Text('58_mm'.tr),
                    groupValue: _paper80MM,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: false,
                    onChanged: (bool? value) {
                      _paper80MM = false;
                      setState(() {});
                    },
                  )),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                ListView.builder(
                  itemCount: _devices.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeSmall),
                      child: InkWell(
                        onTap: () {
                          _selectDevice(_devices[index]);
                          setState(() {
                            _searchingMode = false;
                          });
                        },
                        child: Stack(children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${_devices[index].deviceName}'),
                                Platform.isAndroid &&
                                        _defaultPrinterType == PrinterType.usb
                                    ? const SizedBox()
                                    : Visibility(
                                        visible: !Platform.isWindows,
                                        child:
                                            Text("${_devices[index].address}"),
                                      ),
                                index != _devices.length - 1
                                    ? Divider(
                                        color: Theme.of(context).disabledColor)
                                    : const SizedBox(),
                              ]),
                          (_selectedPrinter != null &&
                                  ((_devices[index].typePrinter ==
                                                  PrinterType.usb &&
                                              Platform.isWindows
                                          ? _devices[index].deviceName ==
                                              _selectedPrinter!.deviceName
                                          : _devices[index].vendorId != null &&
                                              _selectedPrinter!.vendorId ==
                                                  _devices[index].vendorId) ||
                                      (_devices[index].address != null &&
                                          _selectedPrinter!.address ==
                                              _devices[index].address)))
                              ? const Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Icon(Icons.check, color: Colors.green),
                                )
                              : const SizedBox(),
                        ]),
                      ),
                    );
                  },
                ),
                Visibility(
                  visible: _defaultPrinterType == PrinterType.network &&
                      Platform.isWindows,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      controller: _ipController,
                      keyboardType:
                          const TextInputType.numberWithOptions(signed: true),
                      decoration: InputDecoration(
                        label: Text('ip_address'.tr),
                        prefixIcon: const Icon(Icons.wifi, size: 24),
                      ),
                      onChanged: _setIpAddress,
                    ),
                  ),
                ),
                Visibility(
                  visible: _defaultPrinterType == PrinterType.network &&
                      Platform.isWindows,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      controller: _portController,
                      keyboardType:
                          const TextInputType.numberWithOptions(signed: true),
                      decoration: InputDecoration(
                        label: Text('port'.tr),
                        prefixIcon:
                            const Icon(Icons.numbers_outlined, size: 24),
                      ),
                      onChanged: _setPort,
                    ),
                  ),
                ),
                Visibility(
                  visible: _defaultPrinterType == PrinterType.network &&
                      Platform.isWindows,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: OutlinedButton(
                      onPressed: () async {
                        if (_ipController.text.isNotEmpty)
                          _setIpAddress(_ipController.text);
                        setState(() {
                          _searchingMode = false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 50),
                        child: Text("print_ticket".tr,
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        : InvoiceDialog(
            order: widget.order!,
            orderDetails: widget.orderDetails!,
            onPrint: (i.Image? image) => _printReceipt(image!),
          );
  }
}

class InvoiceDialog extends StatelessWidget {
  final OrderModel order;
  final List<OrderDetailsModel> orderDetails;
  final Function(i.Image image) onPrint;
  const InvoiceDialog(
      {required this.order, required this.orderDetails, required this.onPrint});

  String _priceDecimal(double price) {
    return price.toStringAsFixed(
        Get.find<SplashController>().configModel!.digitAfterDecimalPoint!);
  }

  @override
  Widget build(BuildContext context) {
    double fontSizeIncrease = 6;
    double _fontSize = window.physicalSize.width > 1000
        ? Dimensions.fontSizeExtraSmall
        : Dimensions.paddingSizeSmall;
    ScreenshotController _controller = ScreenshotController();
    Restaurant _restaurant =
        Get.find<AuthController>().profileModel!.restaurants![0];

    double _itemsPrice = 0;
    double _addOns = 0;

    for (OrderDetailsModel orderDetails in orderDetails) {
      for (AddOn addOn in orderDetails.addOns!) {
        _addOns = _addOns + (addOn.price! * addOn.quantity!);
      }
      _itemsPrice =
          _itemsPrice + (orderDetails.price! * orderDetails.quantity!);
    }

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                    spreadRadius: 1,
                    blurRadius: 5)
              ],
            ),
            width: 380,
            padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: SingleChildScrollView(
              child: Screenshot(
                controller: _controller,
                child: Container(
                  // color: Colors.white,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Image.asset(
                      Images.dinner,
                      height: 80,
                    ),
                    Text(
                      _restaurant.name!,
                      style: GoogleFonts.robotoMono(
                          fontSize: 16 + fontSizeIncrease,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      _restaurant.address!,
                      style: GoogleFonts.robotoMono(
                          fontSize: 10 + fontSizeIncrease),
                    ),
                    const SizedBox(
                      height: Dimensions.fontSizeDefault,
                    ),
                    Text(
                      order.orderType!.toUpperCase(),
                      style: GoogleFonts.robotoMono(
                          fontSize: 16 + fontSizeIncrease,
                          fontWeight: FontWeight.w500),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('order_id'.tr + ':',
                            style: GoogleFonts.robotoMono(
                                fontSize: 10 + fontSizeIncrease,
                                fontWeight: FontWeight.w500)),
                        Text(
                          order.id.toString(),
                          style: GoogleFonts.robotoMono(
                              fontSize: 9 + fontSizeIncrease),
                        ),
                      ],
                    ),
                    separator(),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.deliveryAddress!.contactPersonName!,
                            style: GoogleFonts.robotoMono(
                                fontSize: 12 + fontSizeIncrease),
                          ),
                          Text(
                            // '${order.deliveryAddress!.address!}, ${order.deliveryAddress!.house! ?? ' ' }',
                            '${order.deliveryAddress!.address!},',
                            style: GoogleFonts.robotoMono(
                                fontSize: 12 + fontSizeIncrease),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            'contact_customer_on'.tr,
                            style: GoogleFonts.robotoMono(
                                fontSize: 12 + fontSizeIncrease),
                          ),
                          Text(
                            order.deliveryAddress!.contactPersonNumber!,
                            style: GoogleFonts.robotoMono(
                                fontSize: 12 + fontSizeIncrease,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            'comments'.tr,
                            style: GoogleFonts.robotoMono(
                                fontSize: 12 + fontSizeIncrease),
                          ),
                          Text(
                            order.orderNote != null
                                ? '${order.orderNote}'
                                : 'no_comments'.tr,
                            style: GoogleFonts.robotoMono(
                                fontSize: 12 + fontSizeIncrease,
                                fontWeight: FontWeight.w500),
                          ),
                          // Text(
                          //   'Previous order',
                          //   style: GoogleFonts.robotoMono(fontSize: 10),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.paddingSizeSmall,
                    ),
                    separator(),
                    Text(
                      '${'requested_on'.tr}${DateConverter.orderTimeStringToMonthAndTime(order.scheduleAt!)}',
                      style: GoogleFonts.robotoMono(
                          fontSize: 10 + fontSizeIncrease,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: Dimensions.paddingSizeSmall,
                    ),
                    separator(),
                    ListView.builder(
                      itemCount: orderDetails.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                    '${orderDetails[index].quantity.toString()}x ',
                                    style: GoogleFonts.robotoMono(
                                        fontSize: 12 + fontSizeIncrease,
                                        fontWeight: FontWeight.w500)),
                                Text(orderDetails[index].foodDetails!.name!,
                                    style: GoogleFonts.robotoMono(
                                        fontSize: 12 + fontSizeIncrease,
                                        fontWeight: FontWeight.w500)),
                                Spacer(),
                                Text(
                                    orderDetails[index]
                                        .foodDetails!
                                        .price!
                                        .toString(),
                                    style: GoogleFonts.robotoMono(
                                        fontSize: 12 + fontSizeIncrease,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                            if (getAddonsText(orderDetails[index]).isNotEmpty)
                              Text(
                                getAddonsText(orderDetails[index]),
                                textAlign: TextAlign.left,
                                style: GoogleFonts.robotoMono(
                                    fontSize: 12 + fontSizeIncrease,
                                    fontWeight: FontWeight.w400),
                              ),
                            Text(
                              getVariationText(orderDetails[index]),
                              textAlign: TextAlign.left,
                              style: GoogleFonts.robotoMono(
                                fontSize: 12 + fontSizeIncrease,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    separator(),
                    PriceWidget(
                        title: 'item_price'.tr,
                        value: _priceDecimal(_itemsPrice),
                        fontSize: _fontSize + fontSizeIncrease),
                    PriceWidget(
                        title: 'add_ons'.tr,
                        value: _priceDecimal(_addOns),
                        fontSize: _fontSize + fontSizeIncrease),
                    PriceWidget(
                        title: 'discount'.tr,
                        value: _priceDecimal(order.restaurantDiscountAmount!),
                        fontSize: _fontSize + fontSizeIncrease),
                    PriceWidget(
                        title: 'delivery_fee'.tr,
                        value: _priceDecimal(order.deliveryCharge!),
                        fontSize: _fontSize + fontSizeIncrease),
                    separator(),
                    Text(
                      '${'total'.tr} = ${order.orderAmount}'.toUpperCase(),
                      style: GoogleFonts.robotoMono(
                          fontSize: 16 + fontSizeIncrease,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${'payment_method'.tr}: '.toUpperCase() +
                          "${order.paymentMethod}".tr.toUpperCase(),
                      style: GoogleFonts.robotoMono(
                          fontSize: 10 + fontSizeIncrease,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '**************',
                      style: GoogleFonts.robotoMono(
                          fontSize: 16 + fontSizeIncrease,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: Dimensions.paddingSizeSmall,
                    ),
                    Text(
                      'thanks_for_your_custom'.tr,
                      style: GoogleFonts.robotoMono(
                          fontSize: 12 + fontSizeIncrease,
                          fontWeight: FontWeight.w500),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: Dimensions.paddingSizeSmall),
        CustomButton(
            buttonText: 'print_invoice'.tr,
            height: 40,
            onPressed: () {
              // _controller
              //     .capture(delay: const Duration(milliseconds: 10))
              //     .then((capturedImage) async {
              //   ImageGallerySaver.saveImage(capturedImage);
              //   Get.back();
              // });
              _controller
                  .capture(delay: const Duration(milliseconds: 10))
                  .then((capturedImage) async {
                Get.back();
                onPrint(i.decodeImage(capturedImage!)!);
              }).catchError((onError) {
                print(onError);
              });
            }),
      ]),
    );
  }

  Row totalLine() {
    return Row(
      children: List.generate(
          20 ~/ 10,
          (index) => Expanded(
                child: Container(
                  color: index % 2 == 0 ? Colors.transparent : Colors.grey,
                  height: 2,
                ),
              )),
    );
  }

  Row separator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('-',
            style: GoogleFonts.robotoMono(
                fontSize: 10, fontWeight: FontWeight.w500)),
        Spacer(),
        Text(
          '-',
          style: GoogleFonts.robotoMono(fontSize: 9),
        ),
      ],
    );
  }

  Row dotsLine() {
    return Row(
      children: List.generate(
          515 ~/ 10,
          (index) => Expanded(
                child: Container(
                  color: index % 2 == 0 ? Colors.transparent : Colors.grey,
                  height: 2,
                ),
              )),
    );
  }

  String getVariationText(OrderDetailsModel orderDetails) {
    String variationText = '';
     if(orderDetails.variation!.isNotEmpty) {
                    for(Variation variation in orderDetails.variation!) {
                      variationText = '${variationText}${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';
                      for(VariationOption value in variation.variationValues!) {
                        variationText = '${variationText}${variationText.endsWith('(') ? '' : ', '}${value.level}';
                      }
                      variationText = '${variationText})';
                    }
                  }else if(orderDetails.oldVariation!.isNotEmpty) {
                    variationText = orderDetails.oldVariation![0].type!;
                  }
    // else if (orderDetails.oldVariation!.length > 0) {
    //   List<String> _variationTypes =
    //       orderDetails.oldVariation![0].type!.split('-');
    //   // if (_variationTypes.length ==
    //   //     orderDetails.foodDetails!.choiceOptions.length) {
    //   //   int _index = 0;
    //   //   orderDetails.foodDetails.choiceOptions.forEach((choice) {
    //   //     _variationText = _variationText +
    //   //         '${(_index == 0) ? '' : ',  '}${choice.title} - ${_variationTypes[_index]}';
    //   //     _index = _index + 1;
    //   //   });
    //   // } 
    //   else {
    //     _variationText = orderDetails.oldVariation![0].type!;
    //   }
    // }
    return variationText;
  }

  String getAddonsText(OrderDetailsModel orderDetails) {
    String _addOnText = '';
    orderDetails.addOns!.forEach((addOn) {
      _addOnText = _addOnText +
          '${(_addOnText.isEmpty) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
    });
    return _addOnText;
  }
}

class PriceWidget extends StatelessWidget {
  final String title;
  final String value;
  final double fontSize;
  const PriceWidget({
    required this.title,
    required this.value,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('$title:',
          style: GoogleFonts.robotoMono(
              fontSize: fontSize, fontWeight: FontWeight.w400)),
      Text(value,
          style: GoogleFonts.robotoMono(
              fontSize: fontSize, fontWeight: FontWeight.w400)),
    ]);
  }
}
