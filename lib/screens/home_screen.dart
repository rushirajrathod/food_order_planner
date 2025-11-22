import 'package:flutter/material.dart';
import 'food_list_screen.dart';
import 'order_plan_screen.dart';
import 'query_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // UX Improvement: Using Expanded Grid for big clickable areas
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                childAspectRatio: 2.5,
                mainAxisSpacing: 15,
                children: [
                  _buildDashboardCard(
                    context,
                    title: 'Manage Food Items',
                    subtitle: 'Add, Update, or Delete items',
                    icon: Icons.restaurant_menu,
                    color: Colors.orange.shade100,
                    destination: const FoodListScreen(),
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Create Order Plan',
                    subtitle: 'Set budget and pick food',
                    icon: Icons.edit_calendar,
                    color: Colors.blue.shade100,
                    destination: const OrderPlanScreen(),
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'View History',
                    subtitle: 'Query plans by date',
                    icon: Icons.history_edu,
                    color: Colors.green.shade100,
                    destination: const QueryScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context,
      {required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required Widget destination}) {
    return Card(
      elevation: 4,
      color: color,
      child: InkWell(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => destination)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.black54),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.black87)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}