import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../utils/decorations.dart';
import '../screens/recipe_detail_page.dart';
import '../screens/matching_recipes_screen.dart';

class RecipeDialogs {
  static void showRecipeDetail(BuildContext context, Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: recipe)),
    );
  }

  static void showFindRecipes(
    BuildContext context,
    List<Recipe> recipeDatabase, {
    List<String> initialIngredients = const [],
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => FindRecipesDialog(
        recipeDatabase: recipeDatabase,
        pageContext: context,
        initialIngredients: initialIngredients,
      ),
    );
  }

  /// Builds a single ranked result card.
  static Widget _buildResultCard({
    required BuildContext context,
    required RecipeMatch match,
    required int rank,
    required VoidCallback onViewRecipe,
  }) {
    final ratio = match.matchRatio;
    final Color badgeColor = ratio >= 0.75
        ? const Color(0xFF3A7A50)
        : ratio >= 0.4
        ? const Color(0xFF78A083)
        : const Color(0xFFFF8C69);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8F3EA), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF78A083).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header — recipe name + rank badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4FAF5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                // Rank badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(match.recipe.icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    match.recipe.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF2C3E30),
                    ),
                  ),
                ),
                // Time chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDE8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '⏱ ${match.recipe.timeMinutes} min',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD94F2A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Match score + progress bar
                Row(
                  children: [
                    Text(
                      '${match.matchScore} / ${match.recipe.ingredients.length} ingredients matched',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: badgeColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(ratio * 100).round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: const Color(0xFFE8F3EA),
                    valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),

                // Matched ingredients (highlighted)
                if (match.matchedIngredients.isNotEmpty) ...[
                  const Text(
                    '✅ You have:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3A7A50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: match.matchedIngredients.map((ing) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEF0E5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ing,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2D6A42),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Unmatched ingredients (muted)
                if (match.unmatchedIngredients.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '🛒 Still need:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: match.unmatchedIngredients.map((ing) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ing,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 14),

                // View full recipe button
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF78A083),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onViewRecipe,
                    child: const Text(
                      'View Full Recipe →',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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

  /// Empty state widget when no recipes match.
  static Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE0D6)),
      ),
      child: const Column(
        children: [
          Text('🥺', style: TextStyle(fontSize: 48)),
          SizedBox(height: 10),
          Text(
            'No matching recipes found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try adding more ingredients or use simpler keywords (e.g. "egg" instead of "eggs").',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF777777)),
          ),
        ],
      ),
    );
  }
}

class FindRecipesDialog extends StatefulWidget {
  const FindRecipesDialog({
    super.key,
    required this.recipeDatabase,
    required this.pageContext,
    this.initialIngredients = const [],
  });

  final List<Recipe> recipeDatabase;
  final BuildContext pageContext;
  final List<String> initialIngredients;

  @override
  State<FindRecipesDialog> createState() => _FindRecipesDialogState();
}

class _FindRecipesDialogState extends State<FindRecipesDialog> {
  late final TextEditingController _inputController;
  late List<String> _selectedIngredients;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _selectedIngredients = List.from(widget.initialIngredients);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addIngredient(String value) {
    final ingredient = value.trim();
    if (ingredient.isEmpty || _selectedIngredients.contains(ingredient)) {
      _inputController.clear();
      return;
    }
    if (mounted) {
      setState(() {
        _selectedIngredients.add(ingredient);
        _inputController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF78A083), Color(0xFF9BC4A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔍 Reverse Recipe Search',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add ingredients you have — we\'ll rank matching recipes.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: 'Add recipe',
                              prefixIcon: const Icon(
                                Icons.set_meal_outlined,
                                color: Color(0xFF78A083),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF78A083),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: _addIngredient,
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF78A083),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () =>
                              _addIngredient(_inputController.text),
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_selectedIngredients.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedIngredients.map((ingredient) {
                          return Chip(
                            avatar: const CircleAvatar(
                              backgroundColor: Color(0xFF5C8068),
                              child: Text(
                                '✓',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            label: Text(ingredient),
                            backgroundColor: const Color(0xFF78A083),
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            deleteIconColor: Colors.white70,
                            onDeleted: () {
                              if (mounted) {
                                setState(() {
                                  _selectedIngredients.remove(ingredient);
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C69),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (_selectedIngredients.isEmpty) {
                            ScaffoldMessenger.of(
                              widget.pageContext,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please add at least one ingredient.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          FocusScope.of(widget.pageContext).unfocus();
                          Navigator.of(context).pop();
                          Navigator.of(widget.pageContext).push(
                            MaterialPageRoute(
                              builder: (context) => MatchingRecipesScreen(
                                recipeDatabase: widget.recipeDatabase,
                                initialIngredients: _selectedIngredients,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.search),
                        label: const Text(
                          'Search Recipes',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    FocusScope.of(widget.pageContext).unfocus();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
