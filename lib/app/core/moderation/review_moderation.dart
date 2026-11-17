import '../storage/storage_service.dart';

/// Reviews the shopper has reported or whose author they blocked. Kept on
/// the device so they disappear at once, whether or not the report reached
/// the server. Reviews carry no author id, so a block is by display name.
class ReviewModeration {
  ReviewModeration._();

  static const _kHidden = 'moderation_hidden_reviews';
  static const _kBlocked = 'moderation_blocked_authors';

  static final _store = StorageService.instance;

  static Set<int> get _hidden =>
      {...?_store.read<List>(_kHidden)?.map((e) => e as int)};

  static Set<String> get _blocked =>
      {...?_store.read<List>(_kBlocked)?.map((e) => '$e')};

  static bool isHidden({required int reviewId, required String author}) =>
      _hidden.contains(reviewId) ||
      _blocked.contains(author.trim().toLowerCase());

  static Future<void> hideReview(int reviewId) =>
      _store.write(_kHidden, [..._hidden, reviewId]);

  static Future<void> blockAuthor(String author) =>
      _store.write(_kBlocked, [..._blocked, author.trim().toLowerCase()]);
}
