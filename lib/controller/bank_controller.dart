import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/data/api/api_checker.dart';
import 'package:efood_multivendor_restaurant/data/model/body/bank_info_body.dart';
import 'package:efood_multivendor_restaurant/data/model/response/bank_repo.dart';
import 'package:efood_multivendor_restaurant/data/model/response/widthdrow_method_model.dart';
import 'package:efood_multivendor_restaurant/data/model/response/withdraw_model.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BankController extends GetxController implements GetxService {
  final BankRepo bankRepo;
  BankController({required this.bankRepo});

  bool _isLoading = false;
  List<WithdrawModel>? _withdrawList;
  late List<WithdrawModel> _allWithdrawList;
  double _pendingWithdraw = 0;
  double _withdrawn = 0;
  final List<String> _statusList = ['All', 'Pending', 'Approved', 'Denied'];
  int _filterIndex = 0;
  List<WidthDrawMethodModel>? _widthDrawMethods;
  int? _methodIndex = 0;
  List<DropdownMenuItem<int>> _methodList = [];
  List<TextEditingController> _textControllerList = [];
  List<MethodFields> _methodFields = [];
  List<FocusNode> _focusList = [];

  bool get isLoading => _isLoading;
  List<WithdrawModel>? get withdrawList => _withdrawList;
  double get pendingWithdraw => _pendingWithdraw;
  double get withdrawn => _withdrawn;
  List<String> get statusList => _statusList;
  int get filterIndex => _filterIndex;
  List<WidthDrawMethodModel>? get widthDrawMethods => _widthDrawMethods;
  int? get methodIndex => _methodIndex;
  List<DropdownMenuItem<int>> get methodList => _methodList;
  List<TextEditingController> get textControllerList => _textControllerList;
  List<MethodFields> get methodFields => _methodFields;
  List<FocusNode> get focusList => _focusList;

  void setMethod({bool isUpdate = true}){
    _methodList = [];
    _textControllerList = [];
    _methodFields = [];
    _focusList = [];
    if(widthDrawMethods != null && widthDrawMethods!.isNotEmpty){
      for(int i=0; i< widthDrawMethods!.length; i++){
        _methodList.add(DropdownMenuItem<int>(value: i, child: SizedBox(
          width: Get.context!.width-100,
          child: Text(widthDrawMethods![i].methodName!, style: robotoBold),
        )));
      }

      _textControllerList = [];
      _methodFields = [];
      for (var field in widthDrawMethods![_methodIndex!].methodFields!) {
        _methodFields.add(field);
        _textControllerList.add(TextEditingController());
        _focusList.add(FocusNode());
      }
    }
    if(isUpdate) {
      update();
    }
  }

  Future<void> updateBankInfo(BankInfoBody bankInfoBody) async {
    _isLoading = true;
    update();
    Response response = await bankRepo.updateBankInfo(bankInfoBody);
    if(response.statusCode == 200) {
     Get.find<AuthController>().getProfile();
     Get.back();
     showCustomSnackBar('bank_info_updated'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> getWithdrawList() async {
    Response response = await bankRepo.getWithdrawList();
    if(response.statusCode == 200) {
      _withdrawList = [];
      _allWithdrawList = [];
      _pendingWithdraw = 0;
      _withdrawn = 0;
      response.body.forEach((withdraw) {
        WithdrawModel withdrawModel = WithdrawModel.fromJson(withdraw);
        _withdrawList!.add(withdrawModel);
        _allWithdrawList.add(withdrawModel);
        if(withdrawModel.status == 'Pending') {
          _pendingWithdraw = _pendingWithdraw + withdrawModel.amount!;
        }else if(withdrawModel.status == 'Approved') {
          _withdrawn = _withdrawn + withdrawModel.amount!;
        }
      });
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getWithdrawMethodList() async {
    Response response = await bankRepo.getWithdrawMethodList();
    if(response.statusCode == 200) {
      _widthDrawMethods = [];
      response.body.forEach((method) {
        WidthDrawMethodModel withdrawMethod = WidthDrawMethodModel.fromJson(method);
        _widthDrawMethods!.add(withdrawMethod);
      });
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void setMethodIndex(int? index) {
    _methodIndex = index;
    // update();
  }

  void filterWithdrawList(int index) {
    _filterIndex = index;
    _withdrawList = [];
    if(index == 0) {
      _withdrawList!.addAll(_allWithdrawList);
    }else {
      for (var withdraw in _allWithdrawList) {
        if(withdraw.status == _statusList[index]) {
          _withdrawList!.add(withdraw);
        }
      }
    }
    update();
  }

  Future<void> requestWithdraw(Map<String?, String> data) async {
    _isLoading = true;
    update();
    Response response = await bankRepo.requestWithdraw(data);
    if(response.statusCode == 200) {
      Get.back();
      getWithdrawList();
      Get.find<AuthController>().getProfile();
      showCustomSnackBar('request_sent_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

}