class PeriodicItem {
  final String id;
  final String name;
  final double price;
  final int periodDays;
  final DateTime lastPurchaseDate;
  final String categoryId;
  final String memo;

  PeriodicItem({
    required this.id,
    required this.name,
    required this.price,
    required this.periodDays,
    required this.lastPurchaseDate,
    required this.categoryId,
    this.memo = '',
  });

  // DBからのデータ変換
  factory PeriodicItem.fromMap(Map<String, dynamic> map) {
    return PeriodicItem(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      periodDays: map['period_days'],
      lastPurchaseDate: DateTime.parse(map['last_purchase_date']),
      categoryId: map['category_id'],
      memo: map['memo'] ?? '',
    );
  }

  // DBへの保存用データ
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'period_days': periodDays,
      'last_purchase_date': lastPurchaseDate.toIso8601String(),
      'category_id': categoryId,
      'memo': memo,
    };
  }
}
