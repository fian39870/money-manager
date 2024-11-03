import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String type;
  final DateTime date;
  final String account;
  final String category;
  final double amount;
  final String note;
  final String description;
  final List<String> images;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.date,
    required this.account,
    required this.category,
    required this.amount,
    required this.note,
    required this.description,
    required this.images,
    required this.createdAt,
  });

  // Add fromMap constructor
  factory TransactionModel.fromMap(
      Map<String, dynamic> data, String documentId) {
    return TransactionModel(
      id: documentId,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      account: data['account'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      note: data['note'] ?? '',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Add toMap method for creating/updating documents
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'date': Timestamp.fromDate(date),
      'account': account,
      'category': category,
      'amount': amount,
      'note': note,
      'description': description,
      'images': images,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Keep the fromFirestore method if you need it elsewhere
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      account: data['account'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      note: data['note'] ?? '',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
