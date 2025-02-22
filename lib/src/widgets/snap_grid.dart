import 'package:appstream/appstream.dart';
import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';

import '/layout.dart';
import 'app_card.dart';

class AppCardGrid extends StatelessWidget {
  const AppCardGrid({
    super.key,
    required this.appCards,
  });

  factory AppCardGrid.fromSnaps({
    required List<Snap> snaps,
    required ValueChanged<Snap> onTap,
  }) =>
      AppCardGrid(
        appCards: snaps.map(
          (snap) => AppCard.fromSnap(
            snap: snap,
            onTap: () => onTap(snap),
          ),
        ),
      );

  factory AppCardGrid.fromDebs({
    required List<AppstreamComponent> debs,
    required ValueChanged<AppstreamComponent> onTap,
  }) =>
      AppCardGrid(
        appCards: debs.map(
          (deb) => AppCard.fromDeb(
            component: deb,
            onTap: () => onTap(deb),
          ),
        ),
      );

  final Iterable<AppCard> appCards;

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveLayout.of(context);
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: layout.cardColumnCount,
        childAspectRatio: layout.cardSize.aspectRatio,
        mainAxisSpacing: kCardSpacing - 2 * kCardMargin,
        crossAxisSpacing: kCardSpacing - 2 * kCardMargin,
      ),
      itemCount: appCards.length,
      itemBuilder: (context, index) => appCards.elementAt(index),
    );
  }
}

// TODO: generalize
class SnapImageCardGrid extends StatelessWidget {
  const SnapImageCardGrid({
    super.key,
    required this.snaps,
    required this.onTap,
  });

  final List<Snap> snaps;
  final ValueChanged<Snap> onTap;

  @override
  Widget build(BuildContext context) {
    final layoutType = ResponsiveLayout.of(context).type;
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: switch (layoutType) {
          ResponsiveLayoutType.small => 1,
          ResponsiveLayoutType.medium => 2,
          ResponsiveLayoutType.large => 4,
        },
        childAspectRatio: switch (layoutType) {
          ResponsiveLayoutType.small => 1.7,
          ResponsiveLayoutType.medium => 1.3,
          ResponsiveLayoutType.large => 1,
        },
        mainAxisSpacing: kCardSpacing - 2 * kCardMargin,
        crossAxisSpacing: kCardSpacing - 2 * kCardMargin,
      ),
      itemCount: snaps.length,
      itemBuilder: (context, index) {
        final snap = snaps[index];
        return SnapImageCard(
          key: ValueKey(snap.id),
          snap: snap,
          onTap: () => onTap(snap),
        );
      },
    );
  }
}
