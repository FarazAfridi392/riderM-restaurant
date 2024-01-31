import 'package:efood_multivendor_restaurant/view/screens/auth/business_plan/widgets/registration_stepper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class RegistrationStepperWidget extends StatelessWidget {
  final String status;
  const RegistrationStepperWidget({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int state = 0;
     if(status == 'business') {
       state = 1;
    }else if(status == 'payment') {
       state = 2;
    }else if(status == 'complete') {
       state = 3;
    }
    return Row(children: [
      RegistrationStepper(
        title: 'general_information'.tr, isActive: true, haveLeftBar: false, haveRightBar: true, rightActive: true, onGoing: state == 0,
      ),
      RegistrationStepper(
        title: 'business_plan'.tr, isActive: state > 1, haveLeftBar: true, haveRightBar: true, rightActive: state > 1, onGoing: state == 1, processing: state != 3 && state != 0,
      ),
      RegistrationStepper(
        title: 'complete'.tr, isActive: state == 3, haveLeftBar: true, haveRightBar: false, rightActive: state == 3,
      ),
    ]);
  }
}
