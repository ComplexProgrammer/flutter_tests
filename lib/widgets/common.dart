import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/core/services.dart';
import 'package:flutter_tests/core/theme.dart';
import 'package:flutter_tests/data/api.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;

String mediaUrl(String path) =>
    path.startsWith('http') ? path : '$baseUrl/media/$path';

/// Cached network image with a neutral placeholder and fallback icon.
class NetImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final IconData fallbackIcon;

  const NetImage(this.path,
      {super.key,
      this.fit = BoxFit.cover,
      this.fallbackIcon = Icons.image_outlined});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: context.colors.primary.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(fallbackIcon, color: context.colors.primary, size: 32),
    );
    if (path.isEmpty) return fallback;
    return CachedNetworkImage(
      imageUrl: mediaUrl(path),
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, __) =>
          Container(color: context.colors.surfaceContainerHighest),
      errorWidget: (_, __, ___) => fallback,
    );
  }
}

/// Opens an image fullscreen with pinch-to-zoom.
void showZoomableImage(BuildContext context, String path) {
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (ctx) => Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            maxScale: 5,
            child: Center(child: NetImage(path, fit: BoxFit.contain)),
          ),
        ),
        Positioned(
          top: MediaQuery.of(ctx).padding.top + 8,
          right: 8,
          child: IconButton.filledTonal(
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(Icons.close),
            tooltip: ctx.tr('close'),
          ),
        ),
      ],
    ),
  );
}

class ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final key = error is ApiException
        ? (error as ApiException).messageKey
        : 'err_unknown';
    final offline = error is ApiException &&
        {ApiError.network, ApiError.timeout}
            .contains((error as ApiException).error);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kErrorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                offline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
                size: 40,
                color: kErrorColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(context.tr(key),
                textAlign: TextAlign.center,
                style: context.text.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(context.tr('err_hint'),
                textAlign: TextAlign.center,
                style: TextStyle(color: context.mutedText)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.tr('retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  final IconData icon;
  final String text;
  const EmptyView({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: context.mutedText.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text(text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.mutedText, fontSize: 15)),
            ],
          ),
        ),
      );
}

/// Pulsing placeholder block used for skeleton loading.
class Skeleton extends StatefulWidget {
  final double? height;
  final double? width;
  final double radius;
  const Skeleton({super.key, this.height, this.width, this.radius = 16});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.colors.surfaceContainerHighest;
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(_c),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: kWarningColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 18, color: kWarningColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(context.tr('offline_mode'),
                  style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      );
}

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  const SearchField(
      {super.key,
      required this.controller,
      required this.onChanged,
      required this.hint});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, v, __) => v.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: context.tr('clear'),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
          ),
        ),
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(text,
                  style: context.text.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

/// Banner ad that takes no space until an ad has actually loaded.
class BannerAdBox extends StatefulWidget {
  const BannerAdBox({super.key});

  @override
  State<BannerAdBox> createState() => _BannerAdBoxState();
}

class _BannerAdBoxState extends State<BannerAdBox> {
  static const _unitId = 'ca-app-pub-7773722896374259/1178104271';
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!isMobile) return;
    _ad = BannerAd(
      size: AdSize.banner,
      adUnitId: _unitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, e) {
          debugPrint('Banner failed: $e');
          ad.dispose();
          _ad = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        height: ad.size.height.toDouble(),
        child: Center(
          child: SizedBox(
            width: ad.size.width.toDouble(),
            child: AdWidget(ad: ad),
          ),
        ),
      ),
    );
  }
}

/// Grade label key + emoji for a percentage.
(String, String) gradeFor(int percent) => switch (percent) {
      >= 90 => ('grade_excellent', '🏆'),
      >= 70 => ('grade_good', '🎉'),
      >= 50 => ('grade_ok', '👍'),
      _ => ('grade_low', '💪'),
    };

String formatDuration(int seconds) {
  final m = seconds ~/ 60, s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
