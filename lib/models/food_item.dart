// File: lib/models/food_item.dart

class FoodItem {
  final int? id;        // Database Primary Key
  final String name;    // Name of the food
  final double cost;    // Cost of the item

  FoodItem({this.id, required this.name, required this.cost});

  // Convert to Map for Database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
    };
  }

  // Create from Database Map
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      cost: map['cost'],
    );
  }
}