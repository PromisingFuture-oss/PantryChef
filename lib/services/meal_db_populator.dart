import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'database_helper.dart';
import '../models/recipe.dart';

/// Populates a local recipe cache from TheMealDB API.
///
/// On first run this service fetches recipes from TheMealDB (using the free
/// test API key "1") and caches them as a local JSON file. On subsequent runs
/// the cached file is loaded — the app works completely offline.
///
/// If no cache exists and the network is unavailable the caller should fall
/// back to the hardcoded recipe list.
class MealDbPopulator {
  MealDbPopulator._();

  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Mapping from TheMealDB category → emoji icon.
  static const Map<String, String> _categoryIcons = {
    'Chicken': '🍗',
    'Beef': '🥩',
    'Pork': '🥓',
    'Lamb': '🍖',
    'Seafood': '🦐',
    'Vegetarian': '🥗',
    'Vegan': '🥬',
    'Pasta': '🍝',
    'Dessert': '🍰',
    'Breakfast': '🍳',
    'Side': '🥦',
    'Miscellaneous': '🍽️',
    'Starter': '🥣',
    'Goat': '🐐',
  };

  // --------------------------------------------------------------------------
  // Public API
  // --------------------------------------------------------------------------

  /// Returns cached recipes, or fetches them from TheMealDB if the cache
  /// doesn't exist yet. Returns `null` if both approaches fail.
  static Future<List<Recipe>?> getRecipes() async {
    try {
      final cached = await DatabaseHelper.instance.getAllRecipes();
      if (cached.isNotEmpty) {
        debugPrint('[MealDbPopulator] Loaded ${cached.length} recipes from SQLite.');
        return cached;
      }
    } catch (e) {
      debugPrint('[MealDbPopulator] SQLite load error: $e');
    }

    debugPrint('[MealDbPopulator] No cache found. Fetching from TheMealDB…');
    try {
      final recipes = await _fetchAll();
      if (recipes.isNotEmpty) {
        await DatabaseHelper.instance.insertRecipes(recipes);
        debugPrint('[MealDbPopulator] Saved ${recipes.length} recipes to SQLite.');
        return recipes;
      }
    } catch (e) {
      debugPrint('[MealDbPopulator] Fetch failed: $e');
    }
    return null;
  }

  /// Force a fresh fetch from TheMealDB, overwriting the cache.
  static Future<List<Recipe>?> refreshCache() async {
    try {
      final recipes = await _fetchAll();
      if (recipes.isNotEmpty) {
        await DatabaseHelper.instance.clearAllRecipes();
        await DatabaseHelper.instance.insertRecipes(recipes);
        debugPrint('[MealDbPopulator] Saved ${recipes.length} recipes to SQLite after refresh.');
        return recipes;
      }
    } catch (e) {
      debugPrint('[MealDbPopulator] Refresh failed: $e');
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // Cache I/O
  // --------------------------------------------------------------------------

  // Removed JSON Cache I/O methods

  // --------------------------------------------------------------------------
  // TheMealDB API calls
  // --------------------------------------------------------------------------

  /// Fetch recipes from multiple endpoints in parallel for speed.
  static Future<List<Recipe>> _fetchAll() async {
    final seenIds = <String>{};
    final recipes = <Recipe>[];

    // Strategy 1: search by first letter (a–z) — returns FULL details in one
    // call per letter. We do a subset to keep things fast.
    final letterFutures = <Future<void>>[];
    for (int i = 0; i < 5; i++) {
      final letter = String.fromCharCode('a'.codeUnitAt(0) + i);
      letterFutures.add(_fetchByFirstLetter(letter, seenIds, recipes));
    }
    // Also add some from the later alphabet.
    letterFutures.add(_fetchByFirstLetter('p', seenIds, recipes));
    letterFutures.add(_fetchByFirstLetter('s', seenIds, recipes));
    await Future.wait(letterFutures);

    // Strategy 2: if we still have few recipes, fetch random ones.
    if (recipes.length < 40) {
      final randomFutures = <Future<void>>[];
      for (int i = 0; i < 8; i++) {
        randomFutures.add(_fetchRandomAndCollect(seenIds, recipes));
      }
      await Future.wait(randomFutures);
    }

    debugPrint('[MealDbPopulator] Total recipes fetched: ${recipes.length}');
    return recipes;
  }

  /// Fetch all meals starting with [letter] and add them to [recipes].
  static Future<void> _fetchByFirstLetter(
    String letter,
    Set<String> seenIds,
    List<Recipe> recipes,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/search.php?f=$letter');
      final response = await http.get(url);
      if (response.statusCode != 200) return;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final meals = body['meals'] as List<dynamic>?;
      if (meals == null || meals.isEmpty) return;

      for (final meal in meals) {
        final recipe = _convertMeal(meal as Map<String, dynamic>);
        if (seenIds.add(recipe.id)) {
          recipes.add(recipe);
        }
      }
    } catch (e) {
      debugPrint('[MealDbPopulator] search.php?f=$letter failed: $e');
    }
  }

  /// Fetch a random recipe and add it to [recipes].
  static Future<void> _fetchRandomAndCollect(
    Set<String> seenIds,
    List<Recipe> recipes,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/random.php');
      final response = await http.get(url);
      if (response.statusCode != 200) return;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final meals = body['meals'] as List<dynamic>?;
      if (meals == null || meals.isEmpty) return;

      final recipe = _convertMeal(meals[0] as Map<String, dynamic>);
      if (seenIds.add(recipe.id)) {
        recipes.add(recipe);
      }
    } catch (_) {}
  }

  // --------------------------------------------------------------------------
  // Data conversion
  // --------------------------------------------------------------------------

  /// Convert a TheMealDB meal JSON object to our [Recipe] model.
  static Recipe _convertMeal(Map<String, dynamic> meal) {
    final id = (meal['idMeal'] as String? ?? '');
    final name = (meal['strMeal'] as String? ?? 'Unknown');
    final category = (meal['strCategory'] as String? ?? '');
    final area = (meal['strArea'] as String? ?? '');
    final imageUrl = (meal['strMealThumb'] as String? ?? '');
    final instructionsRaw = (meal['strInstructions'] as String? ?? '');
    final tagsRaw = (meal['strTags'] as String? ?? '');

    final tags = tagsRaw
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    // Build ingredients list by pairing strIngredientN + strMeasureN.
    final ingredients = <String>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = (meal['strIngredient$i'] as String? ?? '').trim();
      final measure = (meal['strMeasure$i'] as String? ?? '').trim();
      if (ingredient.isEmpty) continue;
      if (measure.isNotEmpty) {
        ingredients.add('$measure $ingredient');
      } else {
        ingredients.add(ingredient);
      }
    }

    // Split instructions by newlines.
    final instructions = instructionsRaw
        .replaceAll('\r\n', '\n')
        .split(RegExp(r'\n+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (instructions.isEmpty) {
      instructions.add(instructionsRaw);
    }

    // Estimate cooking time based on ingredient count (rough heuristic).
    final timeMinutes = _estimateTime(category, ingredients.length);

    // Pick an icon based on category or area.
    final icon = _categoryIcons[category] ?? _areaToIcon(area);

    return Recipe(
      id: 'mealdb_$id',
      name: name,
      icon: icon,
      timeMinutes: timeMinutes,
      ingredients: ingredients,
      instructions: instructions,
      category: category,
      tags: tags,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
    );
  }

  /// Rough cooking-time estimate.
  static int _estimateTime(String category, int ingredientCount) {
    if (category == 'Dessert' || category == 'Breakfast') return 25 + ingredientCount * 2;
    if (category == 'Beef' || category == 'Lamb' || category == 'Pork') return 30 + ingredientCount * 3;
    return 20 + ingredientCount * 2;
  }

  /// Map TheMealDB area to an emoji.
  static String _areaToIcon(String area) {
    const areas = <String, String>{
      'Italian': '🇮🇹',
      'Mexican': '🌮',
      'Indian': '🍛',
      'Chinese': '🥟',
      'Japanese': '🍣',
      'Thai': '🍜',
      'French': '🥖',
      'American': '🍔',
      'British': '🇬🇧',
      'Canadian': '🍁',
      'Greek': '🥗',
      'Spanish': '🇪🇸',
      'Jamaican': '🇯🇲',
      'Moroccan': '🥘',
      'Turkish': '🥙',
      'Egyptian': '🇪🇬',
      'Irish': '☘️',
      'Russian': '🇷🇺',
      'Polish': '🥟',
      'Portuguese': '🇵🇹',
      'Vietnamese': '🍜',
      'Malaysian': '🇲🇾',
      'Filipino': '🇵🇭',
      'Cuban': '🇨🇺',
      'Kenyan': '🇰🇪',
      'Dutch': '🇳🇱',
      'Croatian': '🇭🇷',
    };
    return areas[area] ?? '🍽️';
  }
}