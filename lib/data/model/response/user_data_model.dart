class UserDataModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<Data>? data;

  UserDataModel({this.totalSize, this.limit, this.offset, this.data});

  UserDataModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? fName;
  String? lName;
  String? image;
  String? phone;
  String? email;
  int? userId;
  int? vendorId;
  int? deliverymanId;

  Data({
    this.id,
    this.fName,
    this.lName,
    this.image,
    this.phone,
    this.email,
    this.userId,
    this.vendorId,
    this.deliverymanId,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['fName'];
    lName = json['lName'];
    image = json['image'];
    phone = json['phone'];
    email = json['email'];
    userId = json['user_id'];
    vendorId = json['vendor_id'];
    deliverymanId = json['deliveryman_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fName'] = fName;
    data['lName'] = lName;
    data['image'] = image;
    data['phone'] = phone;
    data['email'] = email;
    data['user_id'] = userId;
    data['vendor_id'] = vendorId;
    data['deliveryman_id'] = deliverymanId;

    return data;
  }
}