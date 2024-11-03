import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'component/bottom_bar.dart';
import '../config/routes.dart';

class StatsPage extends StatelessWidget {
  StatsPage({Key? key}) : super(key: key);

  final List<ExpenseItem> expenses = [
    ExpenseItem('Apparel', 1046.76, 0.428, Colors.pink),
    ExpenseItem('Household', 315.48, 0.129, Colors.orange),
    ExpenseItem('Education', 300.99, 0.123, Colors.yellow),
    ExpenseItem('Transportation', 200.00, 0.082, Colors.yellow[700]!),
    ExpenseItem('Gift', 145.36, 0.060, Colors.lightGreen),
    ExpenseItem('Health', 141.36, 0.058, Colors.greenAccent),
    ExpenseItem('Culture', 99.99, 0.041, Colors.blue),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: Text(
          'Jul 2020',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Income and Expenses Summary
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pemasukan \$4,831.89',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'Pengeluaran \$2,442.93',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Pie Chart
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: expenses.map((expense) {
                  return PieChartSectionData(
                    color: expense.color,
                    value: expense.percentage * 100,
                    title: '',
                    radius: 80,
                  );
                }).toList(),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
              ),
            ),
          ),

          // Expense List
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 30,
                        decoration: BoxDecoration(
                          color: expense.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            '${(expense.percentage * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          expense.category,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        '\$${expense.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Navigation Bar
        ],
      ),
      bottomNavigationBar: SharedBottomNavigation(
        currentIndex: 1, // Transaction tab index
        onTap: (index) {
          switch (index) {
            case 0: // Transaction
              Navigator.pushReplacementNamed(context, Routes.transaction);
              break;
            case 1: // Transaction
              Navigator.pushReplacementNamed(context, Routes.stats);
              break;
            case 2: // Transaction
              Navigator.pushReplacementNamed(context, Routes.asset);
              break;
            case 3: // Settings
              Navigator.pushReplacementNamed(context, Routes.setting);
              break;
            // Add other cases as needed
          }
        },
      ),
    );
  }
}

class ExpenseItem {
  final String category;
  final double amount;
  final double percentage;
  final Color color;

  ExpenseItem(this.category, this.amount, this.percentage, this.color);
}
