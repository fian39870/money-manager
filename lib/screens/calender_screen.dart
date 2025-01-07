import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'component/bottom_bar.dart';
import '../config/routes.dart';
import 'expense_transaction_screen.dart';

class TransactionCalendarView extends StatelessWidget {
  final double income;
  final double expenses;
  final DateTime selectedDate;

  const TransactionCalendarView({
    Key? key,
    required this.income,
    required this.expenses,
    required this.selectedDate,
  }) : super(key: key);
  Widget _buildCalendarCell(BuildContext context, int index) {
    // Tambahkan parameter context
    final date = DateTime(selectedDate.year, selectedDate.month, index + 1);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseTransactionPage(
              selectedDate: date,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          color: _isToday(date) ? Colors.blue.withOpacity(0.1) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              (index + 1).toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    _isToday(date) ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (_hasTransactions(date))
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 2),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {},
        ),
        title: Text(
          DateFormat('MMM yyyy').format(selectedDate),
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle buttons for view options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildToggleButton('Daily', false),
                _buildToggleButton('Calendar', true),
                _buildToggleButton('Weekly', false),
                _buildToggleButton('Monthly', false),
                _buildToggleButton('Summary', false),
              ],
            ),
          ),

          // Summary section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Income', income, Colors.blue),
                _buildSummaryItem('Expenses', expenses, Colors.red),
                _buildSummaryItem('Total', income - expenses, Colors.black),
              ],
            ),
          ),

          // Calendar grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount:
                  DateTime(selectedDate.year, selectedDate.month + 1, 0).day,
              itemBuilder: (context, index) {
                return _buildCalendarCell(
                    context, index); // Passing context ke method
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SharedBottomNavigation(
        currentIndex: 0, // Transaction tab index
        onTap: (index) {
          switch (index) {
            case 0: // Transaction
              Navigator.pushReplacementNamed(context, Routes.transaction);
              break;
            case 1: // Transaction
              Navigator.pushReplacementNamed(context, Routes.stats);
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

  Widget _buildToggleButton(String text, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? Colors.red : Colors.grey,
        ),
        onPressed: () {},
        child: Text(text),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

// Helper method untuk mengecek apakah tanggal yang dipilih adalah hari ini
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _hasTransactions(DateTime date) {
    // Implementasi logika untuk mengecek apakah ada transaksi
    return false;
  }
}
