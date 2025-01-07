import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/expense_transaction_screen.dart';

class IncomeTransactionPage extends StatefulWidget {
  const IncomeTransactionPage({Key? key}) : super(key: key);

  @override
  State<IncomeTransactionPage> createState() => _IncomeTransactionPageState();
}

class _IncomeTransactionPageState extends State<IncomeTransactionPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedType = 'Income'; // Default to Income
  List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (var image in _images) {
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      Reference ref = _storage.ref().child('transaction_images/$fileName');
      await ref.putFile(File(image.path));
      String downloadUrl = await ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<String> imageUrls = await _uploadImages();
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final transactionData = {
        'userId': user.uid,
        'type': _selectedType,
        'date': Timestamp.fromDate(
            DateFormat('yyyy-MM-dd').parse(_dateController.text)),
        'account': _accountController.text,
        'category': _categoryController.text,
        'amount': double.parse(_amountController.text),
        'note': _noteController.text,
        'description': _descriptionController.text,
        'images': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('transactions').add(transactionData);

      // Update user's total balance
      final userRef = _firestore.collection('users').doc(user.uid);
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) {
          throw Exception('User document does not exist');
        }

        double amount = double.parse(_amountController.text);
        double currentBalance = userDoc.data()?['balance'] ?? 0.0;
        double newBalance = currentBalance + amount; // Add for income

        transaction.update(userRef, {'balance': newBalance});
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Income transaction saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving transaction: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Income'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTransaction,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save',
                    style: TextStyle(
                        color: Colors.green)), // Changed to green for income
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTypeButton('Income'),
                  _buildTypeButton('Expense'),
                  _buildTypeButton('Transfer'),
                ],
              ),
              const SizedBox(height: 24),
              // Form Fields
              _buildFormField('Date', _dateController,
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.green),
                    onPressed: _selectDate,
                  )),
              _buildFormField('Asset', _accountController),
              _buildFormField('Category', _categoryController),
              _buildFormField('Amount', _amountController),
              _buildFormField('Note', _noteController),
              _buildFormField('Description', _descriptionController,
                  trailing: IconButton(
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: Colors.green),
                    onPressed: _pickImage,
                  )),

              // Image Preview
              if (_images.isNotEmpty)
                Container(
                  height: 120,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(File(_images[index].path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            top: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

              // Bottom Buttons
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      onPressed: () {},
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.copy,
                      label: 'Copy',
                      onPressed: () {},
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.bookmark_border,
                      label: 'Bookmark',
                      onPressed: () {},
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String type) {
    bool isSelected = _selectedType == type;
    return InkWell(
      onTap: () {
        if (type != _selectedType) {
          switch (type) {
            case 'Expense':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExpenseTransactionPage(),
                ),
              );
              break;
            case 'Transfer':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IncomeTransactionPage(),
                ),
              );
              break;
            default:
              setState(() {
                _selectedType = type;
              });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red[100] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.red : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller,
      {Widget? trailing}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color color = Colors.grey,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
