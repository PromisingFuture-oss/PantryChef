import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/custom_widgets.dart';

class LandingSection extends StatelessWidget {
  const LandingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF78A083), Color(0xFF9BC4A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pantry Chef',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 62,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Transform your ingredients into culinary masterpieces. Cook smart, reduce waste, and discover endless recipe possibilities.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE0E0E0), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.black87, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF555555), Color(0xFF333333)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Turn to Start',
                    style: TextStyle(
                      color: Color(0xFFFDFAF5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.onFindRecipesTap,
    required this.onScrollTap,
    required this.scrollControllerKey,
  });

  final VoidCallback onFindRecipesTap;
  final VoidCallback onScrollTap;
  final GlobalKey scrollControllerKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: scrollControllerKey,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const Text(
                'Cook with What You Have',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  color: Color(0xFF78A083),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Turn your leftover ingredients into delicious meals with personalized recipe suggestions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 14),
              const Text('🍳', style: TextStyle(fontSize: 62)),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C69),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                ),
                onPressed: onFindRecipesTap,
                child: const Text(
                  'Find Recipes',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Why Pantry Chef?',
                style: TextStyle(
                  fontSize: 34,
                  color: Color(0xFF78A083),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900
                      ? 4
                      : constraints.maxWidth > 600
                      ? 2
                      : 1;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.1,
                    children: const [
                      FeatureCard(
                        title: '🍲 Smart Recipe Suggestions',
                        description:
                            'Enter your ingredients and get recipes tailored to what you already have.',
                      ),
                      FeatureCard(
                        title: '🥗 Reduce Food Waste',
                        description:
                            'Use every ingredient in your pantry and save money while helping the environment.',
                      ),
                      FeatureCard(
                        title: '⏱️ Save Time',
                        description:
                            'No more searching for hours, find the perfect recipe in seconds.',
                      ),
                      FeatureCard(
                        title: '📱 Easy to Use',
                        description:
                            'Simple and intuitive design for a seamless cooking experience.',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipesSection extends StatelessWidget {
  const RecipesSection({
    super.key,
    required this.recipes,
    required this.sectionKey,
    required this.onRecipeTap,
  });

  final List<Recipe> recipes;
  final GlobalKey sectionKey;
  final Function(Recipe) onRecipeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      width: double.infinity,
      color: const Color(0xFFF9FDF9),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Featured Recipes',
                style: TextStyle(
                  fontSize: 34,
                  color: Color(0xFF78A083),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1000
                      ? 3
                      : constraints.maxWidth > 650
                      ? 2
                      : 1;

                  return GridView.builder(
                    itemCount: recipes.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.92,
                    ),
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return RecipeCard(
                        recipe: recipe,
                        onTap: () => onRecipeTap(recipe),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  const AboutSection({super.key, required this.sectionKey});

  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 52),
      color: Colors.white,
      child: const Center(
        child: Column(
          children: [
            Text(
              'Meet the Team',
              style: TextStyle(
                fontSize: 34,
                color: Color(0xFF78A083),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Developed by - 3BSIT-1 The Invokables',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, color: Color(0xFF555555)),
            ),
            SizedBox(height: 8),
            Text(
              'Jaymar B. Riveral, Adam Riggs P. Mendoza, and Aryana Kristina S. Manguerra',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Color(0xFF555555)),
            ),
          ],
        ),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF78A083),
      padding: const EdgeInsets.all(22),
      child: const Center(
        child: Text(
          '© 2026 Pantry Chef Project - Capstone Project 1',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
