enum BalanceEnum {
  id("id"),
  amount("amount");

  final String key;
  const BalanceEnum(this.key);

  String get value => key;
}

class BalanceEntity {
  String id;
  double amount;

  BalanceEntity({required this.id, required this.amount});

  factory BalanceEntity.fromMap(Map<String, dynamic> map) {
    return BalanceEntity(
      id: map[BalanceEnum.id.key] as String? ?? '',
      amount: (map[BalanceEnum.amount.key] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {BalanceEnum.id.key: id, BalanceEnum.amount.key: amount};
  }
}
