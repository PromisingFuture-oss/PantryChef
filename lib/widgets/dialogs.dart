import 'package:flutter/material.dart';
import '../models/recipe.dart';

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
                    'ðŸ” Reverse Recipe Search',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add ingredients you have â€” we\'ll rank matching recipes.',
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
                                'âœ“',
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
