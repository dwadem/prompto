import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/state_views.dart';
import '../../domain/entities/skill_module.dart';
import '../../domain/entities/user_progress.dart';
import '../providers/app_providers.dart';
import 'module_visuals.dart';
import 'widgets/lesson_tile.dart';
import 'widgets/stats_header.dart';

/// The skill tree — the app's home. Streams progress + user so streak/XP and
/// lock state update reactively after a lesson completes.
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(modulesProvider);
    final progress = ref.watch(progressProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompto'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: modules,
        onRetry: () => ref.invalidate(modulesProvider),
        data: (moduleList) {
          if (moduleList.isEmpty) {
            return const EmptyStateView(
              icon: Icons.school_outlined,
              title: 'No modules yet',
              message: 'Content will appear here once the curriculum loads.',
            );
          }
          // Header reflects live progress; show a slim placeholder while loading.
          final header = progress.maybeWhen(
            data: (p) => StatsHeader(progress: p),
            orElse: () => const LinearProgressIndicator(),
          );

          final p = progress.valueOrNull;
          final isPro = user.valueOrNull?.isPro ?? false;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(modulesProvider),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                header,
                ..._buildPath(context, ref, moduleList, p, isPro),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Flattens modules→lessons in order and assigns lock status: everything up to
  /// and including the first not-completed lesson is reachable; the rest locks.
  List<Widget> _buildPath(
    BuildContext context,
    WidgetRef ref,
    List<SkillModule> modules,
    UserProgress? progress,
    bool isPro,
  ) {
    final widgets = <Widget>[];
    var foundCurrent = false;

    for (final module in modules) {
      widgets.add(_ModuleHeader(module: module, locked: module.isPro && !isPro));
      for (final lesson in module.lessons) {
        final done = progress?.hasCompleted(lesson.id) ?? false;
        final LessonStatus status;
        if (done) {
          status = LessonStatus.done;
        } else if (!foundCurrent) {
          status = LessonStatus.current;
          foundCurrent = true;
        } else {
          status = LessonStatus.locked;
        }
        final proLocked = lesson.isPro && !isPro;

        widgets.add(
          LessonTile(
            lesson: lesson,
            status: status,
            proLocked: proLocked,
            onTap: () => _onLessonTap(context, lesson.id, proLocked, status),
          ),
        );
      }
    }
    return widgets;
  }

  void _onLessonTap(
    BuildContext context,
    String lessonId,
    bool proLocked,
    LessonStatus status,
  ) {
    if (proLocked) {
      context.push(Routes.paywall);
      return;
    }
    if (status == LessonStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finish the previous lesson first.')),
      );
      return;
    }
    context.push(Routes.lessonPath(lessonId));
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({required this.module, required this.locked});

  final SkillModule module;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        children: [
          Icon(iconForModule(module.icon), color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.title, style: theme.textTheme.titleMedium),
                Text(
                  module.description,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (locked)
            Icon(Icons.lock_outline,
                size: 18, color: theme.colorScheme.outline),
        ],
      ),
    );
  }
}
