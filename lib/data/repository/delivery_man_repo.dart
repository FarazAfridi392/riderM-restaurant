
import 'package:efood_multivendor_restaurant/data/api/api_client.dart';
import 'package:efood_multivendor_restaurant/data/model/response/delivery_man_model.dart';
import 'package:efood_multivendor_restaurant/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DeliveryManRepo {
  final ApiClient apiClient;
  DeliveryManRepo({required this.apiClient});
  
  Future<Response> getDeliveryManList() async {
    return await apiClient.getData(AppConstants.dmListUri);
  }

  Future<Response> addDeliveryMan(DeliveryManModel deliveryMan, String pass, XFile? image, List<XFile> identities, String token, bool isAdd) async {
    List<MultipartBody> images = [];
    if(GetPlatform.isMobile && image != null) {
      images.add(MultipartBody('image', image));
    }
    if(GetPlatform.isMobile && identities.isNotEmpty) {
      for (var identity in identities) {
        images.add(MultipartBody('identity_image[]', identity));
      }
    }
    Map<String, String> fields = {};
    fields.addAll(<String, String>{
      'f_name': deliveryMan.fName!, 'l_name': deliveryMan.lName!, 'email': deliveryMan.email!, 'password': pass,
      'phone': deliveryMan.phone!, 'identity_type': deliveryMan.identityType!, 'identity_number': deliveryMan.identityNumber!,
    });
    return await apiClient.postMultipartData(isAdd ? AppConstants.addDmUri : '${AppConstants.updateDmUri}${deliveryMan.id}', fields, images);
  }

  Future<Response> updateDeliveryMan(DeliveryManModel deliveryManModel) async {
    return await apiClient.postData('${AppConstants.updateDmUri}${deliveryManModel.id}', deliveryManModel.toJson());
  }

  Future<Response> deleteDeliveryMan(int? deliveryManID) async {
    return await apiClient.postData(AppConstants.deleteDmUri, {'_method': 'delete', 'delivery_man_id': deliveryManID});
  }

  Future<Response> updateDeliveryManStatus(int? deliveryManID, int status) async {
    return await apiClient.getData('${AppConstants.updateDmStatusUri}?delivery_man_id=$deliveryManID&status=$status');
  }

  Future<Response> getDeliveryManReviews(int? deliveryManID) async {
    return await apiClient.getData('${AppConstants.dmReviewUri}?delivery_man_id=$deliveryManID');
  }

}