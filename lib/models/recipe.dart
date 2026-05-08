class Recipe {
  Recipe({
    required this.id,
    required this.name,
    required this.icon,
    required this.timeMinutes,
    required this.ingredients,
    required this.instructions,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String icon;
  final int timeMinutes;
  final List<String> ingredients;
  final List<String> instructions;
  final String? imageUrl;
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

/// Result of a reverse recipe search. Wraps a [Recipe] with match metadata.
class RecipeMatch {
  RecipeMatch({
    required this.recipe,
    required this.matchScore,
    required this.matchedIngredients,
    required this.unmatchedIngredients,
  });

  /// The full recipe from the database.
  final Recipe recipe;

  /// Number of recipe ingredients that matched the user's input.
  final int matchScore;

  /// Recipe ingredient strings that were matched.
  final List<String> matchedIngredients;

  /// Recipe ingredient strings that were NOT matched.
  final List<String> unmatchedIngredients;

  /// Percentage of ingredients matched (0.0 – 1.0).
  double get matchRatio =>
      recipe.ingredients.isEmpty ? 0 : matchScore / recipe.ingredients.length;
}
