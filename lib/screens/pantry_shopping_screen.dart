import 'package:flutter/material.dart';

class PantryItem {
  String name;
  bool isChecked;
  int qty;
  String exp;

  PantryItem({
    required this.name,
    this.isChecked = true,
    this.qty = 1,
    this.exp = '-',
  });
}

class PantryCategory {
  String name;
  List<PantryItem> items;

  PantryCategory({required this.name, required this.items});
}

class PantryShoppingScreen extends StatefulWidget {
  const PantryShoppingScreen({super.key});

  @override
  State<PantryShoppingScreen> createState() => _PantryShoppingScreenState();
}

class _PantryShoppingScreenState extends State<PantryShoppingScreen> {
  final List<PantryCategory> _shoppingCategories = [
    PantryCategory(
      name: 'Dairy',
      items: [
        PantryItem(name: 'Milk'),
        PantryItem(name: 'Cheese'),
        PantryItem(name: 'Yogurt'),
        PantryItem(name: 'Butter', isChecked: false),
      ],
    ),
    PantryCategory(
      name: 'Produce',
      items: [
        PantryItem(name: 'Spinach'),
        PantryItem(name: 'Potatoes', isChecked: false),
        PantryItem(name: 'Onions', isChecked: false),
      ],
    ),
    PantryCategory(
      name: 'Protein',
      items: [
        PantryItem(name: 'Pork'),
        PantryItem(name: 'Turkey'),
      ],
    ),
  ];

  final List<PantryCategory> _categories = [
    PantryCategory(
      name: 'Dairy',
      items: [
        PantryItem(name: 'Milk'),
        PantryItem(name: 'Cheese'),
        PantryItem(name: 'Yogurt'),
        PantryItem(name: 'Butter', isChecked: false),
      ],
    ),
    PantryCategory(
      name: 'Produce',
      items: [
        PantryItem(name: 'Spinach'),
        PantryItem(name: 'Potatoes'),
        PantryItem(name: 'Onions'),
      ],
    ),
    PantryCategory(
      name: 'Protein',
      items: [
        PantryItem(name: 'Chicken'),
        PantryItem(name: 'Beef'),
        PantryItem(name: 'Fish'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F6F1),
        appBar: AppBar(
          backgroundColor: const Color(0xFF90B496),
          elevation: 0,
          title: const Text(
            'PantryChef',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: const Color(0xFFE8F0E4),
              width: double.infinity,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Shopping & Pantry',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF78A083),
                      ),
                    ),
                  ),
                  TabBar(
                    indicatorColor: const Color(0xFF78A083),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFF333333),
                    unselectedLabelColor: const Color(0xFF333333),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Virtual Pantry'),
                      Tab(text: 'Shopping List'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [_buildVirtualPantryTab(), _buildShoppingListTab()],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF99874), // Orange color
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save List',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVirtualPantryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(_categories[index]);
      },
    );
  }

  Widget _buildCategoryCard(PantryCategory category) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Qty',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(width: 32),
                const Text(
                  'EXP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: 12),
            ...category.items.map((item) => _buildItemRow(item)),
            const SizedBox(height: 8),
            Container(
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Add Item',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(PantryItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                item.isChecked = !item.isChecked;
              });
            },
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isChecked
                    ? const Color(0xFF81B862)
                    : Colors.grey.shade300,
              ),
              child: item.isChecked
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
            ),
          ),
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    if (item.qty > 0) setState(() => item.qty--);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('-', style: TextStyle(fontSize: 14)),
                  ),
                ),
                Text('${item.qty}', style: const TextStyle(fontSize: 12)),
                InkWell(
                  onTap: () {
                    setState(() => item.qty++);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('+', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 24,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.exp,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingListTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: _shoppingCategories.length,
      itemBuilder: (context, index) {
        return _buildShoppingCategorySection(_shoppingCategories[index]);
      },
    );
  }

  Widget _buildShoppingCategorySection(PantryCategory category) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Qty',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(width: 32),
                const Text(
                  'Type',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: 12),
            ...category.items.map((item) => _buildShoppingItemRow(item)),
            const SizedBox(height: 8),
            Container(
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Add Item',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingItemRow(PantryItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                item.isChecked = !item.isChecked;
              });
            },
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: item.isChecked
                    ? const Color(0xFF81B862)
                    : Colors.grey.shade300,
              ),
              child: item.isChecked
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
            ),
          ),
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    if (item.qty > 0) setState(() => item.qty--);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('-', style: TextStyle(fontSize: 14)),
                  ),
                ),
                Text('${item.qty}', style: const TextStyle(fontSize: 12)),
                InkWell(
                  onTap: () {
                    setState(() => item.qty++);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('+', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 24,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.exp,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
