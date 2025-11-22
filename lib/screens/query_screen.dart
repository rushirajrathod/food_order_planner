import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class QueryScreen extends StatefulWidget {
  const QueryScreen({super.key});

  @override
  State<QueryScreen> createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  String _selectedDate = '';
  List<Map<String, dynamic>> _retrievedPlan = [];
  double _totalPlanCost = 0.0;
  double _targetCost = 0.0;

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
      _fetchPlanForDate();
    }
  }

  Future<void> _fetchPlanForDate() async {
    final data = await DatabaseHelper.instance.getPlanByDate(_selectedDate);

    double total = 0;
    double target = 0;

    if (data.isNotEmpty) {
      // Target cost is stored in every row, so we just take it from the first one
      target = data[0]['target_cost'];
      for (var row in data) {
        total += row['cost'];
      }
    }

    setState(() {
      _retrievedPlan = data;
      _totalPlanCost = total;
      _targetCost = target;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan History')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calendar_month),
              label: Text(_selectedDate.isEmpty ? 'Select Date to Query' : 'Date: $_selectedDate'),
              onPressed: _selectDate,
            ),
          ),
          const SizedBox(height: 20),

          if (_retrievedPlan.isNotEmpty) ...[
            // Summary Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Budget Limit:', style: TextStyle(fontSize: 16)),
                        Text('\$${_targetCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Spent:', style: TextStyle(fontSize: 18)),
                        Text('\$${_totalPlanCost.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Items Ordered:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),

            // List of Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _retrievedPlan.length,
                itemBuilder: (context, index) {
                  final item = _retrievedPlan[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.fastfood, color: Colors.orange),
                      title: Text(item['name']),
                      trailing: Text('\$${item['cost']}'),
                    ),
                  );
                },
              ),
            ),
          ] else if (_selectedDate.isNotEmpty) ...[
            const Expanded(child: Center(child: Text('No plan found for this date.', style: TextStyle(fontSize: 16, color: Colors.grey)))),
          ],
        ],
      ),
    );
  }
}