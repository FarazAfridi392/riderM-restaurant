
class ChatListModel {
  int? totalSize;
  int? limit;
  int? offset;
  MessagesData? messagesData;

  ChatListModel({this.totalSize, this.limit, this.offset, this.messagesData});

  ChatListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    messagesData = json['messages'] != null
        ? MessagesData.fromJson(json['messages'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (messagesData != null) {
      data['messages'] = messagesData!.toJson();
    }
    return data;
  }
}

class MessagesData {
  int? currentPage;
  List<Data>? data;

  MessagesData({this.currentPage, this.data});

  MessagesData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? orderId;
  int? userId;
  int? conversationsCount;
  Customer? customer;

  Data({this.orderId, this.userId, this.conversationsCount, this.customer});

  Data.fromJson(Map<String, dynamic> json) {
    orderId = json['id'];
    userId = json['user_id'];
    conversationsCount = json['conversations_count'];
    customer = json['customer'] != null
        ? Customer.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = orderId;
    data['user_id'] = userId;
    data['conversations_count'] = conversationsCount;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    return data;
  }
}

class Customer {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? image;
  String? createdAt;
  String? updatedAt;
  int? loyaltyPoint;
  String? refCode;

  Customer(
      {this.id,
        this.fName,
        this.lName,
        this.phone,
        this.email,
        this.image,
        this.createdAt,
        this.updatedAt,
        this.loyaltyPoint,
        this.refCode});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    loyaltyPoint = json['loyalty_point'];
    refCode = json['ref_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['loyalty_point'] = loyaltyPoint;
    data['ref_code'] = refCode;
    return data;
  }
}

/*
class ChatList {
  int totalSize;
  int limit;
  int offset;
  List<Users> users;

  ChatList({this.totalSize, this.limit, this.offset, this.users});

  ChatList.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['messages'] != null) {
      users = <Users>[];
      json['messages'].forEach((v) {
        users.add(new Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_size'] = this.totalSize;
    data['limit'] = this.limit;
    data['offset'] = this.offset;
    if (this.users != null) {
      data['messages'] = this.users.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Users {
  int id;
  int userId;
  int adminId;
  int restaurantId;
  int deliverymanId;
  int orderId;
  String message;
  int checked;
  List<String> image;
  int isReply;
  String createdAt;
  String updatedAt;
  User user;

  Users(
      {this.id,
        this.userId,
        this.adminId,
        this.restaurantId,
        this.deliverymanId,
        this.orderId,
        this.message,
        this.checked,
        this.image,
        this.isReply,
        this.createdAt,
        this.updatedAt,
        this.user});

  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    adminId = json['admin_id'];
    restaurantId = json['restaurant_id'];
    deliverymanId = json['deliveryman_id'];
    orderId = json['order_id'];
    message = json['message'];
    checked = json['checked'];
    if(json['image']!=null){
      image = json['image'].cast<String>();
    }
    isReply = json['is_reply'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['admin_id'] = this.adminId;
    data['restaurant_id'] = this.restaurantId;
    data['deliveryman_id'] = this.deliverymanId;
    data['order_id'] = this.orderId;
    data['message'] = this.message;
    data['checked'] = this.checked;
    data['image'] = this.image;
    data['is_reply'] = this.isReply;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}

class User {
  String name;
  String image;

  User({this.name, this.image});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['image'] = this.image;
    return data;
  }
}*/
