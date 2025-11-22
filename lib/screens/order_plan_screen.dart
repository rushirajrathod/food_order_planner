import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food_item.dart';
import '../models/order_plan.dart';

class OrderPlanScreen extends StatefulWidget {
  const OrderPlanScreen({super.key});

  @override
  State<OrderPlanScreen> createState() => _OrderPlanScreenState();
}

class _OrderPlanScreenState extends State<OrderPlanScreen> {
  final TextEditingController _targetCostController = TextEditingController();
  String _selectedDate = '';
  List<FoodItem> _allFoodItems = [];
  final List<FoodItem> _cartItems = []; // Items selected by user
  double _currentTotalCost = 0.0;

  @override
  void initState() {
    super.initState();
    _loadFoodData();
  }

  Future<void> _loadFoodData() async {
    final items = await DatabaseHelper.instance.readAllFoodItems();
    setState(() => _allFoodItems = items);
  }

  /// Opens DatePicker and formats the result
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  /// Handles logic for adding/removing items and checking budget
  void _toggleCartItem(FoodItem item) {
    double budgetLimit = double.tryParse(_targetCostController.text) ?? 0.0;

    if (budgetLimit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Target Cost first!')),
      );
      return;
    }

    setState(() {
      if (_cartItems.contains(item)) {
        // Remove item
        _cartItems.remove(item);
        _currentTotalCost -= item.cost;
      } else {
        // Add item (if within budget)
        if (_currentTotalCost + item.cost <= budgetLimit) {
          _cartItems.add(item);
          _currentTotalCost += item.cost;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Over budget! Cannot add ${item.name}.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  Future<void> _saveOrderToDB() async {
    if (_selectedDate.isEmpty || _cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a date and at least one food item.')),
      );
      return;
    }

    double target = double.tryParse(_targetCostController.text) ?? 0.0;

    // Save each selected item as an order entry
    for (var item in _cartItems) {
      final plan = OrderPlan(
        date: _selectedDate,
        targetCost: target,
        foodItemId: item.id!,
      );
      await DatabaseHelper.instance.insertOrderPlan(plan);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order Plan Saved Successfully!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double targetCost = double.tryParse(_targetCostController.text) ?? 0.0;
    double remainingBudget = targetCost - _currentTotalCost;

    return Scaffold(
      appBar: AppBar(title: const Text('Plan Your Meal')),
      body: Column(
        children: [
          // --- Top Section: Controls ---
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _targetCostController,
                    decoration: const InputDecoration(
                      labelText: 'Daily Budget (\$)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() {}), // Update UI on typing
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate.isEmpty ? 'No Date Selected' : 'Date: $_selectedDate',
                        style: const TextStyle(fontSize: 16),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Pick Date'),
                        onPressed: _selectDate,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- Middle Section: Budget Visualization ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Selected: \$${_currentTotalCost.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Remaining: \$${remainingBudget.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: remainingBudget < 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // --- Bottom Section: Food List ---
          Expanded(
            child: ListView.builder(
              itemCount: _allFoodItems.length,
              itemBuilder: (context, index) {
                final item = _allFoodItems[index];
                final isSelected = _cartItems.contains(item);

                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('\$${item.cost.toStringAsFixed(2)}'),
                  trailing: Icon(
                    isSelected ? Icons.check_circle : Icons.add_circle_outline,
                    color: isSelected ? Colors.green : Colors.grey,
                  ),
                  tileColor: isSelected ? Colors.green.shade50 : null,
                  onTap: () => _toggleCartItem(item),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveOrderToDB,
        label: const Text('Save Plan'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}