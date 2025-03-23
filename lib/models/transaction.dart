// lib/models/transaction_model.dart
class TransactionModel {
  final int? id;
  final int? fromCategoryId;
  final int? toCategoryId;
  final int amount;
  final String description;
  final DateTime date;
  final String? fromName;
  final String? toName;
  final String? fromSection;
  final String? toSection;

  TransactionModel({
    this.id,
    this.fromCategoryId,
    this.toCategoryId,
    required this.amount,
    this.description = '',
    required this.date,
    this.fromName,
    this.toName,
    this.fromSection,
    this.toSection,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'from_category_id': fromCategoryId,
      'to_category_id': toCategoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  static TransactionModel fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      fromCategoryId: map['from_category_id'],
      toCategoryId: map['to_category_id'],
      amount: map['amount'],
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      fromName: map['from_name'],
      toName: map['to_name'],
      fromSection: map['from_section'],
      toSection: map['to_section'],
    );
  }
}
