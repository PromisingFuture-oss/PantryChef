import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/recipe.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pantrychef.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE recipes (
  id $idType,
  name $textType,
  icon $textType,
  timeMinutes $integerType,
  ingredients $textType,
  instructions $textType,
  category $textType,
  tags $textType,
  imageUrl TEXT
)
''');
  }

  Future<void> insertRecipes(List<Recipe> recipes) async {
    final db = await instance.database;
    Batch batch = db.batch();
    for (final recipe in recipes) {
      batch.insert('recipes', {
        'id': recipe.id,
        'name': recipe.name,
        'icon': recipe.icon,
        'timeMinutes': recipe.timeMinutes,
        'ingredients': jsonEncode(recipe.ingredients),
        'instructions': jsonEncode(recipe.instructions),
        'category': recipe.category,
        'tags': jsonEncode(recipe.tags),
        'imageUrl': recipe.imageUrl,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Recipe>> getAllRecipes() async {
    final db = await instance.database;
    final result = await db.query('recipes');
    return result.map((json) => Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      timeMinutes: json['timeMinutes'] as int,
      ingredients: (jsonDecode(json['ingredients'] as String) as List).cast<String>(),
      instructions: (jsonDecode(json['instructions'] as String) as List).cast<String>(),
      category: json['category'] as String,
      tags: (jsonDecode(json['tags'] as String) as List).cast<String>(),
      imageUrl: json['imageUrl'] as String?,
    )).toList();
  }

  Future<void> clearAllRecipes() async {
    final db = await instance.database;
    await db.delete('recipes');
  }

  Future<int> getRecipeCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM recipes');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
