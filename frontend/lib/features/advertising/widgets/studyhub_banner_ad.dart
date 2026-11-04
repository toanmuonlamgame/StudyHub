import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../advertising_provider.dart';
import '../advertising_scope.dart';
import '../advertising_service.dart';

class StudyHubBannerAd extends StatefulWidget {
  const StudyHubBannerAd({super.key, required this.placement, this.fallback});

  final BannerPlacement placement;
  final Widget? fallback;

  @override
  State<StudyHubBannerAd> createState() => _StudyHubBannerAdState();
}

class _StudyHubBannerAdState extends State<StudyHubBannerAd> {
  BannerAdHandle? _handle;
  AdvertisingService? _service;
  bool _loading = false;
  bool _attempted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final service = AdvertisingScope.maybeOf(context);
    _service = service;
    if (!_attempted && service?.shouldShowAds == true) {
      _attempted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  Future<void> _load() async {
    if (!mounted || _loading) return;
    setState(() => _loading = true);
    final service = AdvertisingScope.of(context);
    final width = MediaQuery.sizeOf(context).width.clamp(320, 560).toDouble();
    final handle = await service.loadBanner(
      widget.placement,
      availableWidth: width,
    );
    if (!mounted) {
      if (handle != null) {
        unawaited(service.releaseBanner(widget.placement, handle));
      }
      return;
    }
    setState(() {
      _handle = handle;
      _loading = false;
    });
  }

  @override
  void dispose() {
    final handle = _handle;
    if (handle != null) {
      final service = _service;
      if (service != null) {
        unawaited(service.releaseBanner(widget.placement, handle));
      } else {
        unawaited(handle.dispose());
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = AdvertisingScope.maybeOf(context);
    if (service?.shouldShowAds != true || _handle == null) {
      return widget.fallback ?? const SizedBox.shrink();
    }
    final handle = _handle!;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (handle.size.width > constraints.maxWidth) {
          return widget.fallback ?? const SizedBox.shrink();
        }
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.advertisement,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: handle.size.width,
                  height: handle.size.height,
                  child: handle.buildView(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
