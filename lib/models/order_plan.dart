/// Represents a saved order entry for a specific date.
class OrderPlan {
  final int? id;
  final String date;        // Format: YYYY-MM-DD
  final double targetCost;  // The user's daily budget limit
  final int foodItemId;     // Foreign Key linking to the FoodItem table

  OrderPlan({
    this.id,
    required this.date,
    required this.targetCost,
    required this.foodItemId,
  });

  /// Converts data to Map for Database.
  /// Note: Keys match the database column names (snake_case).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'target_cost': targetCost,
      'food_item_id': foodItemId,
    };
  }

  /// Creates object from Database Map.
  factory OrderPlan.fromMap(Map<String, dynamic> map) {
    return OrderPlan(
      id: map['id'],
      date: map['date'],
      targetCost: map['target_cost'],
      foodItemId: map['food_item_id'],
    );
  }
}