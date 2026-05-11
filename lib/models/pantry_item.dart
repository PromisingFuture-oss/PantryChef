class PantryItem {
  int? id;
  String category;
  String name;
  bool isChecked;
  int qty;
  String exp;
  String unit;

  PantryItem({
    this.id,
    required this.category,
    required this.name,
    this.isChecked = true,
    this.qty = 1,
    this.exp = '-',
    this.unit = 'pcs',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'isChecked': isChecked ? 1 : 0,
      'qty': qty,
      'exp': exp,
      'unit': unit,
    };
  }

  factory PantryItem.fromMap(Map<String, dynamic> map) {
    return PantryItem(
      id: map['id'] as int?,
      category: map['category'] as String,
      name: map['name'] as String,
      isChecked: (map['isChecked'] as int) == 1,
      qty: map['qty'] as int,
      exp: map['exp'] as String,
      unit: map['unit'] as String? ?? 'pcs',
    );
  }
}
