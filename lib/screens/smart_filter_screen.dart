import 'package:flutter/material.dart';
import 'allergy_filter_screen.dart';

class SmartFilterScreen extends StatefulWidget {
  const SmartFilterScreen({super.key});

  @override
  State<SmartFilterScreen> createState() => _SmartFilterScreenState();
}

class _SmartFilterScreenState extends State<SmartFilterScreen> {
  String? _selectedDishType;

  bool _isVegetarian = true;
  bool _isVegan = true;
  bool _isGlutenFree = false;
  bool _isLowCarb = false;

  double _totalTime = 15;

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
                    children: const [
                      Text(
                        'Total Time',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF222222),
                        ),
                      ),
                      Text(
                        'mins',
                        style: TextStyle(
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
                      max: 30,
                      divisions: 2,
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
                          '15',
                          style: TextStyle(
                            color: Color(0xFF4A4A4A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '30',
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllergyFilterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Allergies Filter',
                        style: TextStyle(
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
                        Navigator.pop(context); // Go back
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
