import 'package:flutter/material.dart';

class AllergyFilterScreen extends StatefulWidget {
  final Set<String> initialAllergens;

  const AllergyFilterScreen({
    super.key,
    this.initialAllergens = const {},
  });

  @override
  State<AllergyFilterScreen> createState() => _AllergyFilterScreenState();
}

class _AllergyFilterScreenState extends State<AllergyFilterScreen> {
  final List<String> _allergens = [
    'Dairy',
    'Eggs',
    'Peanuts',
    'Tree Nuts',
    'Fish',
    'Shellfish',
    'Soy',
    'Wheat',
    'Sesame',
    'Mustard',
  ];

  late Set<String> _selectedAllergens;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedAllergens = Set.from(widget.initialAllergens);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF7),
      body: Column(
        children: [
          // Top Green Header
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              left: 24,
              right: 24,
              bottom: 20,
            ),
            color: const Color(0xFF88AB92), // Sage green
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PantryChef',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // Allergy Filter Title Area
          Container(
            width: double.infinity,
            color: const Color(0xFFE8EFEA), // Very light green-grey
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: const Center(
              child: Text(
                'Allergy Filter',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF222222),
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Allergens to exclude:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Search Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF555555),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search Allergens (e.g., Coconut)',
                        hintStyle: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Color(0xFF222222)),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : const Icon(
                                Icons.search,
                                color: Color(0xFF222222),
                                size: 26,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Common Allergens',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Check to exclude:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Allergens List
                  ..._allergens
                      .where((allergen) =>
                          allergen.toLowerCase().contains(_searchQuery))
                      .map((allergen) => _buildAllergenItem(allergen)),

                  const SizedBox(height: 40),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C69),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, _selectedAllergens);
                      },
                      child: const Text(
                        'Apply Allergens',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergenItem(String allergen) {
    final bool isSelected = _selectedAllergens.contains(allergen);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedAllergens.remove(allergen);
            } else {
              _selectedAllergens.add(allergen);
            }
          });
        },
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFFD1D1D1),
                borderRadius: BorderRadius.circular(6),
                border: isSelected
                    ? Border.all(color: const Color(0xFF888888), width: 1)
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 20, color: Color(0xFF555555))
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              allergen,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF222222),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
