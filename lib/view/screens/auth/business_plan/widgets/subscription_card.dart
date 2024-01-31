import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/package_model.dart';
import 'package:efood_multivendor_restaurant/helper/price_converter.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

class SubscriptionCard extends StatelessWidget {
  final int index;
  final Packages package;
  final AuthController authController;
  final Color color;
  const SubscriptionCard({Key? key, required this.index, required this.package, required this.authController, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

      ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusLarge), topRight: Radius.circular(Dimensions.radiusLarge)),
        child: Stack(
          children: [

            ClipPath(
              clipper: CurveClipper(),
              child: Container(
              color: color.withOpacity(0.3),
              height: 140.0,
              ),
            ),

            ClipPath(
              clipper: CurveClipper(),
              child: Container(
                color: color.withOpacity(0.2),
                height: 160.0,
              ),
            ),

            // ClipPath(
            //   clipper: CurveClipper(),
            //   child: Container(
            //     alignment: Alignment.center,
            //     color: color.withOpacity(1), height: 120.0, width: double.infinity,
            //     child: Text('${package.packageName}', style: robotoBold.copyWith(fontSize: Dimensions.FONT_SIZE_OVER_LARGE, color: Theme.of(context).cardColor)),
            //   ),
            // ),

            ClipPath(
              clipper: CurveClipper(),
              child: Stack(
                children: [
                  SizedBox(
                    height: 120, width: size.width,
                    child: Container(
                      color: color.withOpacity(1),
                      height: 120.0,
                    ),
                  ),
                  Positioned(
                    child: SizedBox(
                      height: 120, width: size.width,
                      child: CustomPaint(
                        painter: const CardPaint(color: Colors.white),
                        child: Center(
                          child: Text(
                            '${package.packageName}',
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).cardColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ]),
      ),

      const SizedBox(height: Dimensions.paddingSizeDefault),

      Text(
        PriceConverter.convertPrice(package.price), textDirection: TextDirection.ltr,
        style: robotoBold.copyWith(fontSize: 35, color: color),
      ),

      Text('${package.validity} ' 'days'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      Divider(color: color, indent: 70, endIndent: 70, thickness: 2),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        packageWidget(title: '${'max_order'.tr} (${package.maxOrder})'),

        packageWidget(title: '${'max_product'.tr} (${package.maxProduct})'),

        package.pos != 0 ? packageWidget(title: 'pos'.tr) : const SizedBox(),

        package.mobileApp != 0 ? packageWidget(title: 'mobile_app_access'.tr) : const SizedBox(),

        package.chat != 0 ? packageWidget(title: 'chat'.tr) : const SizedBox(),

        package.review != 0 ? packageWidget(title: 'review'.tr) : const SizedBox(),

        package.selfDelivery != 0 ? packageWidget(title: 'self_delivery'.tr) : const SizedBox(),
      ]),

    ]);
  }

  Widget packageWidget({ required String title}){
    return Column(children: [
      Padding(
        padding: EdgeInsets.only(left: MediaQuery.of(Get.context!).size.width * 0.15),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          const Icon(Icons.check_circle, size: 18, color: Colors.green),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Text(title, style: robotoMedium),
        ]),
      ),

      Divider(indent: 50, endIndent: 50, color: Theme.of(Get.context!).dividerColor,thickness: 1,)
    ]);
  }
}



class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    int curveHeight = 40;
    Offset controlPoint = Offset(size.width / 2, size.height + curveHeight);
    Offset endPoint = Offset(size.width, size.height - curveHeight);

    Path path = Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CardPaint extends CustomPainter{
  final Color color;
  const CardPaint({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = ui.Gradient.linear(
          Offset(0, size.height),
          Offset( size.width*0.4, size.height*0.6),
          [Colors.white10, Colors.white12])
      ..style = PaintingStyle.fill;

    Path path = Path()..moveTo(0, size.height*0.7)
      ..quadraticBezierTo(size.width*0.2, size.height*0.2, size.width*0.4, size.height*0.4)
      ..quadraticBezierTo(size.width*0.6, size.height*0.6, size.width*0.7, size.height*0.3)
      ..quadraticBezierTo(size.width*0.8, size.height*0.1, size.width*0.85, size.height*0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    Path path1 = Path()..moveTo(0, size.height)
      ..quadraticBezierTo(size.width*0.25, size.height*0.5, size.width*0.5, size.height*0.68)
      ..quadraticBezierTo(size.width*0.65, size.height*0.75, size.width*0.7, size.height*0.68)
      ..quadraticBezierTo(size.width*0.85, size.height*0.51, size.width*0.9, size.height*0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path1, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}
