import '../models/recipe.dart';

/// Offline reverse recipe search service.
///
/// Given a list of [Recipe] objects (the local database) and a list of
/// ingredient keywords provided by the user, this service scores every recipe
/// by how many of its ingredients match at least one keyword, then returns the
/// results sorted from best match to worst — filtering out recipes with zero
/// matches.
class RecipeSearchService {
  RecipeSearchService._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Search [database] for recipes that use any of [userIngredients].
  ///
  /// Returns a list of [RecipeMatch] objects sorted by [RecipeMatch.matchScore]
  /// in descending order. Recipes with a score of 0 are excluded.
  static List<RecipeMatch> search({
    required List<Recipe> database,
    required List<String> userIngredients,
  }) {
    if (userIngredients.isEmpty || database.isEmpty) return [];

    // Normalise user keywords once.
    final keywords = userIngredients
        .map((i) => _normalise(i))
        .where((k) => k.isNotEmpty)
        .toList();

    final results = <RecipeMatch>[];

    for (final recipe in database) {
      final matched = <String>[];
      final unmatched = <String>[];

      for (final ingredient in recipe.ingredients) {
        final normalised = _normalise(ingredient);
        final isMatch = keywords.any((kw) => normalised.contains(kw));
        if (isMatch) {
          matched.add(ingredient);
        } else {
          unmatched.add(ingredient);
        }
      }

      if (matched.isNotEmpty) {
        results.add(
          RecipeMatch(
            recipe: recipe,
            matchScore: matched.length,
            matchedIngredients: matched,
            unmatchedIngredients: unmatched,
          ),
        );
      }
    }

    // Sort by match score descending, then by match ratio as a tiebreaker.
    results.sort((a, b) {
      final scoreCompare = b.matchScore.compareTo(a.matchScore);
      if (scoreCompare != 0) return scoreCompare;
      return b.matchRatio.compareTo(a.matchRatio);
    });

    return results;
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Normalise an ingredient string for comparison:
  ///   - Lower-case
  ///   - Strip leading quantity + unit tokens (e.g. "400g", "2 tbsp", "1/2 cup")
  ///   - Remove punctuation
  static String _normalise(String raw) {
    var s = raw.toLowerCase().trim();

    // Remove leading quantity patterns like "400g", "2 tbsp", "1/2 cup", "3 cloves"
    s = s.replaceAll(RegExp(r'^\d+[\d/]*\s*(g|kg|ml|l|tbsp|tsp|cup|cups|cloves?|slice[s]?|can|cans?)?\s*'), '');

    // Remove parenthetical notes like "(optional)", "(thinly sliced)"
    s = s.replaceAll(RegExp(r'\(.*?\)'), '');

    // Remove punctuation except hyphens used in compound words
    s = s.replaceAll(RegExp(r'[^a-z0-9\s\-]'), '');

    s = s.trim();

    // Basic plural stripping (e.g., "eggs" -> "egg", "potatoes" -> "potato")
    if (s.endsWith('oes')) {
      s = s.substring(0, s.length - 2);
    } else if (s.endsWith('s') && !s.endsWith('ss')) {
      s = s.substring(0, s.length - 1);
    }

    return s;
  }
}
