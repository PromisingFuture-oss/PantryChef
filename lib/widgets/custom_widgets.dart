import 'package:flutter/material.dart';
import '../models/recipe.dart';

class LoadingPancake extends StatefulWidget {
  const LoadingPancake({super.key});

  @override
  State<LoadingPancake> createState() => _LoadingPancakeState();
}

class _LoadingPancakeState extends State<LoadingPancake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * 3.1415926535;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateY(angle)
            ..rotateZ(angle),
          child: const Text('🥞', style: TextStyle(fontSize: 78)),
        );
      },
    );
  }
}

class NavButton extends StatelessWidget {
  const NavButton({super.key, 
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFFFF8C69) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF78A083),
          shape: const StadiumBorder(),
          visualDensity: VisualDensity.compact,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({super.key, required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF78A083),
              ),
            ),
            const SizedBox(height: 10),
            Text(description, style: const TextStyle(color: Color(0xFF666666))),
          ],
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 26),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [Color(0xFFE8F0EA), Color(0xFFFDFAF5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                recipe.icon,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 54),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 21,
                        color: Color(0xFF78A083),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '⏱️ ${recipe.timeMinutes} minutes',
                      style: const TextStyle(
                        color: Color(0xFFFF8C69),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ingredients: ${recipe.ingredients.take(4).join(', ')}${recipe.ingredients.length > 4 ? '...' : ''}',
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
