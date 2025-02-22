import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

class SnapSearchParameters {
  const SnapSearchParameters({this.query, this.category});
  final String? query;
  final SnapCategoryEnum? category;

  // Removes characters from the search query that would cause snapd to reply
  // with 'bad query'.
  // See https://github.com/snapcore/snapd/blob/29c9752d66bf95ffa85d85309531e2f5c7971553/store/store.go#L1048-L1056
  String? get cleanedQuery => query?.replaceAll(
        RegExp(r'[+=&|><!(){}\[\]^"~*?:\\/]'),
        ' ',
      );

  @override
  bool operator ==(Object other) =>
      other is SnapSearchParameters &&
      other.query == query &&
      other.category == category;

  @override
  int get hashCode => Object.hash(query, category);
}

final snapCategoryProvider = StateProvider.family
    .autoDispose<SnapCategoryEnum?, SnapCategoryEnum?>(
        (ref, initialValue) => initialValue);

final snapSearchProvider =
    StreamProvider.family((ref, SnapSearchParameters searchParameters) async* {
  final snapd = getService<SnapdService>();
  if (searchParameters.category == SnapCategoryEnum.ubuntuDesktop) {
    yield* snapd.getStoreSnaps(searchParameters.category!.featuredSnapNames
            ?.where((name) => name.contains(searchParameters.query ?? ''))
            .toList() ??
        []);
  } else if (searchParameters.query == null &&
      searchParameters.category != null) {
    yield* snapd.getCategory(searchParameters.category!.categoryName);
  } else {
    yield await snapd.find(
      query: searchParameters.cleanedQuery,
      category: searchParameters.category?.categoryName,
    );
  }
});

final snapSortOrderProvider =
    StateProvider.autoDispose<SnapSortOrder?>((_) => null);

final sortedSnapSearchProvider = FutureProvider.family
    .autoDispose((ref, SnapSearchParameters searchParameters) {
  return ref.watch(snapSearchProvider(searchParameters).future).then(
      (snaps) => snaps.sortedSnaps(ref.watch(snapSortOrderProvider)).toList());
});
