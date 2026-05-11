import 'package:flutter/material.dart';
import '../models/pantry_item.dart';
import '../services/database_helper.dart';

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
  List<PantryCategory> _categories = [];
  final List<PantryItem> _deletedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPantryItems();
  }

  Future<void> _loadPantryItems() async {
    final items = await DatabaseHelper.instance.getAllPantryItems();
    
    // Group by category
    final Map<String, List<PantryItem>> grouped = {};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    
    setState(() {
      if (grouped.isEmpty) {
        _categories = [
          PantryCategory(name: 'Dairy', items: []),
          PantryCategory(name: 'Produce', items: []),
          PantryCategory(name: 'Protein', items: []),
        ];
      } else {
        _categories = grouped.entries
            .map((e) => PantryCategory(name: e.key, items: e.value))
            .toList();
        
        // Ensure basic categories exist even if empty
        final existingNames = _categories.map((e) => e.name).toSet();
        for (final basic in ['Dairy', 'Produce', 'Protein']) {
          if (!existingNames.contains(basic)) {
            _categories.add(PantryCategory(name: basic, items: []));
          }
        }
        
        // Sort categories
        _categories.sort((a, b) => a.name.compareTo(b.name));
      }
      _isLoading = false;
    });
  }

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
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF78A083)))
                : TabBarView(
                    children: [_buildVirtualPantryTab(), _buildShoppingListTab()],
                  ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    
                    // 1. Delete removed items from DB
                    for (var item in _deletedItems) {
                      if (item.id != null) {
                        await DatabaseHelper.instance.deletePantryItem(item.id!);
                      }
                    }
                    _deletedItems.clear();
                    
                    // 2. Save or update remaining items
                    for (var cat in _categories) {
                      for (var item in cat.items) {
                        if (item.id == null) {
                          item.id = await DatabaseHelper.instance.insertPantryItem(item);
                        } else {
                          await DatabaseHelper.instance.updatePantryItem(item);
                        }
                      }
                    }
                    
                    setState(() => _isLoading = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pantry & Shopping List Saved!'),
                          backgroundColor: Color(0xFF78A083),
                        ),
                      );
                    }
                  },
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
            ...category.items.map((item) => _buildItemRow(category, item)),
            const SizedBox(height: 8),
            Container(
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    setState(() {
                      category.items.add(PantryItem(
                        category: category.name,
                        name: value.trim(),
                      ));
                    });
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Add Item (Press Enter)',
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

  Widget _buildItemRow(PantryCategory category, PantryItem item) {
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
            child: GestureDetector(
              onLongPress: () => _showEditItemDialog(item),
              child: Container(
                color: Colors.transparent, // Ensures long press registers on the whole expanded area
                child: Text(
                  item.name,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                ),
              ),
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
                    if (item.qty > 1) {
                      setState(() => item.qty--);
                    } else if (item.qty == 1) {
                      _showDeleteConfirmationDialog(category, item);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('-', style: TextStyle(fontSize: 14)),
                  ),
                ),
                Text('${item.qty}', style: const TextStyle(fontSize: 12)),
                InkWell(
                  onTap: () async {
                    setState(() => item.qty++);
                    await DatabaseHelper.instance.updatePantryItem(item);
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
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF78A083), // Green header
                        onPrimary: Colors.white, // Text on header
                        onSurface: Color(0xFF333333), // Body text
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  item.exp = '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';
                });
              }
            },
            child: Container(
              height: 24,
              width: 55, // Adjusted to fit MM/DD
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
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingListTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        // Show only unchecked items in shopping list
        final category = _categories[index];
        final uncheckedItems = category.items.where((i) => !i.isChecked).toList();
        if (uncheckedItems.isEmpty) return const SizedBox();
        
        final filteredCategory = PantryCategory(name: category.name, items: uncheckedItems);
        return _buildShoppingCategorySection(filteredCategory);
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
                  'Unit',
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
            ...category.items.map((item) => _buildShoppingItemRow(category, item)),
            const SizedBox(height: 8),
            Container(
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    setState(() {
                      category.items.add(PantryItem(
                        category: category.name,
                        name: value.trim(),
                        isChecked: false, // Start unchecked in shopping list
                      ));
                    });
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Add Item (Press Enter)',
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

  Widget _buildShoppingItemRow(PantryCategory category, PantryItem item) {
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
            child: GestureDetector(
              onLongPress: () => _showEditItemDialog(item),
              child: Container(
                color: Colors.transparent,
                child: Text(
                  item.name,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                ),
              ),
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
                    if (item.qty > 1) {
                      setState(() => item.qty--);
                    } else if (item.qty == 1) {
                      _showDeleteConfirmationDialog(category, item);
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('-', style: TextStyle(fontSize: 14)),
                  ),
                ),
                Text('${item.qty}', style: const TextStyle(fontSize: 12)),
                InkWell(
                  onTap: () async {
                    setState(() => item.qty++);
                    await DatabaseHelper.instance.updatePantryItem(item);
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
          GestureDetector(
            onTap: () async {
              final String? selectedUnit = await showModalBottomSheet<String>(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  final units = ['pcs', 'kg', 'g', 'L', 'ml', 'packs', 'boxes'];
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Select Unit',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF78A083),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            alignment: WrapAlignment.center,
                            children: units.map((u) => ActionChip(
                              label: Text(u),
                              backgroundColor: const Color(0xFFE8F0E4),
                              side: BorderSide.none,
                              onPressed: () => Navigator.pop(context, u),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
              if (selectedUnit != null) {
                setState(() {
                  item.unit = selectedUnit;
                });
              }
            },
            child: Container(
              height: 24,
              width: 55, // Adjusted width
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
                      item.unit,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditItemDialog(PantryItem item) async {
    final TextEditingController controller = TextEditingController(text: item.name);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item', style: TextStyle(color: Color(0xFF78A083))),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Item name",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF78A083)),
              ),
            ),
            autofocus: true,
            cursorColor: const Color(0xFF78A083),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF78A083)),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    item.name = controller.text.trim();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(PantryCategory category, PantryItem item) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Item?'),
          content: Text('Do you want to remove "${item.name}" from your list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF99874)), // Orange to match app
              onPressed: () {
                setState(() {
                  category.items.remove(item);
                  if (item.id != null) {
                    _deletedItems.add(item);
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
