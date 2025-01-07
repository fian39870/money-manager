import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'calender_screen.dart';
import 'expense_transaction_screen.dart';
import 'setting_screen.dart';
import 'stats_screen.dart';
import '../models/transaction_model.dart';
import 'component/bottom_bar.dart';
import '../config/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const TransactionScreen({Key? key, this.selectedDate}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _currentFilter = 'Daily';
  late DateTime _selectedDate;
  double _income = 0;
  double _expenses = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (_auth.currentUser == null) {
      print('No user logged in');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final userId = _auth.currentUser!.uid;
      print('Loading transactions for user: $userId');

      // Get the start and end of the selected month
      final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endOfMonth =
          DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);

      print(
          'Date range: ${startOfMonth.toString()} to ${endOfMonth.toString()}');

      // Query transactions
      final QuerySnapshot snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get(); // Temporarily remove date filters for testing

      print('Raw query result: ${snapshot.docs.length} documents');

      // Print the first document for debugging
      if (snapshot.docs.isNotEmpty) {
        print('First document data: ${snapshot.docs.first.data()}');
      }

      // Clear previous transactions
      _transactions.clear();
      _income = 0;
      _expenses = 0;

      // Process each document
      for (var doc in snapshot.docs) {
        try {
          print('Processing document ${doc.id}');
          print('Document data: ${doc.data()}');

          final transaction = TransactionModel.fromFirestore(doc);
          print(
              'Successfully created transaction object: ${transaction.description}');

          _transactions.add(transaction);

          // Update totals
          if (transaction.type == 'Income') {
            _income += transaction.amount;
          } else if (transaction.type == 'Expense') {
            _expenses += transaction.amount;
          }
        } catch (e, stackTrace) {
          print('Error processing document ${doc.id}: $e');
          print('Stack trace: $stackTrace');
        }
      }

      setState(() {});
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeDate = ModalRoute.of(context)?.settings.arguments as DateTime?;
    if (routeDate != null) {
      setState(() {
        _selectedDate = routeDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterTabs(),
          Expanded(child: _buildTransactionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF4D4D),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExpenseTransactionPage(),
            ),
          );
        },
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const Icon(Icons.search, color: Colors.black),
      title: const Text(
        'Transaction',
        style: TextStyle(color: Colors.black),
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
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _updateMonth(-1),
                child: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat('MMM yyyy').format(_selectedDate),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => _updateMonth(1),
                child: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                label: 'Income',
                amount: '\Rp. ${_income.toStringAsFixed(2)}',
                color: Colors.blue,
              ),
              _SummaryItem(
                label: 'Expenses',
                amount: '\Rp. ${_expenses.toStringAsFixed(2)}',
                color: Colors.red,
              ),
              _SummaryItem(
                label: 'Total',
                amount: '\Rp. ${(_income - _expenses).toStringAsFixed(2)}',
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_transactions.isEmpty) {
      return const Center(
        child: Text('No transactions found for this period'),
      );
    }

    return ListView.builder(
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return _TransactionItem(
          date: DateFormat('dd').format(transaction.date),
          day: DateFormat('E').format(transaction.date),
          category: '${transaction.category} • ${transaction.account}',
          title: transaction.description,
          subtitle: transaction.note,
          amount: '\Rp.${transaction.amount.toStringAsFixed(2)}',
          isExpense: transaction.type == 'Expense',
        );
      },
    );
  }

  void _updateMonth(int months) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + months,
        _selectedDate.day,
      );
      _loadTransactions(); // Reload transactions when month changes
    });
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterTab(
            text: 'Daily',
            isSelected: _currentFilter == 'Daily',
            onTap: () => _setFilter('Daily'),
          ),
          _FilterTab(
            text: 'Calendar',
            isSelected: _currentFilter == 'Calendar',
            onTap: () => _navigateToCalendarView(),
          ),
          _FilterTab(
            text: 'Weekly',
            isSelected: _currentFilter == 'Weekly',
            onTap: () => _setFilter('Weekly'),
          ),
          _FilterTab(
            text: 'Monthly',
            isSelected: _currentFilter == 'Monthly',
            onTap: () => _setFilter('Monthly'),
          ),
          _FilterTab(
            text: 'Summary',
            isSelected: _currentFilter == 'Summary',
            onTap: () => _setFilter('Summary'),
          ),
        ],
      ),
    );
  }

  void _navigateToCalendarView() async {
    final result = await Navigator.of(context).push<DateTime>(
      MaterialPageRoute(
        builder: (context) => TransactionCalendarView(
          income: _income,
          expenses: _expenses,
          selectedDate: _selectedDate,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDate = result;
      });
    }
  }

  void _setFilter(String filter) {
    setState(() {
      _currentFilter = filter;
    });
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _SummaryItem({
    Key? key,
    required this.label,
    required this.amount,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          amount,
          style: TextStyle(fontSize: 16, color: color),
        ),
      ],
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterTab({
    Key? key,
    required this.text,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFF4D4D) : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String date;
  final String day;
  final String category;
  final String title;
  final String subtitle;
  final String amount;
  final bool isExpense;

  const _TransactionItem({
    Key? key,
    required this.date,
    required this.day,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isExpense,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              color: isExpense ? Colors.orange : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
