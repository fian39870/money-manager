import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'component/bottom_bar.dart';
import '../config/routes.dart';

class AssetScreen extends StatefulWidget {
  const AssetScreen({Key? key}) : super(key: key);

  @override
  State<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;

  // Data containers
  double _totalAssets = 0;
  double _totalLiabilities = 0;
  List<Asset> _cashAssets = [];
  List<Asset> _bankAssets = [];
  List<CardAsset> _cardAssets = [];

  @override
  void initState() {
    super.initState();
    _loadAssetData();
  }

  Future<void> _loadAssetData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Fetch assets from Firestore
      final QuerySnapshot assetSnapshot = await _firestore
          .collection('assets')
          .where('userId', isEqualTo: user.uid)
          .get();

      List<Asset> cashAssets = [];
      List<Asset> bankAssets = [];
      List<CardAsset> cardAssets = [];
      double totalAssets = 0;
      double totalLiabilities = 0;

      for (var doc in assetSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final type = data['type'] as String;
        final amount = (data['amount'] as num).toDouble();
        final title = data['title'] as String;
        final mustPay = (data['mustPay'] as num?)?.toDouble() ?? 0;
        final unpaid = (data['unpaid'] as num?)?.toDouble() ?? 0;

        final asset = Asset(title: title, amount: amount);
        final cardAsset = CardAsset(
          title: title,
          mustPay: mustPay,
          unpaid: unpaid,
        );

        switch (type.toLowerCase()) {
          case 'cash':
            cashAssets.add(asset);
            totalAssets += amount;
            break;
          case 'bank':
            bankAssets.add(asset);
            totalAssets += amount;
            break;
          case 'card':
            cardAssets.add(cardAsset);
            if (mustPay < 0) {
              totalLiabilities += mustPay.abs();
            }
            break;
        }
      }

      if (mounted) {
        setState(() {
          _cashAssets = cashAssets;
          _bankAssets = bankAssets;
          _cardAssets = cardAssets;
          _totalAssets = totalAssets;
          _totalLiabilities = totalLiabilities;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading asset data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAssetData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildSummaryCard(),
                    if (_cashAssets.isNotEmpty) _buildCashSection(),
                    if (_bankAssets.isNotEmpty) _buildBankSection(),
                    if (_cardAssets.isNotEmpty) _buildCardSection(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: SharedBottomNavigation(
        currentIndex: 2,
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

  Widget _buildSummaryCard() {
    final total = _totalAssets - _totalLiabilities;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem(
              'Aset', '\$ ${_totalAssets.toStringAsFixed(2)}', Colors.black),
          _buildSummaryItem('Liabilitas',
              '\$ ${_totalLiabilities.toStringAsFixed(2)}', Colors.red),
          _buildSummaryItem('Total', '\$ ${total.toStringAsFixed(2)}',
              total < 0 ? Colors.red : Colors.black),
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
        ..._cashAssets.map((asset) => _buildListItem(
            asset.title, '\$${asset.amount.toStringAsFixed(2)}')),
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
        ..._bankAssets.map((asset) => _buildListItem(
            asset.title, '\$${asset.amount.toStringAsFixed(2)}')),
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
        ..._cardAssets.map((card) => _buildCardItem(
              card.title,
              card.mustPay != 0 ? '\$${card.mustPay.toStringAsFixed(2)}' : '',
              '\$${card.unpaid.toStringAsFixed(2)}',
            )),
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
              color: amount.contains('-') ? Colors.red : Colors.blue,
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
                color: mustPay.contains('-') ? Colors.red : Colors.blue,
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

class Asset {
  final String title;
  final double amount;

  Asset({required this.title, required this.amount});
}

class CardAsset {
  final String title;
  final double mustPay;
  final double unpaid;

  CardAsset({
    required this.title,
    required this.mustPay,
    required this.unpaid,
  });
}
