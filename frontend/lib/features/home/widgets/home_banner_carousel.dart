import 'package:flutter/material.dart';

import '../../../core/app_motion.dart';
import '../../../l10n/app_localizations_x.dart';
import '../models/home_banner_item.dart';

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key, required this.items});

  final List<HomeBannerItem> items;

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.94);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final extraHeight = ((textScale - 1).clamp(0, 1) * 260).toDouble();

    return Column(
      key: const ValueKey('home-banner-carousel'),
      children: [
        SizedBox(
          height: 300 + extraHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            padEnds: false,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _HomeBannerCard(
                item: widget.items[index],
                position: index + 1,
                total: widget.items.length,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Semantics(
          key: const ValueKey('home-banner-indicator'),
          label: context.l10n.bannerPageSemantics(
            _currentPage + 1,
            widget.items.length,
          ),
          child: ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < widget.items.length; index++)
                  AnimatedContainer(
                    duration: AppMotion.duration(
                      context,
                      const Duration(milliseconds: 180),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: index == _currentPage ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: index == _currentPage
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeBannerCard extends StatelessWidget {
  const _HomeBannerCard({
    required this.item,
    required this.position,
    required this.total,
  });

  final HomeBannerItem item;
  final int position;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final (background, foreground, iconBackground) = switch (item.tone) {
      HomeBannerTone.primary => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
        colors.primary,
      ),
      HomeBannerTone.success => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
        colors.secondary,
      ),
      HomeBannerTone.neutral => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
        colors.tertiary,
      ),
    };

    return Semantics(
      label: context.l10n.bannerPageSemantics(position, total),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: background, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              item.title,
              style: theme.textTheme.titleLarge?.copyWith(color: foreground),
            ),
            const SizedBox(height: 6),
            Text(
              item.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: item.onPressed,
              style: TextButton.styleFrom(
                foregroundColor: foreground,
                minimumSize: const Size(0, 44),
              ),
              icon: const Icon(Icons.arrow_forward),
              label: Text(item.actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
