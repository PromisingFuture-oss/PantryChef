import 'package:flutter/material.dart';
import 'allergy_filter_screen.dart';
import '../models/recipe.dart';

class SmartFilterResult {
  final List<Recipe> recipes;
  final String? dishType;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final bool isLowCarb;
  final double totalTime;
  final Set<String> excludedAllergens;

  SmartFilterResult({
    required this.recipes,
    this.dishType,
    required this.isVegetarian,
    required this.isVegan,
    required this.isGlutenFree,
    required this.isLowCarb,
    required this.totalTime,
    required this.excludedAllergens,
  });
}

class SmartFilterScreen extends StatefulWidget {
  final List<Recipe> allRecipes;
  final String? initialDishType;
  final bool initialIsVegetarian;
  final bool initialIsVegan;
  final bool initialIsGlutenFree;
  final bool initialIsLowCarb;
  final double initialTotalTime;
  final Set<String> initialExcludedAllergens;

  const SmartFilterScreen({
    super.key,
    required this.allRecipes,
    this.initialDishType,
    this.initialIsVegetarian = false,
    this.initialIsVegan = false,
    this.initialIsGlutenFree = false,
    this.initialIsLowCarb = false,
    this.initialTotalTime = 120,
    this.initialExcludedAllergens = const {},
  });

  @override
  State<SmartFilterScreen> createState() => _SmartFilterScreenState();
}

class _SmartFilterScreenState extends State<SmartFilterScreen> {
  String? _selectedDishType;

  bool _isVegetarian = false;
  bool _isVegan = false;
  bool _isGlutenFree = false;
  bool _isLowCarb = false;

  late double _totalTime;
  late Set<String> _excludedAllergens;

  @override
  void initState() {
    super.initState();
    _selectedDishType = widget.initialDishType;
    _isVegetarian = widget.initialIsVegetarian;
    _isVegan = widget.initialIsVegan;
    _isGlutenFree = widget.initialIsGlutenFree;
    _isLowCarb = widget.initialIsLowCarb;
    _totalTime = widget.initialTotalTime;
    _excludedAllergens = Set.from(widget.initialExcludedAllergens);
  }

  List<Recipe> _getFilteredRecipes() {
    return widget.allRecipes.where((recipe) {
      // 1. Time filter (if under 120 minutes)
      if (_totalTime < 120 && recipe.timeMinutes > _totalTime) {
        return false;
      }

      // 2. Dish type filter
      if (_selectedDishType != null) {
        final type = _selectedDishType!.toLowerCase();
        bool matchesType = recipe.category.toLowerCase() == type ||
            recipe.tags.any((tag) => tag.toLowerCase() == type);

        // Smart mapping: TheMealDB doesn't use "Lunch", "Dinner", or "Snack" as categories.
        // We map their ingredient-based categories to our dish types so filtering works.
        if (!matchesType) {
          final cat = recipe.category.toLowerCase();
          if (type == 'lunch') {
            matchesType = ['chicken', 'seafood', 'pasta', 'vegetarian', 'vegan', 'miscellaneous'].contains(cat);
          } else if (type == 'dinner') {
            matchesType = ['beef', 'pork', 'lamb', 'goat'].contains(cat);
          } else if (type == 'snack') {
            matchesType = ['starter', 'side', 'dessert'].contains(cat);
          }
        }

        if (!matchesType) return false;
      }

      // 3. Dietary filter
      if (_isVegetarian) {
        bool isVeg = recipe.category.toLowerCase() == 'vegetarian' ||
            recipe.category.toLowerCase() == 'vegan' ||
            recipe.tags.any((t) =>
                t.toLowerCase() == 'vegetarian' || t.toLowerCase() == 'vegan');

        // Smart check for Vegetarian by excluding meats (since MealDB often forgets tags)
        if (!isVeg) {
          final meatKeywords = ['chicken', 'beef', 'pork', 'lamb', 'bacon', 'sausage', 'ham', 'fish', 'salmon', 'shrimp', 'prawn', 'tuna', 'meat', 'steak', 'prosciutto', 'turkey'];
          isVeg = !recipe.ingredients.any(
              (ing) => meatKeywords.any((kw) => ing.toLowerCase().contains(kw)));
        }

        if (!isVeg) return false;
      }

      if (_isVegan) {
        bool isVegan = recipe.category.toLowerCase() == 'vegan' ||
            recipe.tags.any((t) => t.toLowerCase() == 'vegan');
        if (!isVegan) return false;
      }

      // Smart check for Gluten-Free by scanning ingredients
      if (_isGlutenFree) {
        final glutenKeywords = [
          'flour', 'wheat', 'bread', 'pasta', 'spaghetti', 'macaroni',
          'noodle', 'soy sauce', 'tortilla', 'pita', 'biscuit'
        ];
        bool hasGluten = recipe.ingredients.any(
            (ing) => glutenKeywords.any((kw) => ing.toLowerCase().contains(kw)));
        if (hasGluten) return false;
      }

      // Smart check for Low Carb by scanning ingredients
      if (_isLowCarb) {
        final carbKeywords = [
          'rice', 'pasta', 'bread', 'potato', 'sugar', 'flour', 'noodle',
          'spaghetti', 'honey', 'syrup', 'tortilla', 'biscuit'
        ];
        bool hasCarbs = recipe.ingredients.any(
            (ing) => carbKeywords.any((kw) => ing.toLowerCase().contains(kw)));
        if (hasCarbs) return false;
      }

      // 4. Allergy filter
      if (_excludedAllergens.isNotEmpty) {
        final Map<String, List<String>> allergyKeywords = {
          'Dairy': ['milk', 'cheese', 'butter', 'yogurt', 'cream', 'ghee', 'whey'],
          'Eggs': ['egg', 'mayonnaise', 'meringue'],
          'Peanuts': ['peanut'],
          'Tree Nuts': ['almond', 'walnut', 'pecan', 'cashew', 'pistachio', 'macadamia', 'hazelnut', 'pine nut'],
          'Fish': ['fish', 'salmon', 'tuna', 'cod', 'sardine', 'anchovy', 'tilapia', 'trout', 'halibut'],
          'Shellfish': ['shrimp', 'prawn', 'crab', 'lobster', 'mussel', 'oyster', 'scallop', 'clam', 'squid'],
          'Soy': ['soy', 'tofu', 'miso', 'edamame', 'tempeh'],
          'Wheat': ['wheat', 'flour', 'bread', 'pasta', 'noodle', 'soy sauce', 'pita', 'tortilla'],
          'Sesame': ['sesame', 'tahini'],
          'Mustard': ['mustard'],
        };

        bool hasAllergen = false;
        for (final allergen in _excludedAllergens) {
          final keywords = allergyKeywords[allergen] ?? [];
          if (recipe.ingredients.any((ing) => keywords.any((kw) => ing.toLowerCase().contains(kw)))) {
            hasAllergen = true;
            break;
          }
        }
        if (hasAllergen) return false;
      }

      return true;
    }).toList();
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
                  'Pantry Chef',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                  onPressed: () {
                    // Menu action
                  },
                ),
              ],
            ),
          ),

          // Smart Filter Title Area
          Container(
            width: double.infinity,
            color: const Color(0xFFE8EFEA), // Very light green-grey
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: const Center(
              child: Text(
                'Smart Filter',
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
                  // Dish Type Section
                  const Text(
                    'Dish Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDishTypeItem('Breakfast', '🥞'),
                      _buildDishTypeItem('Lunch', '🥗'),
                      _buildDishTypeItem('Dinner', '🥘'),
                      _buildDishTypeItem('Snack', '🍿'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Dietary Needs Section
                  const Text(
                    'Dietary Needs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDietarySwitch(
                    'Vegetarian',
                    Icons.eco_outlined,
                    _isVegetarian,
                    (val) => setState(() => _isVegetarian = val),
                  ),
                  _buildDietarySwitch(
                    'Vegan',
                    Icons.grass_outlined,
                    _isVegan,
                    (val) => setState(() => _isVegan = val),
                  ),
                  _buildDietarySwitch(
                    'Gluten-Free',
                    Icons.no_food_outlined,
                    _isGlutenFree,
                    (val) => setState(() => _isGlutenFree = val),
                  ),
                  _buildDietarySwitch(
                    'Low Carb',
                    Icons.opacity_outlined,
                    _isLowCarb,
                    (val) => setState(() => _isLowCarb = val),
                  ),

                  const SizedBox(height: 24),

                  // Total Time Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Time',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF222222),
                        ),
                      ),
                      Text(
                        _totalTime == 120
                            ? 'No limit'
                            : '${_totalTime.toInt()} mins',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 6,
                      activeTrackColor: const Color(0xFFFF8C69),
                      inactiveTrackColor: const Color(0xFFD6D6D6),
                      thumbColor: const Color(0xFFFF8C69),
                      overlayColor: const Color(
                        0xFFFF8C69,
                      ).withValues(alpha: 0.2),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Slider(
                      value: _totalTime,
                      min: 0,
                      max: 120,
                      divisions: 8,
                      onChanged: (value) {
                        setState(() {
                          _totalTime = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '0',
                          style: TextStyle(
                            color: Color(0xFF4A4A4A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '60',
                          style: TextStyle(
                            color: Color(0xFF4A4A4A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '120+',
                          style: TextStyle(
                            color: Color(0xFF4A4A4A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Allergies Filter Button
                  Center(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF88AB92),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push<Set<String>>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllergyFilterScreen(
                              initialAllergens: _excludedAllergens,
                            ),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _excludedAllergens = result;
                          });
                        }
                      },
                      child: Text(
                        _excludedAllergens.isNotEmpty
                            ? 'Allergies Filter (${_excludedAllergens.length})'
                            : 'Allergies Filter',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Apply Filters Button
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
                      final filteredRecipes = _getFilteredRecipes();
                      Navigator.pop(
                        context,
                        SmartFilterResult(
                          recipes: filteredRecipes,
                          dishType: _selectedDishType,
                          isVegetarian: _isVegetarian,
                          isVegan: _isVegan,
                          isGlutenFree: _isGlutenFree,
                          isLowCarb: _isLowCarb,
                          totalTime: _totalTime,
                          excludedAllergens: _excludedAllergens,
                        ),
                      );
                      },
                      child: const Text(
                        'Apply Filters',
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

  Widget _buildDishTypeItem(String title, String emoji) {
    final bool isSelected = _selectedDishType == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDishType = isSelected ? null : title;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EFEA),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: const Color(0xFF88AB92), width: 2)
                  : Border.all(color: const Color(0xFFB0B0B0), width: 1),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF222222),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietarySwitch(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF555555)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF222222),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF88AB92),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFC0C0C0),
          ),
        ],
      ),
    );
  }
}
