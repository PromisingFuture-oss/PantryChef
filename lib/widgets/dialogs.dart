import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_search_service.dart';
import '../utils/decorations.dart';


class RecipeDialogs {
  static void showRecipeDetail(BuildContext context, Recipe recipe) {
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

  static void showFindRecipes(
    BuildContext context,
    List<Recipe> recipeDatabase,
  ) {
    final TextEditingController inputController = TextEditingController();
    final List<String> selectedIngredients = [];

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        List<RecipeMatch> results = [];
        bool hasSearched = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF78A083), Color(0xFF9BC4A3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
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

                    // ── Scrollable body ──────────────────────────────────────
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Input row
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: inputController,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      hintText: 'e.g. eggs, rice, chicken …',
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
                                    onSubmitted: (value) {
                                      _addIngredient(
                                        value,
                                        selectedIngredients,
                                        inputController,
                                        setStateDialog,
                                      );
                                    },
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
                                  onPressed: () => _addIngredient(
                                    inputController.text,
                                    selectedIngredients,
                                    inputController,
                                    setStateDialog,
                                  ),
                                  child: const Icon(Icons.add),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Ingredient chips
                            if (selectedIngredients.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: selectedIngredients.map((ingredient) {
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
                                      setStateDialog(() {
                                        selectedIngredients.remove(ingredient);
                                        // Re-run search if results are showing
                                        if (hasSearched) {
                                          results = RecipeSearchService.search(
                                            database: recipeDatabase,
                                            userIngredients: selectedIngredients,
                                          );
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),

                            const SizedBox(height: 16),

                            // Search button
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF8C69),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  if (selectedIngredients.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please add at least one ingredient.',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }
                                  setStateDialog(() {
                                    hasSearched = true;
                                    results = RecipeSearchService.search(
                                      database: recipeDatabase,
                                      userIngredients: selectedIngredients,
                                    );
                                  });
                                },
                                icon: const Icon(Icons.search),
                                label: const Text(
                                  'Search Recipes',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),

                            // ── Results ──────────────────────────────────────
                            if (hasSearched) ...[
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Text(
                                    'Matching Recipes',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF78A083),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: results.isEmpty
                                          ? const Color(0xFFFFE0D6)
                                          : const Color(0xFFDEF0E5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${results.length} found',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: results.isEmpty
                                            ? const Color(0xFFD94F2A)
                                            : const Color(0xFF3A7A50),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              if (results.isEmpty)
                                _buildEmptyState()
                              else
                                ...results.asMap().entries.map(
                                  (entry) => _buildResultCard(
                                    context: context,
                                    match: entry.value,
                                    rank: entry.key + 1,
                                    onViewRecipe: () {
                                      Navigator.of(dialogContext).pop();
                                      showRecipeDetail(context, entry.value.recipe);
                                    },
                                  ),
                                ),
                            ],
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),

                    // ── Footer ───────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Close'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(inputController.dispose);
  }

  /// Adds a non-duplicate, non-empty ingredient to the list and clears the field.
  static void _addIngredient(
    String value,
    List<String> selectedIngredients,
    TextEditingController controller,
    StateSetter setStateDialog,
  ) {
    final ingredient = value.trim();
    if (ingredient.isEmpty || selectedIngredients.contains(ingredient)) {
      controller.clear();
      return;
    }
    setStateDialog(() {
      selectedIngredients.add(ingredient);
      controller.clear();
    });
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
                Text(
                  match.recipe.icon,
                  style: const TextStyle(fontSize: 22),
                ),
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

  static void showAddRecipe(
    BuildContext context,
    Function(Recipe) onRecipeAdded,
  ) {
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
                constraints: const BoxConstraints(
                  maxWidth: 650,
                  maxHeight: 700,
                ),
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
                            decoration: fieldDecoration('Recipe Name'),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: emojiController,
                            decoration: fieldDecoration('Emoji (e.g., 🍝)'),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: timeController,
                            keyboardType: TextInputType.number,
                            decoration: fieldDecoration(
                              'Cooking Time in minutes',
                            ),
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
                                  decoration: fieldDecoration(
                                    'Ingredient name',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: ingredientQtyController,
                                  decoration: fieldDecoration('Quantity'),
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
                                  final qty = ingredientQtyController.text
                                      .trim();
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
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
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
                                  decoration: fieldDecoration('Enter step'),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
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
                                  timeMinutes: int.parse(
                                    timeController.text.trim(),
                                  ),
                                  ingredients: ingredients
                                      .map(
                                        (item) =>
                                            '${item.ingredient} - ${item.amount}',
                                      )
                                      .toList(),
                                  instructions: instructionSteps.toList(),
                                );

                                onRecipeAdded(newRecipe);
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
}
