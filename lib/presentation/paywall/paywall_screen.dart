import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';
import '../providers/repository_providers.dart';

/// Transparent, anti-dark-pattern pricing (concept §5). The "upgrade" is a
/// prototype stub — no real billing. TODO: integrate in_app_purchase / RevenueCat.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _upgrading = false;

  Future<void> _upgrade() async {
    setState(() => _upgrading = true);
    await ref.read(userRepositoryProvider).upgradeToPro();
    if (!mounted) return;
    setState(() => _upgrading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome to Pro! (prototype)')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPro = ref.watch(userProvider).valueOrNull?.isPro ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Prompto Pro')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.workspace_premium,
              size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text('Learn faster with Pro',
              style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'The basics are free forever. Pro adds unlimited practice and pro paths.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          const _Benefit('Unlimited live Prompt Lab evaluations'),
          const _Benefit('Advanced modules: reasoning, verification'),
          const _Benefit('Spaced-repetition review of your weak spots'),
          const _Benefit('Completion certificates for your CV / LinkedIn'),
          const SizedBox(height: 24),
          // Plans (display only, except Pro which the prototype "buys").
          _PlanCard(
            title: 'Pro — Monthly',
            price: '24,99 zł / mo',
            highlighted: true,
            child: FilledButton(
              onPressed: isPro || _upgrading ? null : _upgrade,
              child: _upgrading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isPro ? 'You are Pro ✓' : 'Start Pro'),
            ),
          ),
          const _PlanCard(
            title: 'Pro — Yearly',
            price: '149 zł / yr',
            subtitle: 'Best value — 2 months free',
          ),
          const _PlanCard(
            title: 'Lifetime',
            price: '399 zł once',
            subtitle: 'No subscription, ever',
          ),
          const SizedBox(height: 16),
          Text(
            'No hidden fees. Cancel anytime. The full theory tree stays free.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    this.subtitle,
    this.highlighted = false,
    this.child,
  });

  final String title;
  final String price;
  final String? subtitle;
  final bool highlighted;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: highlighted
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Text(price, style: theme.textTheme.titleMedium),
              ],
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            if (child != null) ...[
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: child),
            ],
          ],
        ),
      ),
    );
  }
}
