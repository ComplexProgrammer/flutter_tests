import 'package:flutter/material.dart';
import 'package:flutter_tests/data/api.dart';
import 'package:flutter_tests/widgets/common.dart';

/// Loads an [ApiResult] on init and exposes loading / error / data state.
mixin ApiLoader<W extends StatefulWidget, T> on State<W> {
  ApiResult<T>? result;
  Object? error;
  bool loading = true;

  Future<ApiResult<T>> fetch();

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    setState(() {
      loading = result == null;
      error = null;
    });
    try {
      final r = await fetch();
      if (!mounted) return;
      setState(() => result = r);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /// Sliver for the main content: skeleton, error with retry, or [builder].
  Widget contentSliver({
    required Widget Function(T data) builder,
    required Widget skeleton,
  }) {
    if (loading && result == null) return skeleton;
    if (result == null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorView(error: error ?? 'unknown', onRetry: reload),
      );
    }
    return builder(result!.data);
  }

  Widget offlineSliver() => SliverToBoxAdapter(
        child: result?.fromCache == true
            ? const OfflineBanner()
            : const SizedBox.shrink(),
      );
}
