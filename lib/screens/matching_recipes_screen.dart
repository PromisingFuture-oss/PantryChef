import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_search_service.dart';
import '../widgets/dialogs.dart';
import 'smart_filter_screen.dart';

class MatchingRecipesScreen extends StatefulWidget {
  final List<Recipe> recipeDatabase;
  final List<String> initialIngredients;

  const MatchingRecipesScreen({
    super.key,
    required this.recipeDatabase,
    required this.initialIngredients,
  });

  @override
  State<MatchingRecipesScreen> createState() => _MatchingRecipesScreenState();
}

class _MatchingRecipesScreenState extends State<MatchingRecipesScreen> {
  late List<String> _userIngredients;
  late List<RecipeMatch> _results;

  /// The full ingredient-matched results BEFORE any smart filter is applied.
  /// This is kept separate so that when the user re-opens the Smart Filter,
  /// they always filter from the original matched set — not from an already
  /// narrowed set (which causes results to vanish on successive filter taps).
  List<RecipeMatch>? _unfilteredResults;

  /// The recipe database narrowed by the current smart filter (if any).
  /// Used when re-searching with different ingredients via the search button.
  List<Recipe>? _filteredDatabase;

  // Active filter states to pass back to the filter screen
  String? _activeDishType;
  bool _activeIsVegetarian = false;
  bool _activeIsVegan = false;
  bool _activeIsGlutenFree = false;
  bool _activeIsLowCarb = false;
  double _activeTotalTime = 120;
  Set<String> _activeExcludedAllergens = {};

  @override
  void initState() {
    super.initState();
    _userIngredients = List.from(widget.initialIngredients);
    _performSearch();
  }

  void _performSearch() {
    _results = RecipeSearchService.search(
      database: _filteredDatabase ?? widget.recipeDatabase,
      userIngredients: _userIngredients,
    );
    // Keep a snapshot of the original unfiltered results.
    // We clone by ID so the match objects remain independent.
    _unfilteredResults = List.from(_results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Top Green Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 50,
                    left: 24,
                    right: 24,
                    bottom: 60,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF88AB92), // Sage green
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              // Menu action
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(
                        color: Colors.white54,
                        height: 1,
                        thickness: 1,
                      ),
                      const SizedBox(height: 30),
                      const Center(
                        child: Text(
                          'Your Matching Recipes',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // Ingredients floating card
                Positioned(
                  bottom: -40,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EFEA), // Very light green-grey
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Based on you ingredients:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: _userIngredients.map((ing) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      ing,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF555555),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                RecipeDialogs.showFindRecipes(
                                  context,
                                  widget.recipeDatabase,
                                  initialIngredients: _userIngredients,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF8C69),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filters row spacing (to offset the floating card)
          SliverToBoxAdapter(child: const SizedBox(height: 60)),

          // Filters Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () async {
                      // Always open the Smart Filter with the ORIGINAL (unfiltered)
                      // ingredient-matched recipes. This prevents a bug where:
                      //   Tap 1: filter by "Dinner"  → _results narrowed to Dinner
                      //   Tap 2: filter narrowing again on Dinner-only → even fewer results
                      //   Tap 3: etc → results quickly drop to 0.
                      //
                      // By always starting from _unfilteredResults, subsequent filter
                      // taps always work on the same full set of ingredient-matched recipes.
                      final baseMatches =
                          (_unfilteredResults ?? _results)
                              .map((r) => r.recipe)
                              .toList();
                      final result = await Navigator.push<SmartFilterResult>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SmartFilterScreen(
                            allRecipes: baseMatches,
                            initialDishType: _activeDishType,
                            initialIsVegetarian: _activeIsVegetarian,
                            initialIsVegan: _activeIsVegan,
                            initialIsGlutenFree: _activeIsGlutenFree,
                            initialIsLowCarb: _activeIsLowCarb,
                            initialTotalTime: _activeTotalTime,
                            initialExcludedAllergens: _activeExcludedAllergens,
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _activeDishType = result.dishType;
                          _activeIsVegetarian = result.isVegetarian;
                          _activeIsVegan = result.isVegan;
                          _activeIsGlutenFree = result.isGlutenFree;
                          _activeIsLowCarb = result.isLowCarb;
                          _activeTotalTime = result.totalTime;
                          _activeExcludedAllergens = result.excludedAllergens;

                          // Filter the ORIGINAL unfiltered results by recipe ID.
                          // This avoids re-running the ingredient search and preserves
                          // the exact match scores, matched/unmatched lists, and rankings.
                          // IMPORTANT: Always filter _unfilteredResults (the original full
                          // match set), NOT _results. On the second filter tap, _results
                          // is already narrowed from the first filter, so applying the new
                          // filter on it would produce an intersection that yields 0 results.
                          final resultIds = result.recipes.map((r) => r.id).toSet();
                          _results = (_unfilteredResults ?? _results)
                              .where((rm) => resultIds.contains(rm.recipe.id))
                              .toList();
                          // ✅ Also update _filteredDatabase so any subsequent ingredient
                          // change (via the search button) will search within this filtered set.
                          _filteredDatabase = result.recipes;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF78A083),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Smart filter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Found:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBE8E1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_results.length} Recipes',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5C8068),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Results List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildRecipeCard(_results[index], index + 1),
                );
              }, childCount: _results.length),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(RecipeMatch match, int rank) {
    final recipe = match.recipe;
    final int totalIngredients = recipe.ingredients.length;
    final int matchedCount = match.matchScore;
    final double matchPercent = match.matchRatio * 100;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Green Header Area
          Container(
            color: const Color(0xFF88AB92), // matching top header green
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image box
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    recipe.icon,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(width: 16),
                // Title and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16), // push badge to bottom
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Color(0xFF88AB92),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${recipe.timeMinutes} mins',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF555555),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Rank Badge
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF8C69),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // White Body Area
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$matchedCount / $totalIngredients ingredients matched',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A4A4A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${matchPercent.toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A4A4A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: match.matchRatio,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF8C69),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // You have
                if (match.matchedIngredients.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF78A083),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'You have:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: match.matchedIngredients
                        .map(
                          (i) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF88AB92), // matching green
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              i,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Still need
                if (match.unmatchedIngredients.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        size: 16,
                        color: Color(0xFF333333),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Still need:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: match.unmatchedIngredients
                        .map(
                          (i) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              i,
                              style: const TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Button
                Center(
                  child: InkWell(
                    onTap: () {
                      RecipeDialogs.showRecipeDetail(context, recipe);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8C69),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'View Step by Step ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
