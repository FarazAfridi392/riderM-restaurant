class BusinessPlanBody {
  String? businessPlan;
  String? restaurantId;
  String? packageId;
  String? payment;
  String? type;

  BusinessPlanBody({this.businessPlan, this.restaurantId, this.packageId, this.payment, this.type});

  BusinessPlanBody.fromJson(Map<String, dynamic> json) {
    businessPlan = json['business_plan'];
    restaurantId = json['restaurant_id'];
    packageId = json['package_id'];
    payment = json['payment'];
    type = json['type'];
  }

  Map<String, String?> toJson() {
    final Map<String, String?> data = <String, String?>{};
    data['business_plan'] = businessPlan;
    data['restaurant_id'] = restaurantId;
    data['package_id'] = packageId;
    data['payment'] = payment;
    data['type'] = type;
    return data;
  }
}
