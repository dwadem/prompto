import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/routes.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_progress.dart';
import '../providers/app_providers.dart';

/// Progress overview + account. Combines the live progress and user streams.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: progress.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (p) => _Content(
          progress: p,
          user: user.valueOrNull,
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.progress, required this.user});

  final UserProgress progress;
  final UserProfile? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPro = user?.isPro ?? false;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Identity card.
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                (user?.displayName ?? 'L').characters.first.toUpperCase(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.displayName ?? 'Learner',
                    style: theme.textTheme.titleLarge),
                Text(
                  isPro ? 'Pro member' : 'Free plan',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (user != null)
                  Text(
                    'Joined ${DateFormat.yMMMd().format(user!.joinedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Stats grid.
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _StatCard(
              icon: Icons.local_fire_department,
              value: '${progress.streakDays}',
              label: 'Day streak',
              color: Colors.orange,
            ),
            _StatCard(
              icon: Icons.bolt,
              value: '${progress.totalXp}',
              label: 'Total XP',
              color: theme.colorScheme.primary,
            ),
            _StatCard(
              icon: Icons.workspace_premium_outlined,
              value: 'Level ${progress.level}',
              label: 'Current level',
              color: theme.colorScheme.tertiary,
            ),
            _StatCard(
              icon: Icons.check_circle_outline,
              value: '${progress.completedLessonIds.length}',
              label: 'Lessons done',
              color: theme.colorScheme.secondary,
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (!isPro)
          Card(
            color: theme.colorScheme.tertiaryContainer,
            child: ListTile(
              leading: Icon(Icons.workspace_premium,
                  color: theme.colorScheme.onTertiaryContainer),
              title: const Text('Upgrade to Pro'),
              subtitle: const Text('Unlimited Prompt Lab, advanced paths, certificates'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.paywall),
            ),
          ),
        ListTile(
          leading: const Icon(Icons.local_fire_department_outlined),
          title: const Text('Streak freezes'),
          trailing: Text('${progress.freezesAvailable}'),
        ),
        ListTile(
          leading: const Icon(Icons.flag_outlined),
          title: const Text('Daily goal'),
          trailing: Text('${progress.dailyGoalMinutes} min'),
          onTap: () => context.push(Routes.settings),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const Spacer(),
            Text(value, style: theme.textTheme.titleLarge),
            Text(
              label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
