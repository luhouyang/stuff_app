import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionEnum {
  id("id"),
  userId("userId"),
  amount("amount"),
  type("type"), // 'income' or 'expense'
  category("category"),
  description("description"),
  year("year"),
  month("month"),
  day("day"),
  createdAt("createdAt");

  final String key;
  const TransactionEnum(this.key);

  String get value => key;
}

class TransactionEntity {
  String id;
  final String userId;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final String description;
  final Timestamp createdAt;
  final int year;
  final int month;
  final int day;

  TransactionEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    required this.createdAt,
    required this.year,
    required this.month,
    required this.day,
  });

  factory TransactionEntity.fromMap(Map<String, dynamic> map) {
    Timestamp timestamp = map[TransactionEnum.createdAt.key] as Timestamp? ?? Timestamp.now();
    DateTime dateTime = timestamp.toDate();

    return TransactionEntity(
      id: map[TransactionEnum.id.key] as String? ?? '',
      userId: map[TransactionEnum.userId.key] as String? ?? '',
      amount: (map[TransactionEnum.amount.key] as num?)?.toDouble() ?? 0.0,
      type: map[TransactionEnum.type.key] as String? ?? 'expense',
      category: map[TransactionEnum.category.key] as String? ?? 'Uncategorized',
      description: map[TransactionEnum.description.key] as String? ?? '',
      createdAt: timestamp,
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      TransactionEnum.id.key: id,
      TransactionEnum.userId.key: userId,
      TransactionEnum.amount.key: amount,
      TransactionEnum.type.key: type,
      TransactionEnum.category.key: category,
      TransactionEnum.description.key: description,
      TransactionEnum.createdAt.key: createdAt,
      TransactionEnum.year.key: year,
      TransactionEnum.month.key: month,
      TransactionEnum.day.key: day,
    };
  }
}
