import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'component/bottom_bar.dart';
import '../config/routes.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Store processed data
  List<ExpenseItem> _expenses = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactionData();
  }

  Future<void> _loadTransactionData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get current month's start and end dates
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      // Query transactions
      final QuerySnapshot transactions = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      // Process transactions
      Map<String, double> categoryTotals = {};
      double totalIncome = 0;
      double totalExpense = 0;

      for (var doc in transactions.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['amount'] as num).toDouble();
        final type = data['type'] as String;

        if (type == 'Income') {
          totalIncome += amount;
        } else if (type == 'Expense') {
          totalExpense += amount;
          final category = data['category'] as String;
          categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        }
      }

      // Convert to ExpenseItem list
      List<ExpenseItem> expenses = [];
      final colors = [
        Colors.pink,
        Colors.orange,
        Colors.yellow,
        Colors.yellow[700]!,
        Colors.lightGreen,
        Colors.greenAccent,
        Colors.blue,
      ];

      int colorIndex = 0;
      categoryTotals.forEach((category, amount) {
        expenses.add(ExpenseItem(
          category,
          amount,
          amount / totalExpense,
          colors[colorIndex % colors.length],
        ));
        colorIndex++;
      });

      // Sort by amount descending
      expenses.sort((a, b) => b.amount.compareTo(a.amount));

      if (mounted) {
        setState(() {
          _expenses = expenses;
          _totalIncome = totalIncome;
          _totalExpense = totalExpense;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading transaction data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: Text(
          '${DateTime.now().year}-${DateTime.now().month}',
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadTransactionData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Income and Expenses Summary
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pemasukan \$${_totalIncome.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Pengeluaran \$${_totalExpense.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Pie Chart
                if (_expenses.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _expenses.map((expense) {
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
                  )
                else
                  const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text('No expense data for this period'),
                    ),
                  ),

                // Expense List
                Expanded(
                  child: ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                expense.category,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              '\$${expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
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
              ],
            ),
      bottomNavigationBar: SharedBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, Routes.transaction);
              break;
            case 1:
              Navigator.pushReplacementNamed(context, Routes.stats);
              break;
            case 2:
              Navigator.pushReplacementNamed(context, Routes.asset);
              break;
            case 3:
              Navigator.pushReplacementNamed(context, Routes.setting);
              break;
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
