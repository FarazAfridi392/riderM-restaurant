
class SubscriptionModel {
  int? id;
  String? status;
  String? startAt;
  String? endAt;
  String? note;
  String? type;
  int? quantity;
  int? userId;
  int? restaurantId;
  double? billingAmount;
  double? paidAmount;
  String? createdAt;
  String? updatedAt;
  bool? isPausedToday;

  SubscriptionModel(
      {this.id,
        this.status,
        this.startAt,
        this.endAt,
        this.note,
        this.type,
        this.quantity,
        this.userId,
        this.restaurantId,
        this.billingAmount,
        this.paidAmount,
        this.createdAt,
        this.updatedAt,
        this.isPausedToday,
      });

  SubscriptionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    startAt = json['start_at'];
    endAt = json['end_at'];
    note = json['note'];
    type = json['type'];
    quantity = json['quantity'];
    userId = json['user_id'];
    restaurantId = json['restaurant_id'];
    billingAmount = json['billing_amount'].toDouble();
    paidAmount = json['paid_amount'].toDouble();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isPausedToday = json['is_paused_today'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['start_at'] = startAt;
    data['end_at'] = endAt;
    data['note'] = note;
    data['type'] = type;
    data['quantity'] = quantity;
    data['user_id'] = userId;
    data['restaurant_id'] = restaurantId;
    data['billing_amount'] = billingAmount;
    data['paid_amount'] = paidAmount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_paused_today'] = isPausedToday;
    return data;
  }
}
