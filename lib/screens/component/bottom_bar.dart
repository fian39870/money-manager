import 'package:flutter/material.dart';

class SharedBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SharedBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFFF4D4D),
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Transaksi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Statistik',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sync_outlined),
          activeIcon: Icon(Icons.sync),
          label: 'Aset',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Pengaturan',
        ),
      ],
    );
  }
}
