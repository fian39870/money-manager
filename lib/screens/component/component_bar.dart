import 'package:flutter/material.dart';

// Tab Bar Widget
class FinanceCalendarTabBar extends StatelessWidget {
  final bool isSelected;
  final String text;
  final VoidCallback onTap;

  const FinanceCalendarTabBar({
    Key? key,
    required this.isSelected,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.red : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.red : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Bottom Navigation Bar Widget
class FinanceCalendarBottomBar extends StatelessWidget {
  const FinanceCalendarBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Transactional',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sync),
          label: 'Accounts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Account',
        ),
      ],
    );
  }
}
