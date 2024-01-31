import 'package:efood_multivendor_restaurant/data/api/api_client.dart';
import 'package:efood_multivendor_restaurant/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class PosRepo {
  final ApiClient apiClient;
  PosRepo({required this.apiClient});

  Future<Response> searchProductList(String searchText) async {
    return await apiClient.postData(AppConstants.searchProductListUri, {'name': searchText});
  }

  Future<Response> searchCustomerList(String searchText) async {
    return await apiClient.getData('${AppConstants.searchCustomersUri}?search=$searchText');
  }

  Future<Response> placeOrder(String searchText) async {
    return await apiClient.postData(AppConstants.placeOrderUri, {});
  }

  Future<Response> getPosOrders() async {
    return await apiClient.getData(AppConstants.posOrdersUri);
  }

}