import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/state_views.dart';
import '../../domain/entities/prompt_template.dart';
import '../providers/app_providers.dart';

/// The curated "exemplary prompts" library (§4.4): reusable prompts with an
/// explanation of *why* they work. Pro items route to the paywall.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesProvider);
    final isPro = ref.watch(userProvider).valueOrNull?.isPro ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Prompt Library')),
      body: AsyncValueWidget(
        value: templates,
        onRetry: () => ref.invalidate(templatesProvider),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyStateView(
              icon: Icons.menu_book_outlined,
              title: 'No prompts yet',
              message: 'Saved and curated prompts will show up here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) => _TemplateCard(
              template: list[i],
              locked: list[i].isPro && !isPro,
            ),
          );
        },
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template, required this.locked});

  final PromptTemplate template;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        shape: const Border(),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Icon(
            locked ? Icons.lock_outline : Icons.bookmark_border,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(template.title),
        subtitle: Text(template.category),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: locked
            ? [
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonal(
                    onPressed: () => context.push(Routes.paywall),
                    child: const Text('Unlock with Pro'),
                  ),
                ),
              ]
            : [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    template.prompt,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        template.whyItWorks,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
      ),
    );
  }
}
