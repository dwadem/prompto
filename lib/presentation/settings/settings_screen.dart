import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../providers/repository_providers.dart';

/// App preferences: theme, daily goal, gentle reminders. Reminder scheduling
/// goes through the platform-neutral ReminderService abstraction.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _reminders = false;

  Future<void> _toggleReminders(bool value) async {
    final service = ref.read(reminderServiceProvider);
    if (value) {
      final granted = await service.requestPermission();
      if (!granted) return;
      await service.scheduleDailyReminder(hour: 19, minute: 0);
    } else {
      await service.cancelAll();
    }
    if (mounted) setState(() => _reminders = value);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final progress = ref.watch(progressProvider).valueOrNull;
    final goal = progress?.dailyGoalMinutes ?? 10;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          // SegmentedButton is the Material 3 single-select control and avoids
          // the Radio group-value APIs deprecated after Flutter 3.32.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) {
                ref.read(themeModeProvider.notifier).set(selection.first);
              },
            ),
          ),
          const Divider(),
          const _SectionHeader('Daily goal'),
          ListTile(
            title: const Text('Minutes per day'),
            subtitle: Slider(
              value: goal.toDouble(),
              min: 5,
              max: 30,
              divisions: 5,
              label: '$goal min',
              onChanged: (v) {
                ref
                    .read(progressRepositoryProvider)
                    .setDailyGoalMinutes(v.round());
              },
            ),
            trailing: Text('$goal min'),
          ),
          const Divider(),
          const _SectionHeader('Reminders'),
          SwitchListTile(
            value: _reminders,
            onChanged: _toggleReminders,
            title: const Text('Gentle daily reminder'),
            subtitle: const Text('A single nudge at 7pm — never spammy.'),
          ),
          const Divider(),
          const _SectionHeader('About'),
          const ListTile(
            title: Text('Prompto'),
            subtitle: Text('Prototype • v0.1.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
