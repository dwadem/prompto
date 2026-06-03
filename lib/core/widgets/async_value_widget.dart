import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state_views.dart';

/// Renders an [AsyncValue] with consistent loading / error handling so screens
/// don't repeat the same boilerplate. [onRetry] re-runs the source provider.
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorStateView(
        message: error.toString(),
        onRetry: onRetry,
      ),
    );
  }
}
