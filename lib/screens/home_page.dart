import 'dart:async';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/meal_db_populator.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/dialogs.dart';
import 'sections.dart';
import 'pantry_shopping_screen.dart';
import '../models/pantry_item.dart';
import '../services/database_helper.dart';

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
  bool _hasShownWarning = false;

  int _getDaysUntilExpiration(String expDate) {
    if (expDate == '-') return 999;
    try {
      final parts = expDate.split('/');
      if (parts.length == 2) {
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final now = DateTime.now();
        var expDateTime = DateTime(now.year, month, day);
        if (expDateTime.isBefore(now) && now.difference(expDateTime).inDays > 180) {
          expDateTime = DateTime(now.year + 1, month, day);
        }
        final today = DateTime(now.year, now.month, now.day);
        return expDateTime.difference(today).inDays;
      }
    } catch (e) {
      // ignore
    }
    return 999;
  }

  Future<void> _checkAndShowExpirationWarning() async {
    if (_hasShownWarning) return;
    
    final items = await DatabaseHelper.instance.getAllPantryItems();
    List<PantryItem> expiringItems = [];
    
    for (var item in items) {
      if (item.isChecked && item.exp != '-') {
        final days = _getDaysUntilExpiration(item.exp);
        if (days <= 3) expiringItems.add(item);
      }
    }

    if (expiringItems.isNotEmpty && mounted) {
      _hasShownWarning = true;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text('Expiring Soon!', style: TextStyle(color: Colors.orange)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('The following items in your Pantry are expiring within 3 days or already expired:'),
                const SizedBox(height: 12),
                ...expiringItems.map((item) => Text('• ${item.name} (${item.exp})')),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it', style: TextStyle(color: Color(0xFF78A083))),
              ),
            ],
          );
        }
      );
    }
  }

  /// The full list of recipes available for searching.
  ///
  /// Initially populated with the hardcoded list. If [MealDbPopulator]
  /// has a cached dataset, those recipes replace this list (or are
  /// fetched on first launch and cached for offline use).
  List<Recipe> _allRecipes = _hardcodedRecipes();

  /// The up to 10 random recipes displayed on the home page as suggestions.
  late List<Recipe> _suggestedRecipes;

  /// The hardcoded fallback recipe list used when offline / first launch.
  static List<Recipe> _hardcodedRecipes() {
    return [
      Recipe(
        id: 'spaghetti',
        name: 'Spaghetti Aglio e Olio',
        icon: '🍝',
        timeMinutes: 15,
        category: 'Pasta',
        tags: const ['Vegetarian', 'Dinner'],
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
        category: 'Vegetarian',
        tags: const ['Lunch', 'Dinner'],
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
        category: 'Chicken',
        tags: const ['Dinner'],
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
        category: 'Miscellaneous',
        tags: const ['Lunch', 'Snack', 'Vegetarian'],
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
        timeMinutes: 45,
        category: 'Breakfast',
        tags: const ['Vegetarian'],
        imageUrl:
            'https://images.immediate.co.uk/production/volatile/sites/30/2020/08/spanish-omelette-7c2250c.jpg',
        ingredients: const [
          '6 Eggs',
          '3 Potatoes',
          '1 Onion',
          '150ml extra-virgin olive oil',
          '3 tbsp chopped flat-leaf parsley',
        ],
        instructions: const [
          'Scrape the new potatoes or leave the skins on, if you prefer. Cut them into thick slices. Chop the onion.',
          'Heat the extra-virgin olive oil in a large frying pan, add the potatoes and onion and stew gently, partially covered, for 30 mins, stirring occasionally until the potatoes are softened. Strain the potatoes and onion through a colander into a large bowl (set the strained oil aside).',
          'Beat the eggs then stir into the potatoes with the parsley and plenty of salt and pepper. Heat a little of the strained oil in a smaller pan.',
          'Tip everything into the pan and cook on a moderate heat until the bottom is golden and the top is almost set.',
          'Invert the omelette onto a plate and slide back into the pan. Cook for another 5 minutes until golden on both sides.',
        ],
      ),
      Recipe(
        id: 'curry',
        name: 'Vegetable Curry',
        icon: '🥘',
        timeMinutes: 30,
        category: 'Vegetarian',
        tags: const ['Vegan', 'Dinner'],
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
        category: 'Breakfast',
        tags: const ['Vegetarian', 'Snack'],
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
  }

  @override
  void initState() {
    super.initState();

    _allRecipes.shuffle();
    _suggestedRecipes = _allRecipes.take(10).toList();

    // Hide the loading animation after a short delay.
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showLoading = false;
        });
      }
    });

    // Attempt to load recipes from MealDbPopulator cache (fast, local file).
    // If a cache exists, replace the hardcoded list. On first launch the
    // populator will fetch from TheMealDB in the background.
    _loadFromCache();
  }

  Future<void> _loadFromCache() async {
    final cached = await MealDbPopulator.getRecipes();

    if (!mounted) return;

    if (cached != null && cached.isNotEmpty) {
      // Successfully loaded from cache (or freshly fetched).
      cached.shuffle();
      setState(() {
        _allRecipes = cached;
        _suggestedRecipes = cached.take(10).toList();
        _showLoading = false;
      });

      if (mounted) {
        _showCacheSnackBar(
          '✅ Loaded ${cached.length} recipes from TheMealDB!',
        );
      }
    } else {
      // No cache and no network — using hardcoded fallback.
      if (mounted) {
        _showCacheSnackBar(
          '📖 Using ${_allRecipes.length} built-in recipes (offline)',
        );
      }
    }
  }

  void _showCacheSnackBar(String message) {
    // Delay slightly so it shows after the loading animation fades.
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
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

    if (key == _cookSectionKey) {
      _checkAndShowExpirationWarning();
    }

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  List<Widget> _buildResponsiveActions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      return [
        PopupMenuButton<String>(
          color: Colors.white,
          icon: const Icon(Icons.menu, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'cook':
                _scrollToSection(_cookSectionKey);
                break;
              case 'recipes':
                _scrollToSection(_recipesSectionKey);
                break;
              case 'pantry':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantryShoppingScreen(),
                  ),
                );
                break;
              case 'about':
                _scrollToSection(_aboutSectionKey);
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'cook',
              child: Text('👩‍🍳 Let\'s cook'),
            ),
            const PopupMenuItem(value: 'recipes', child: Text('📖 Recipes')),
            const PopupMenuItem(
              value: 'pantry',
              child: Text('🍱 Pantry & Shopping list'),
            ),
            const PopupMenuItem(value: 'about', child: Text('👥 About Us')),
          ],
        ),
        const SizedBox(width: 8),
      ];
    }

    return [
      NavButton(
        label: '👩‍🍳 Let\'s cook',
        isPrimary: true,
        onPressed: () => _scrollToSection(_cookSectionKey),
      ),
      NavButton(
        label: '📖 Recipes',
        onPressed: () => _scrollToSection(_recipesSectionKey),
      ),
      NavButton(
        label: '🍱 Pantry & Shopping list',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PantryShoppingScreen(),
            ),
          );
        },
      ),
      NavButton(
        label: '👥 About Us',
        onPressed: () => _scrollToSection(_aboutSectionKey),
      ),
      const SizedBox(width: 16),
    ];
  }

  bool _isCookSectionVisible() {
    final context = _cookSectionKey.currentContext;
    if (context == null) return false;
    try {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero).dy;
      final screenHeight = MediaQuery.of(this.context).size.height;
      return position < screenHeight && position > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo is ScrollEndNotification && !_hasShownWarning) {
                if (_isCookSectionVisible()) {
                  _checkAndShowExpirationWarning();
                }
              }
              return false;
            },
            child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: LandingSection(
                  onStartTap: () => _scrollToSection(_cookSectionKey),
                ),
              ),
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
                actions: _buildResponsiveActions(context),
              ),
              SliverToBoxAdapter(
                child: HeroSection(
                  onFindRecipesTap: () =>
                      RecipeDialogs.showFindRecipes(context, _allRecipes),
                  onScrollTap: () => _scrollToSection(_cookSectionKey),
                  scrollControllerKey: _cookSectionKey,
                ),
              ),
              SliverToBoxAdapter(child: const FeaturesSection()),
              SliverToBoxAdapter(
                child: RecipesSection(
                  recipes: _suggestedRecipes,
                  sectionKey: _recipesSectionKey,
                  onRecipeTap: (recipe) =>
                      RecipeDialogs.showRecipeDetail(context, recipe),
                ),
              ),
              SliverToBoxAdapter(
                child: AboutSection(sectionKey: _aboutSectionKey),
              ),
              SliverToBoxAdapter(child: const Footer()),
            ],
          ),
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
                      LoadingPancake(),
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
}
