import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeDetailPage extends StatelessWidget {
  const RecipeDetailPage({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8), // Very light gray/green background
      appBar: AppBar(
        backgroundColor: const Color(0xFF93B799),
        elevation: 0,
        automaticallyImplyLeading: false, // We'll use our own back button or title
        title: const Text(
          'PantryChef',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Recipe Title
            Text(
              recipe.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 34,
                color: Color(0xFF93B799),
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            // Recipe Image Container
            Center(
              child: Container(
                width: 320,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EEE6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: recipe.imageUrl != null
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Image.network(
                            recipe.imageUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Text(recipe.icon, style: const TextStyle(fontSize: 80)),
                          ),
                        )
                      : Text(
                          recipe.icon,
                          style: const TextStyle(fontSize: 80),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Ingredients Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...recipe.ingredients.map((ingredient) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.check_box,
                                color: Color(0xFF76A21E),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ingredient,
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF333333),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                  // Instructions Section
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...recipe.instructions.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          '${entry.key + 1}.) ${entry.value}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF333333),
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )),
                  const SizedBox(height: 48),
                  // Back Button
                  Center(
                    child: SizedBox(
                      width: 260,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9E74),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
