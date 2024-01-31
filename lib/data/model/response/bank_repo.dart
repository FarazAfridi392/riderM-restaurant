import 'package:efood_multivendor_restaurant/data/api/api_client.dart';
import 'package:efood_multivendor_restaurant/data/model/body/bank_info_body.dart';
import 'package:efood_multivendor_restaurant/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class BankRepo {
  final ApiClient apiClient;
  BankRepo({required this.apiClient});
  
  Future<Response> updateBankInfo(BankInfoBody bankInfoBody) async {
    return await apiClient.putData(AppConstants.updateBankInfoUri, bankInfoBody.toJson());
  }

  Future<Response> getWithdrawList() async {
    return await apiClient.getData(AppConstants.withdrawListUri);
  }

  Future<Response> requestWithdraw(Map<String?, String> data) async {
    return await apiClient.postData(AppConstants.withdrawRequestUri, data);
  }

  Future<Response> getWithdrawMethodList() async {
    return await apiClient.getData(AppConstants.withdrawRequestMethodUri);
  }

}