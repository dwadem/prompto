import 'package:flutter/material.dart';

import '../../domain/entities/skill_module.dart';

/// Maps the platform-neutral [ModuleIcon] enum to a Material icon. Lives in the
/// presentation layer so the domain stays free of Flutter types.
IconData iconForModule(ModuleIcon icon) {
  switch (icon) {
    case ModuleIcon.basics:
      return Icons.lightbulb_outline;
    case ModuleIcon.context:
      return Icons.article_outlined;
    case ModuleIcon.fewShot:
      return Icons.format_list_numbered;
    case ModuleIcon.structure:
      return Icons.data_object;
    case ModuleIcon.reasoning:
      return Icons.account_tree_outlined;
    case ModuleIcon.verification:
      return Icons.verified_outlined;
  }
}

/// Traffic-light colour for a 0–100 score, used across the Prompt Lab UI.
Color scoreColor(BuildContext context, int score) {
  final scheme = Theme.of(context).colorScheme;
  if (score >= 70) return scheme.primary;
  if (score >= 50) return scheme.tertiary;
  return scheme.error;
}
