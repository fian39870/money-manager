import 'package:flutter/material.dart';
import 'component/bottom_bar.dart';
import '../config/routes.dart';

class AssetScreen extends StatelessWidget {
  const AssetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Aset',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black, size: 20),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.black, size: 24),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSummaryCard(),
            _buildCashSection(),
            _buildBankSection(),
            _buildCardSection(),
          ],
        ),
      ),
      bottomNavigationBar: SharedBottomNavigation(
        currentIndex: 2, // Transaction tab index
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

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem('Aset', '\$ 6,628.12', Colors.black),
          _buildSummaryItem('Liabilitas', '\$ 208,242.65', Colors.red),
          _buildSummaryItem('Total', '\$-201,614.53', Colors.black),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String amount, Color amountColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: amountColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCashSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'Tunai',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildListItem('Tunai', '\$68.45'),
      ],
    );
  }

  Widget _buildBankSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'Bank',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildListItem('Bank', '\$2,768.66'),
        _buildListItem('Bank', '\$1,155.05'),
      ],
    );
  }

  Widget _buildCardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Harus Dibayar',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                'Belum Dibayar',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
        _buildCardItem('Bank', '\$2,192.65', '\$0.00'),
        _buildCardItem('HIBD Travel', '\$-1,076.39', '\$0.00'),
        _buildCardItem('RBO Credit Card', '\$-1,116.26', '\$0.00'),
        _buildCardItem('Karu Debit', '', '\$0.00'),
        _buildCardItem('HIBD Debit Card', '', '\$0.00'),
        _buildCardItem('RBO Debit Card', '', '\$0.00'),
      ],
    );
  }

  Widget _buildListItem(String title, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              color: amount.startsWith('-') ? Colors.red : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(String title, String mustPay, String unpaid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              mustPay,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                color: mustPay.startsWith('-') ? Colors.red : Colors.blue,
              ),
            ),
          ),
          Expanded(
            child: Text(
              unpaid,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
