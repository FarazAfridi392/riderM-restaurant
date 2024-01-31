import 'package:efood_multivendor_restaurant/controller/bank_controller.dart';
import 'package:efood_multivendor_restaurant/helper/date_converter.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_button.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_snackbar.dart';
import 'package:efood_multivendor_restaurant/view/base/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WithdrawRequestBottomSheet extends StatefulWidget {
  const WithdrawRequestBottomSheet({Key? key}) : super(key: key);

  @override
  State<WithdrawRequestBottomSheet> createState() => _WithdrawRequestBottomSheetState();
}

class _WithdrawRequestBottomSheetState extends State<WithdrawRequestBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    Get.find<BankController>().setMethod(isUpdate: false);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
      ),
      child: GetBuilder<BankController>(
        builder: (bankController) {

          return SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              Text('withdraw'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              Image.asset(Images.bank, height: 30, width: 30),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              DropdownButton(
                value: bankController.methodIndex,
                  items: bankController.methodList,
                  onChanged: (int? index){
                    bankController.setMethodIndex(index);
                    bankController.setMethod();
                  },
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: bankController.methodFields.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Column(children: [

                    Row(
                      children: [
                        Expanded(
                          child: MyTextField(
                            titleName: bankController.methodFields[index].inputName.toString().replaceAll('_', ' '),
                            hintText: bankController.methodFields[index].placeholder,
                            controller: bankController.textControllerList[index],
                            capitalization: TextCapitalization.words,
                            inputType: bankController.methodFields[index].inputType == 'phone' ? TextInputType.phone : bankController.methodFields[index].inputType == 'number'
                                ? TextInputType.number : bankController.methodFields[index].inputType == 'email' ? TextInputType.emailAddress : TextInputType.name,
                            focusNode: bankController.focusList[index],
                            nextFocus: index != bankController.methodFields.length-1 ? bankController.focusList[index + 1] : _amountFocus,
                            isRequired: bankController.methodFields[index].isRequired == 1,
                          ),
                        ),

                        bankController.methodFields[index].inputType == 'date' ?
                          IconButton(
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                String formattedDate = DateConverter.dateTimeForCoupon(pickedDate);
                                setState(() {
                                  bankController.textControllerList[index].text = formattedDate;
                                });
                              }

                            },
                            icon: const Icon(Icons.date_range_sharp),
                          )
                  // bankController.selectDate(context),
                        // bankController.textControllerList[index].text = DateConverter.estimatedDate();

                            : const SizedBox(),
                      ],
                    ),
                    SizedBox(height: index != bankController.methodFields.length-1 ? Dimensions.paddingSizeLarge : 0),

                ]);
              }),

              // Text('enter_amount'.tr, style: robotoBold.copyWith(color: Theme.of(context).disabledColor)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              MyTextField(
                hintText: 'enter_amount'.tr,
                controller: _amountController,
                capitalization: TextCapitalization.words,
                inputType: TextInputType.number,
                focusNode: _amountFocus,
                inputAction: TextInputAction.done,
                isRequired: true,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),


              !bankController.isLoading ? CustomButton(
                buttonText: 'withdraw'.tr,
                onPressed: () {
                  bool fieldEmpty = false;
                  for (var element in bankController.methodFields) {
                    if(element.isRequired == 1){
                      if(bankController.textControllerList[bankController.methodFields.indexOf(element)].text.isEmpty){
                        fieldEmpty = true;
                      }
                    }
                  }

                  if(fieldEmpty){
                    showCustomSnackBar('required_fields_can_not_be_empty'.tr);
                  }else if(_amountController.text.trim().isEmpty){
                    showCustomSnackBar('enter_amount'.tr);
                  }else{
                    Map<String?, String> data = {};
                    data['id'] = bankController.widthDrawMethods![bankController.methodIndex!].id.toString();
                    data['amount'] = _amountController.text.trim();
                    for (var result in bankController.methodFields) {
                      data[result.inputName] = bankController.textControllerList[bankController.methodFields.indexOf(result)].text.trim();
                    }
                    bankController.requestWithdraw(data);
                  }

                },
              ) : const Center(child: CircularProgressIndicator()),

            ]),
          );
        }
      ),
    );
  }
}
