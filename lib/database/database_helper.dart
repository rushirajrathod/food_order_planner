// File: lib/database/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/food_item.dart';
import '../models/order_plan.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('food_order_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. Create Food Items Table
    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cost REAL NOT NULL
      )
    ''');

    // 2. Create Orders Table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        target_cost REAL NOT NULL,
        food_item_id INTEGER NOT NULL,
        FOREIGN KEY (food_item_id) REFERENCES food_items (id)
          ON DELETE CASCADE
      )
    ''');

    await _populateInitialData(db);
  }

  Future _populateInitialData(Database db) async {
    // Requirement 1: Store at least 20 preferred food items
    List<FoodItem> items = [
      FoodItem(name: 'Veggie Burger', cost: 9.50),
      FoodItem(name: 'Cheese Pizza Slice', cost: 3.50),
      FoodItem(name: 'Greek Salad', cost: 8.50),
      FoodItem(name: 'Diet Coke', cost: 1.99),
      FoodItem(name: 'Large Fries', cost: 3.99),
      FoodItem(name: 'Pasta Marinara', cost: 11.00),
      FoodItem(name: 'Grilled Cheese Sandwich', cost: 5.50),
      FoodItem(name: 'Tomato Soup', cost: 4.50),
      FoodItem(name: 'Avocado Toast', cost: 7.50),
      FoodItem(name: 'Bean Tacos (3)', cost: 8.50),
      FoodItem(name: 'Veggie Burrito', cost: 9.00),
      FoodItem(name: 'Cucumber Avocado Roll', cost: 8.00),
      FoodItem(name: 'Falafel Wrap', cost: 8.00),
      FoodItem(name: 'Vanilla Ice Cream', cost: 3.00),
      FoodItem(name: 'Black Coffee', cost: 2.50),
      FoodItem(name: 'Green Tea', cost: 2.00),
      FoodItem(name: 'Cream Cheese Bagel', cost: 3.50),
      FoodItem(name: 'Glazed Donut', cost: 1.50),
      FoodItem(name: 'Berry Smoothie', cost: 5.50),
      FoodItem(name: 'Veggie Wrap', cost: 7.00),
      FoodItem(name: 'Macaroni and Cheese', cost: 10.50),
      FoodItem(name: 'Mushroom Risotto', cost: 13.50),
      FoodItem(name: 'Hummus & Pita Plate', cost: 6.50),
      FoodItem(name: 'Chocolate Cake Slice', cost: 4.50),
      FoodItem(name: 'Fresh Fruit Salad', cost: 5.00),
    ];

    for (var item in items) {
      await db.insert('food_items', item.toMap());
    }
  }

  // --- CRUD Operations ---

  // Insert (Requirement 5)
  Future<int> createFoodItem(FoodItem item) async {
    final db = await instance.database;
    return await db.insert('food_items', item.toMap());
  }

  // Read (Requirement 5)
  Future<List<FoodItem>> readAllFoodItems() async {
    final db = await instance.database;
    final result = await db.query('food_items', orderBy: 'name ASC');
    return result.map((json) => FoodItem.fromMap(json)).toList();
  }

  // Update (Requirement 5)
  Future<int> updateFoodItem(FoodItem item) async {
    final db = await instance.database;
    return await db.update(
      'food_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete (Requirement 5)
  Future<int> deleteFoodItem(int id) async {
    final db = await instance.database;
    return await db.delete(
      'food_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Save Order Plan (Requirement 3)
  Future<int> insertOrderPlan(OrderPlan plan) async {
    final db = await instance.database;
    return await db.insert('orders', plan.toMap());
  }

  // Query Plan (Requirement 4)
  Future<List<Map<String, dynamic>>> getPlanByDate(String date) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT orders.id, orders.date, orders.target_cost, food_items.name, food_items.cost 
      FROM orders 
      INNER JOIN food_items ON orders.food_item_id = food_items.id 
      WHERE orders.date = ?
    ''', [date]);
  }
}