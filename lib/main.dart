import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const PantryChefApp());
}

class PantryChefApp extends StatelessWidget {
  const PantryChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF78A083),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Pantry Chef',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFFDFAF5),
        textTheme: GoogleFonts.quicksandTextTheme(),
        useMaterial3: true,
      ),
      home: const PantryChefHomePage(),
    );
  }
}

class PantryChefHomePage extends StatefulWidget {
  const PantryChefHomePage({super.key});

  @override
  State<PantryChefHomePage> createState() => _PantryChefHomePageState();
}

class _PantryChefHomePageState extends State<PantryChefHomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _cookSectionKey = GlobalKey();
  final GlobalKey _recipesSectionKey = GlobalKey();
  final GlobalKey _aboutSectionKey = GlobalKey();

  bool _showLoading = true;

  late final List<Recipe> _recipes = [
    Recipe(
      id: 'spaghetti',
      name: 'Spaghetti Aglio e Olio',
      icon: '🍝',
      timeMinutes: 15,
      ingredients: const [
        '400g Spaghetti',
        '6 cloves Garlic (thinly sliced)',
        '1/2 cup Olive Oil',
        '1 tsp Red Pepper Flakes',
        'Fresh Parsley (chopped)',
        'Parmesan Cheese (grated)',
      ],
      instructions: const [
        'Bring a large pot of salted water to boil and cook spaghetti until al dente.',
        'Heat olive oil in a pan over medium heat.',
        'Add garlic and pepper flakes; saute until garlic is golden.',
        'Drain pasta, reserving a little pasta water.',
        'Toss pasta in garlic oil and loosen with pasta water as needed.',
        'Finish with parsley and parmesan, then serve.',
      ],
    ),
    Recipe(
      id: 'friedrice',
      name: 'Vegetable Fried Rice',
      icon: '🍚',
      timeMinutes: 20,
      ingredients: const [
        '3 cups Cooked Rice',
        '2 Eggs',
        '2 cups Mixed Vegetables',
        '3 tbsp Soy Sauce',
        '3 cloves Garlic',
        '1 tbsp Ginger',
      ],
      instructions: const [
        'Scramble eggs and set aside.',
        'Saute garlic and ginger, then add vegetables.',
        'Add rice and soy sauce, stirring over high heat.',
        'Return eggs and toss with green onions before serving.',
      ],
    ),
    Recipe(
      id: 'stirfry',
      name: 'Chicken Stir Fry',
      icon: '🥗',
      timeMinutes: 25,
      ingredients: const [
        '500g Chicken Breast',
        '2 Bell Peppers',
        '2 cups Broccoli',
        '3 tbsp Soy Sauce',
        '1 tbsp Ginger',
      ],
      instructions: const [
        'Marinate chicken with soy sauce and cornstarch.',
        'Stir-fry chicken until golden and set aside.',
        'Cook aromatics and vegetables in a hot wok.',
        'Return chicken, toss well, and cook through.',
      ],
    ),
    Recipe(
      id: 'grilledcheese',
      name: 'Grilled Cheese Sandwich',
      icon: '🥪',
      timeMinutes: 10,
      ingredients: const [
        '2 slices Bread',
        '2-3 slices Cheese',
        '2 tbsp Butter',
        'Tomato (optional)',
      ],
      instructions: const [
        'Butter one side of each bread slice.',
        'Layer cheese between bread slices.',
        'Toast both sides in a pan until golden and melty.',
      ],
    ),
    Recipe(
      id: 'omelette',
      name: 'Spanish Omelette',
      icon: '🍳',
      timeMinutes: 20,
      ingredients: const [
        '6 Eggs',
        '3 Potatoes',
        '1 Onion',
        'Olive Oil',
        'Salt and Pepper',
      ],
      instructions: const [
        'Cook sliced potatoes and onion until tender.',
        'Mix cooked vegetables with beaten eggs.',
        'Cook gently in a pan, flip once, and finish.',
      ],
    ),
    Recipe(
      id: 'curry',
      name: 'Vegetable Curry',
      icon: '🥘',
      timeMinutes: 30,
      ingredients: const [
        'Mixed Vegetables',
        '1 can Coconut Milk',
        '2 tbsp Curry Powder',
        'Onion, Garlic, Ginger',
      ],
      instructions: const [
        'Saute onion, garlic, and ginger.',
        'Toast curry powder, then add vegetables.',
        'Pour coconut milk and simmer until tender.',
      ],
    ),
    Recipe(
      id: 'pancakes',
      name: 'Pancakes',
      icon: '🥞',
      timeMinutes: 15,
      ingredients: const [
        '2 Eggs',
        '1 cup Milk',
        '1 1/2 cups Flour',
        'Butter',
        'Sugar and Baking Powder',
      ],
      instructions: const [
        'Whisk dry and wet ingredients separately.',
        'Combine to make a smooth batter.',
        'Cook on a hot pan until both sides are golden.',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToSection(GlobalKey key) async {
    final context = key.currentContext;
    if (context == null) {
      return;
    }

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  void _openRecipeDetail(Recipe recipe) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(recipe.icon, style: const TextStyle(fontSize: 64)),
                        const SizedBox(height: 8),
                        Text(
                          recipe.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF78A083),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '⏱️ ${recipe.timeMinutes} minutes',
                          style: const TextStyle(
                            color: Color(0xFFFF8C69),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF78A083),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recipe.ingredients.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('• $item'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF78A083),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recipe.instructions.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text('${entry.key + 1}. ${entry.value}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openFindRecipesDialog() {
    final TextEditingController inputController = TextEditingController();
    final List<String> selectedIngredients = [];

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        List<SuggestedRecipe> suggestions = [];

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Find Recipes with Your Ingredients',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF78A083),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: inputController,
                          decoration: InputDecoration(
                            hintText: 'Type ingredient and press Enter',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onSubmitted: (value) {
                            final ingredient = value.trim();
                            if (ingredient.isEmpty ||
                                selectedIngredients.contains(ingredient)) {
                              return;
                            }
                            setStateDialog(() {
                              selectedIngredients.add(ingredient);
                              inputController.clear();
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedIngredients
                              .map(
                                (ingredient) => Chip(
                                  label: Text(ingredient),
                                  backgroundColor: const Color(0xFF78A083),
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                  deleteIconColor: Colors.white,
                                  onDeleted: () {
                                    setStateDialog(() {
                                      selectedIngredients.remove(ingredient);
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8C69),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              if (selectedIngredients.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please add at least one ingredient.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              setStateDialog(() {
                                suggestions = [
                                  SuggestedRecipe(
                                    name: 'Quick Stir Fry',
                                    matchedIngredients:
                                        selectedIngredients.take(3).toList(),
                                    instructions:
                                        '1. Heat oil\n2. Stir-fry ingredients\n3. Season with soy sauce\n4. Serve with rice',
                                  ),
                                  SuggestedRecipe(
                                    name: 'Simple Pasta',
                                    matchedIngredients:
                                        selectedIngredients.take(2).toList(),
                                    instructions:
                                        '1. Boil pasta\n2. Saute ingredients in olive oil\n3. Toss together\n4. Add herbs and cheese',
                                  ),
                                  SuggestedRecipe(
                                    name: 'Fresh Salad Bowl',
                                    matchedIngredients:
                                        selectedIngredients.take(4).toList(),
                                    instructions:
                                        '1. Chop everything\n2. Mix in a bowl\n3. Add dressing\n4. Toss and serve',
                                  ),
                                ];
                              });
                            },
                            child: const Text('Find Recipes'),
                          ),
                        ),
                        if (suggestions.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Suggested Recipes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF78A083),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...suggestions.map(
                            (recipe) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FDF9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFFF8C69),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Using your ingredients: ${recipe.matchedIngredients.join(', ')}',
                                  ),
                                  const SizedBox(height: 6),
                                  Text(recipe.instructions.replaceAll('\n', '\n')),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Close'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(inputController.dispose);
  }

  void _openAddRecipeDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emojiController = TextEditingController();
    final timeController = TextEditingController();
    final ingredientNameController = TextEditingController();
    final ingredientQtyController = TextEditingController();
    final stepController = TextEditingController();

    final List<IngredientAmount> ingredients = [];
    final List<String> instructionSteps = [];

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650, maxHeight: 700),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add New Recipe',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF78A083),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: nameController,
                            decoration: _fieldDecoration('Recipe Name'),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: emojiController,
                            decoration: _fieldDecoration('Emoji (e.g., 🍝)'),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: timeController,
                            keyboardType: TextInputType.number,
                            decoration: _fieldDecoration('Cooking Time in minutes'),
                            validator: (value) {
                              final parsed = int.tryParse(value ?? '');
                              if (parsed == null || parsed <= 0) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Ingredients',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: ingredientNameController,
                                  decoration: _fieldDecoration(
                                    'Ingredient name',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: ingredientQtyController,
                                  decoration: _fieldDecoration('Quantity'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF78A083),
                                ),
                                onPressed: () {
                                  final name = ingredientNameController.text
                                      .trim();
                                  final qty = ingredientQtyController.text.trim();
                                  if (name.isEmpty || qty.isEmpty) {
                                    return;
                                  }
                                  setStateDialog(() {
                                    ingredients.add(
                                      IngredientAmount(
                                        ingredient: name,
                                        amount: qty,
                                      ),
                                    );
                                    ingredientNameController.clear();
                                    ingredientQtyController.clear();
                                  });
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ingredients
                                .map(
                                  (item) => Chip(
                                    label: Text(
                                      '${item.ingredient} - ${item.amount}',
                                    ),
                                    backgroundColor: const Color(0xFF78A083),
                                    labelStyle:
                                        const TextStyle(color: Colors.white),
                                    deleteIconColor: Colors.white,
                                    onDeleted: () {
                                      setStateDialog(() {
                                        ingredients.remove(item);
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Instructions',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: stepController,
                                  minLines: 2,
                                  maxLines: 3,
                                  decoration: _fieldDecoration('Enter step'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF78A083),
                                ),
                                onPressed: () {
                                  final step = stepController.text.trim();
                                  if (step.isEmpty) {
                                    return;
                                  }
                                  setStateDialog(() {
                                    instructionSteps.add(step);
                                    stepController.clear();
                                  });
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...instructionSteps.asMap().entries.map(
                            (entry) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FDF9),
                                borderRadius: BorderRadius.circular(8),
                                border: const Border(
                                  left: BorderSide(
                                    color: Color(0xFF78A083),
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: const Color(0xFF78A083),
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(entry.value)),
                                  IconButton(
                                    onPressed: () {
                                      setStateDialog(() {
                                        instructionSteps.removeAt(entry.key);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Color(0xFFFF6B4A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8C69),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }
                                if (ingredients.isEmpty ||
                                    instructionSteps.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Add at least one ingredient and instruction.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final newRecipe = Recipe(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  name: nameController.text.trim(),
                                  icon: emojiController.text.trim(),
                                  timeMinutes:
                                      int.parse(timeController.text.trim()),
                                  ingredients: ingredients
                                      .map(
                                        (item) =>
                                            '${item.ingredient} - ${item.amount}',
                                      )
                                      .toList(),
                                  instructions: instructionSteps.toList(),
                                );

                                setState(() {
                                  _recipes.add(newRecipe);
                                });

                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Recipe added successfully!'),
                                  ),
                                );
                              },
                              child: const Text('Save Recipe'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      emojiController.dispose();
      timeController.dispose();
      ingredientNameController.dispose();
      ingredientQtyController.dispose();
      stepController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildLandingSection()),
              SliverAppBar(
                pinned: true,
                expandedHeight: 92,
                toolbarHeight: 92,
                backgroundColor: const Color(0xFF78A083),
                titleSpacing: 20,
                title: InkWell(
                  onTap: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOut,
                    );
                  },
                  child: const Text(
                    'Pantry Chef',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                actions: [
                  _NavButton(
                    label: '👩‍🍳 Let\'s cook',
                    isPrimary: true,
                    onPressed: () => _scrollToSection(_cookSectionKey),
                  ),
                  _NavButton(
                    label: '📖 Recipes',
                    onPressed: () => _scrollToSection(_recipesSectionKey),
                  ),
                  _NavButton(
                    label: '✨ Add new Recipe',
                    onPressed: _openAddRecipeDialog,
                  ),
                  _NavButton(
                    label: '👥 About Us',
                    onPressed: () => _scrollToSection(_aboutSectionKey),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              SliverToBoxAdapter(child: _buildHeroSection()),
              SliverToBoxAdapter(child: _buildFeaturesSection()),
              SliverToBoxAdapter(child: _buildRecipesSection()),
              SliverToBoxAdapter(child: _buildAboutSection()),
              SliverToBoxAdapter(child: _buildFooter()),
            ],
          ),
        ),
        if (_showLoading)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _showLoading ? 1 : 0,
              duration: const Duration(milliseconds: 450),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF78A083), Color(0xFF9BC4A3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LoadingPancake(),
                      SizedBox(height: 12),
                      Text(
                        'Cooking up something delicious...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLandingSection() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF78A083), Color(0xFF9BC4A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pantry Chef',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 62,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Transform your ingredients into culinary masterpieces. Cook smart, reduce waste, and discover endless recipe possibilities.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => _scrollToSection(_cookSectionKey),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE0E0E0), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.black87, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF555555), Color(0xFF333333)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Turn to Start',
                    style: TextStyle(
                      color: Color(0xFFFDFAF5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      key: _cookSectionKey,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const Text(
                'Cook with What You Have',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  color: Color(0xFF78A083),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Turn your leftover ingredients into delicious meals with personalized recipe suggestions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 14),
              const Text('🍳', style: TextStyle(fontSize: 62)),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C69),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                ),
                onPressed: _openFindRecipesDialog,
                child: const Text(
                  'Find Recipes',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Why Pantry Chef?',
                style: TextStyle(
                  fontSize: 34,
                  color: Color(0xFF78A083),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900
                      ? 4
                      : constraints.maxWidth > 600
                      ? 2
                      : 1;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.1,
                    children: const [
                      _FeatureCard(
                        title: '🍲 Smart Recipe Suggestions',
                        description:
                            'Enter your ingredients and get recipes tailored to what you already have.',
                      ),
                      _FeatureCard(
                        title: '🥗 Reduce Food Waste',
                        description:
                            'Use every ingredient in your pantry and save money while helping the environment.',
                      ),
                      _FeatureCard(
                        title: '⏱️ Save Time',
                        description:
                            'No more searching for hours, find the perfect recipe in seconds.',
                      ),
                      _FeatureCard(
                        title: '📱 Easy to Use',
                        description:
                            'Simple and intuitive design for a seamless cooking experience.',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipesSection() {
    return Container(
      key: _recipesSectionKey,
      width: double.infinity,
      color: const Color(0xFFF9FDF9),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Featured Recipes',
                style: TextStyle(
                  fontSize: 34,
                  color: Color(0xFF78A083),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1000
                      ? 3
                      : constraints.maxWidth > 650
                      ? 2
                      : 1;

                  return GridView.builder(
                    itemCount: _recipes.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.92,
                    ),
                    itemBuilder: (context, index) {
                      final recipe = _recipes[index];
                      return _RecipeCard(
                        recipe: recipe,
                        onTap: () => _openRecipeDetail(recipe),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      key: _aboutSectionKey,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 52),
      color: Colors.white,
      child: const Center(
        child: Column(
          children: [
            Text(
              'Meet the Team',
              style: TextStyle(
                fontSize: 34,
                color: Color(0xFF78A083),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Developed by - 3BSIT-1 The Invokables',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, color: Color(0xFF555555)),
            ),
            SizedBox(height: 8),
            Text(
              'Jaymar B. Riveral, Adam Riggs P. Mendoza, and Aryana Kristina S. Manguerra',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Color(0xFF555555)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF78A083),
      padding: const EdgeInsets.all(22),
      child: const Center(
        child: Text(
          '© 2026 Pantry Chef Project - Capstone Project 1',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
      ),
    );
  }
}

class _LoadingPancake extends StatefulWidget {
  const _LoadingPancake();

  @override
  State<_LoadingPancake> createState() => _LoadingPancakeState();
}

class _LoadingPancakeState extends State<_LoadingPancake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * 3.1415926535;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateY(angle)
            ..rotateZ(angle),
          child: const Text('🥞', style: TextStyle(fontSize: 78)),
        );
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFFFF8C69) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF78A083),
          shape: const StadiumBorder(),
          visualDensity: VisualDensity.compact,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF78A083),
              ),
            ),
            const SizedBox(height: 10),
            Text(description, style: const TextStyle(color: Color(0xFF666666))),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 26),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [Color(0xFFE8F0EA), Color(0xFFFDFAF5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                recipe.icon,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 54),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 21,
                        color: Color(0xFF78A083),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '⏱️ ${recipe.timeMinutes} minutes',
                      style: const TextStyle(
                        color: Color(0xFFFF8C69),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ingredients: ${recipe.ingredients.take(4).join(', ')}${recipe.ingredients.length > 4 ? '...' : ''}',
                      style: const TextStyle(color: Color(0xFF666666), height: 1.4),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Recipe {
  Recipe({
    required this.id,
    required this.name,
    required this.icon,
    required this.timeMinutes,
    required this.ingredients,
    required this.instructions,
  });

  final String id;
  final String name;
  final String icon;
  final int timeMinutes;
  final List<String> ingredients;
  final List<String> instructions;
}

class IngredientAmount {
  IngredientAmount({required this.ingredient, required this.amount});

  final String ingredient;
  final String amount;
}

class SuggestedRecipe {
  SuggestedRecipe({
    required this.name,
    required this.matchedIngredients,
    required this.instructions,
  });

  final String name;
  final List<String> matchedIngredients;
  final String instructions;
}
