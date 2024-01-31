import 'package:efood_multivendor_restaurant/data/model/response/product_model.dart';

class ProfileModel {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? createdAt;
  String? updatedAt;
  String? bankName;
  String? branch;
  String? holderName;
  String? accountNo;
  String? image;
  int? orderCount;
  int? todaysOrderCount;
  int? thisWeekOrderCount;
  int? thisMonthOrderCount;
  int? memberSinceDays;
  double? cashInHands;
  double? balance;
  double? totalEarning;
  double? todaysEarning;
  double? thisWeekEarning;
  double? thisMonthEarning;
  List<Restaurant>? restaurants;
  Subscription? subscription;
  SubscriptionOtherData? subscriptionOtherData;
  List<Translation>? translations;

  ProfileModel(
      {this.id,
        this.fName,
        this.lName,
        this.phone,
        this.email,
        this.createdAt,
        this.updatedAt,
        this.bankName,
        this.branch,
        this.holderName,
        this.accountNo,
        this.image,
        this.orderCount,
        this.todaysOrderCount,
        this.thisWeekOrderCount,
        this.thisMonthOrderCount,
        this.memberSinceDays,
        this.cashInHands,
        this.balance,
        this.totalEarning,
        this.todaysEarning,
        this.thisWeekEarning,
        this.thisMonthEarning,
        this.restaurants,
        this.subscription,
        this.subscriptionOtherData,
        this.translations,
      });

  ProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    bankName = json['bank_name'];
    branch = json['branch'];
    holderName = json['holder_name'];
    accountNo = json['account_no'];
    image = json['image'];
    orderCount = json['order_count'];
    todaysOrderCount = json['todays_order_count'];
    thisWeekOrderCount = json['this_week_order_count'];
    thisMonthOrderCount = json['this_month_order_count'];
    memberSinceDays = json['member_since_days'];
    cashInHands = json['cash_in_hands'].toDouble();
    balance = json['balance'].toDouble();
    totalEarning = json['total_earning'].toDouble();
    todaysEarning = json['todays_earning'].toDouble();
    thisWeekEarning = json['this_week_earning'].toDouble();
    thisMonthEarning = json['this_month_earning'].toDouble();
    if (json['restaurants'] != null) {
      restaurants = [];
      json['restaurants'].forEach((v) {
        restaurants!.add(Restaurant.fromJson(v));
      });
    }
    if (json['subscription'] != null) {
      subscription = Subscription.fromJson(json['subscription']);
    }
    subscriptionOtherData = json['subscription_other_data'] != null ? SubscriptionOtherData.fromJson(json['subscription_other_data']) : null;
    if (json['translations'] != null) {
      translations = [];
      json['translations'].forEach((v) {
        translations!.add(Translation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['bank_name'] = bankName;
    data['branch'] = branch;
    data['holder_name'] = holderName;
    data['account_no'] = accountNo;
    data['image'] = image;
    data['order_count'] = orderCount;
    data['todays_order_count'] = todaysOrderCount;
    data['this_week_order_count'] = thisWeekOrderCount;
    data['this_month_order_count'] = thisMonthOrderCount;
    data['member_since_days'] = memberSinceDays;
    data['cash_in_hands'] = cashInHands;
    data['balance'] = balance;
    data['total_earning'] = totalEarning;
    data['todays_earning'] = todaysEarning;
    data['this_week_earning'] = thisWeekEarning;
    data['this_month_earning'] = thisMonthEarning;
    if (restaurants != null) {
      data['restaurants'] = restaurants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Restaurant {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? logo;
  String? latitude;
  String? longitude;
  String? address;
  double? minimumOrder;
  bool? scheduleOrder;
  String? currency;
  String? createdAt;
  String? updatedAt;
  bool? freeDelivery;
  String? coverPhoto;
  bool? delivery;
  bool? takeAway;
  bool? orderSubscriptionActive;
  double? tax;
  bool? reviewsSection;
  bool? foodSection;
  String? availableTimeStarts;
  String? availableTimeEnds;
  double? avgRating;
  int? ratingCount;
  bool? active;
  bool? gstStatus;
  String? gstCode;
  int? selfDeliverySystem;
  bool? posSystem;
  double? minimumShippingCharge;
  double? maximumShippingCharge;
  double? perKmShippingCharge;
  String? restaurantModel;
  int? veg;
  int? nonVeg;
  Discount? discount;
  List<Schedules>? schedules;
  String? deliveryTime;
  List<Cuisine>? cuisines;
  bool? cutlery;
  List<Translation>? translations;
  String? metaTitle;
  String? metaDescription;
  String? metaKeyWord;

  Restaurant(
      {this.id,
        this.name,
        this.phone,
        this.email,
        this.logo,
        this.latitude,
        this.longitude,
        this.address,
        this.minimumOrder,
        this.scheduleOrder,
        this.currency,
        this.createdAt,
        this.updatedAt,
        this.freeDelivery,
        this.coverPhoto,
        this.delivery,
        this.takeAway,
        this.orderSubscriptionActive,
        this.tax,
        this.reviewsSection,
        this.foodSection,
        this.availableTimeStarts,
        this.availableTimeEnds,
        this.avgRating,
        this.ratingCount,
        this.active,
        this.gstStatus,
        this.gstCode,
        this.selfDeliverySystem,
        this.posSystem,
        this.minimumShippingCharge,
        this.maximumShippingCharge,
        this.perKmShippingCharge,
        this.restaurantModel,
        this.veg,
        this.nonVeg,
        this.discount,
        this.schedules,
        this.deliveryTime,
        this.cuisines,
        this.cutlery,
        this.translations,
        this.metaTitle,
        this.metaDescription,
        this.metaKeyWord,
      });

  Restaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    logo = json['logo'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    minimumOrder = json['minimum_order'].toDouble();
    scheduleOrder = json['schedule_order'];
    currency = json['currency'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    freeDelivery = json['free_delivery'];
    coverPhoto = json['cover_photo'];
    delivery = json['delivery'];
    takeAway = json['take_away'];
    orderSubscriptionActive = json['order_subscription_active'];
    tax = json['tax'].toDouble();
    reviewsSection = json['reviews_section'];
    foodSection = json['food_section'];
    availableTimeStarts = json['available_time_starts'];
    availableTimeEnds = json['available_time_ends'];
    avgRating = json['avg_rating'].toDouble();
    ratingCount = json['rating_count '];
    active = json['active'];
    gstStatus = json['gst_status'];
    gstCode = json['gst_code'];
    selfDeliverySystem = json['self_delivery_system'];
    posSystem = json['pos_system'];
    minimumShippingCharge = json['minimum_shipping_charge']?.toDouble();
    maximumShippingCharge = json['maximum_shipping_charge']?.toDouble();
    perKmShippingCharge = json['per_km_shipping_charge']?.toDouble();
    restaurantModel = json['restaurant_model'];
    veg = json['veg'];
    nonVeg = json['non_veg'];
    discount = json['discount'] != null ? Discount.fromJson(json['discount']) : null;
    if (json['schedules'] != null) {
      schedules = <Schedules>[];
      json['schedules'].forEach((v) {
        schedules!.add(Schedules.fromJson(v));
      });
    }
    deliveryTime = json['delivery_time'];
    if (json['cuisine'] != null) {
      cuisines = <Cuisine>[];
      json['cuisine'].forEach((v) {
        cuisines!.add(Cuisine.fromJson(v));
      });
    }
    cutlery = json['cutlery'];
    if (json['translations'] != null) {
      translations = [];
      json['translations'].forEach((v) {
        translations!.add(Translation.fromJson(v));
      });
    }
    metaTitle = json['meta_title'];
    metaDescription = json['meta_description'];
    metaKeyWord = json['meta_key_word'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['logo'] = logo;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address'] = address;
    data['minimum_order'] = minimumOrder;
    data['schedule_order'] = scheduleOrder;
    data['currency'] = currency;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['free_delivery'] = freeDelivery;
    data['cover_photo'] = coverPhoto;
    data['delivery'] = delivery;
    data['take_away'] = takeAway;
    data['order_subscription_active'] = orderSubscriptionActive;
    data['tax'] = tax;
    data['reviews_section'] = reviewsSection;
    data['food_section'] = foodSection;
    data['available_time_starts'] = availableTimeStarts;
    data['available_time_ends'] = availableTimeEnds;
    data['avg_rating'] = avgRating;
    data['rating_count '] = ratingCount;
    data['active'] = active;
    data['gst_status'] = gstStatus;
    data['gst_code'] = gstCode;
    data['self_delivery_system'] = selfDeliverySystem;
    data['pos_system'] = posSystem;
    data['minimum_shipping_charge'] = minimumShippingCharge;
    data['maximum_shipping_charge'] = maximumShippingCharge;
    data['per_km_shipping_charge'] = perKmShippingCharge;
    data['restaurant_model'] = restaurantModel;
    data['veg'] = veg;
    data['non_veg'] = nonVeg;
    if (discount != null) {
      data['discount'] = discount!.toJson();
    }
    if (schedules != null) {
      data['schedules'] = schedules!.map((v) => v.toJson()).toList();
    }
    data['delivery_time'] = deliveryTime;
    if (cuisines != null) {
      data['cuisine'] = cuisines!.map((v) => v.toJson()).toList();
    }
    data['cutlery'] = cutlery;
    data['meta_title'] = metaTitle;
    data['meta_description'] = metaDescription;
    data['meta_key_word'] = metaKeyWord;
    return data;
  }
}

class Cuisine {
  int? id;
  String? name;
  String? image;
  int? status;
  String? slug;
  String? createdAt;
  String? updatedAt;
  Pivot? pivot;

  Cuisine(
      {this.id,
        this.name,
        this.image,
        this.status,
        this.slug,
        this.createdAt,
        this.updatedAt,
        this.pivot});

  Cuisine.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    status = json['status'];
    slug = json['slug'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['status'] = status;
    data['slug'] = slug;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? restaurantId;
  int? cuisineId;

  Pivot({this.restaurantId, this.cuisineId});

  Pivot.fromJson(Map<String, dynamic> json) {
    restaurantId = int.parse(json['restaurant_id'].toString());
    cuisineId = int.parse(json['cuisine_id'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['restaurant_id'] = restaurantId;
    data['cuisine_id'] = cuisineId;
    return data;
  }
}

class Discount {
  int? id;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  double? minPurchase;
  double? maxDiscount;
  double? discount;
  String? discountType;
  int? restaurantId;
  String? createdAt;
  String? updatedAt;

  Discount(
      {this.id,
        this.startDate,
        this.endDate,
        this.startTime,
        this.endTime,
        this.minPurchase,
        this.maxDiscount,
        this.discount,
        this.discountType,
        this.restaurantId,
        this.createdAt,
        this.updatedAt});

  Discount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    minPurchase = json['min_purchase'].toDouble();
    maxDiscount = json['max_discount'].toDouble();
    discount = json['discount'].toDouble();
    discountType = json['discount_type'];
    restaurantId = json['restaurant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['min_purchase'] = minPurchase;
    data['max_discount'] = maxDiscount;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['restaurant_id'] = restaurantId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Schedules {
  int? id;
  int? restaurantId;
  int? day;
  String? openingTime;
  String? closingTime;

  Schedules(
      {this.id,
        this.restaurantId,
        this.day,
        this.openingTime,
        this.closingTime});

  Schedules.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    day = json['day'];
    openingTime = json['opening_time'].substring(0, 5);
    closingTime = json['closing_time'].substring(0, 5);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_id'] = restaurantId;
    data['day'] = day;
    data['opening_time'] = openingTime;
    data['closing_time'] = closingTime;
    return data;
  }
}

class Subscription {
  int? id;
  int? packageId;
  int? restaurantId;
  String? expiryDate;
  String? maxOrder;
  String? maxProduct;
  int? pos;
  int? mobileApp;
  int? chat;
  int? review;
  int? selfDelivery;
  int? status;
  int? totalPackageRenewed;
  String? createdAt;
  String? updatedAt;
  Package? package;

  Subscription({this.id, this.packageId, this.restaurantId, this.expiryDate, this.maxOrder, this.maxProduct, this.pos, this.mobileApp, this.chat, this.review, this.selfDelivery, this.status, this.totalPackageRenewed, this.createdAt, this.updatedAt, this.package});

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packageId = json['package_id'];
    restaurantId = json['restaurant_id'];
    expiryDate = json['expiry_date'];
    maxOrder = json['max_order'];
    maxProduct = json['max_product'];
    pos = json['pos'] ?? 0;
    mobileApp = json['mobile_app'] ?? 0;
    chat = json['chat'] ?? 0;
    review = json['review'] ?? 0;
    selfDelivery = json['self_delivery'];
    status = json['status'];
    totalPackageRenewed = json['total_package_renewed'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    package = json['package'] != null ? Package.fromJson(json['package']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['package_id'] = packageId;
    data['restaurant_id'] = restaurantId;
    data['expiry_date'] = expiryDate;
    data['max_order'] = maxOrder;
    data['max_product'] = maxProduct;
    data['pos'] = pos;
    data['mobile_app'] = mobileApp;
    data['chat'] = chat;
    data['review'] = review;
    data['self_delivery'] = selfDelivery;
    data['status'] = status;
    data['total_package_renewed'] = totalPackageRenewed;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (package != null) {
      data['package'] = package!.toJson();
    }
    return data;
  }
}

class Package {
  int? id;
  String? packageName;
  double? price;
  int? validity;
  String? maxOrder;
  String? maxProduct;
  int? pos;
  int? mobileApp;
  int? chat;
  int? review;
  int? selfDelivery;
  int? status;
  int? def;
  String? colour;
  String? text;
  String? createdAt;
  String? updatedAt;

  Package({this.id, this.packageName, this.price, this.validity, this.maxOrder, this.maxProduct, this.pos, this.mobileApp, this.chat, this.review, this.selfDelivery, this.status, this.def, this.colour, this.text, this.createdAt, this.updatedAt});

Package.fromJson(Map<String, dynamic> json) {
  id = json['id'];
  packageName = json['package_name'];
  price = json['price'].toDouble();
  validity = json['validity'];
  maxOrder = json['max_order'];
  maxProduct = json['max_product'];
  pos = json['pos'];
  mobileApp = json['mobile_app'];
  chat = json['chat'];
  review = json['review'];
  selfDelivery = json['self_delivery'];
  status = json['status'];
  def = json['default'];
  colour = json['colour'];
  text = json['text'];
  createdAt = json['created_at'];
  updatedAt = json['updated_at'];
}

Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = id;
  data['package_name'] = packageName;
  data['price'] = price;
  data['validity'] = validity;
  data['max_order'] = maxOrder;
  data['max_product'] = maxProduct;
  data['pos'] = pos;
  data['mobile_app'] = mobileApp;
  data['chat'] = chat;
  data['review'] = review;
  data['self_delivery'] = selfDelivery;
  data['status'] = status;
  data['default'] = def;
  data['colour'] = colour;
  data['text'] = text;
  data['created_at'] = createdAt;
  data['updated_at'] = updatedAt;
  return data;
  }
}

class SubscriptionOtherData {
  double? totalBill;
  int? maxProductUpload;

  SubscriptionOtherData({this.totalBill, this.maxProductUpload});

  SubscriptionOtherData.fromJson(Map<String, dynamic> json) {
    totalBill = json['total_bill']?.toDouble();
    maxProductUpload = json['max_product_uploads'];
  }

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['total_bill'] = totalBill;
  data['max_product_uploads'] = maxProductUpload;

  return data;
  }
}