import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../advertising_provider.dart';
import '../advertising_scope.dart';
import '../advertising_service.dart';

class StudyHubBannerAd extends StatefulWidget {
  const StudyHubBannerAd({super.key, required this.placement});

  final BannerPlacement placement;

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
    if (service == null ||
        !service.shouldShowAds ||
        (!_loading && _handle == null)) {
      return const SizedBox.shrink();
    }
    final handle = _handle;
    return SafeArea(
      top: false,
      child: Semantics(
        label: context.l10n.advertisement,
        container: true,
        child: SizedBox(
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.advertisement,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              if (handle == null)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                SizedBox(
                  width: handle.size.width,
                  height: handle.size.height,
                  child: handle.buildView(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
