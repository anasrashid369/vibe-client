import 'package:flutter/material.dart';

/// Shows whether results came from the AI layer or the non-AI fallback
/// — spec §3.2: "never hides the fallback."
class AiSourceBadge extends StatelessWidget {
  const AiSourceBadge({super.key, required this.isAi});

  final bool isAi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAi ? Colors.deepPurple.shade50 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAi ? 'AI-curated' : 'Popular picks',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isAi ? Colors.deepPurple : Colors.grey.shade700,
        ),
      ),
    );
  }
}