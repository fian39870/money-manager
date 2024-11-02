import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Methods
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<String> createTransaction(TransactionModel transaction) async {
    final docRef =
        await _firestore.collection('transactions').add(transaction.toMap());
    return docRef.id;
  }

  Stream<List<TransactionModel>> getUserTransactions(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Settings Methods
  Future<void> updateUserSettings(
      String userId, Map<String, dynamic> settings) async {
    await _firestore.collection('user_settings').doc(userId).set(
          settings,
          SetOptions(merge: true),
        );
  }

  Stream<Map<String, dynamic>> getUserSettings(String userId) {
    return _firestore
        .collection('user_settings')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }
}
