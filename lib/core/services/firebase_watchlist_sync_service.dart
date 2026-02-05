import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movies_app/core/domain/entities/media.dart';

/// Simple Firestore sync service for user watchlist.
/// Assumes Firebase.initializeApp() already called in main.
class FirebaseWatchlistSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'watchlists';

  /// Optional provider to obtain current user id at runtime.
  final String? Function()? userIdProvider;

  FirebaseWatchlistSyncService({this.userIdProvider});

  /// Returns null if no user is logged in (prevents sharing data)
  String? get _userId => userIdProvider?.call();

  /// Check if we have a valid user ID for sync
  bool get _canSync => _userId != null && _userId!.isNotEmpty;

  DocumentReference<Map<String, dynamic>>? get _doc {
    if (!_canSync) return null;
    return _firestore.collection(_collection).doc(_userId);
  }

  Future<void> ensureDocument() async {
    final doc = _doc;
    if (doc == null) return;
    final snap = await doc.get();
    if (!snap.exists) {
      await doc.set({'items': [], 'updatedAt': FieldValue.serverTimestamp()});
    }
  }

  Future<List<Media>> fetchRemote(List<Media> local) async {
    if (!_canSync) return local; // No sync for unauthenticated users
    try {
      await ensureDocument();
      final doc = _doc;
      if (doc == null) return local;
      final snap = await doc.get();
      final items = (snap.data()?['items'] as List?) ?? [];
      // Merge remote with local (avoid duplicates by tmdbID)
      final map = {for (final m in local) m.tmdbID: m};
      for (final raw in items) {
        if (raw is Map<String, dynamic>) {
          final media = Media(
            tmdbID: raw['tmdbID'] ?? 0,
            title: raw['title'] ?? '',
            posterUrl: raw['posterUrl'] ?? '',
            backdropUrl: raw['backdropUrl'] ?? '',
            voteAverage: (raw['voteAverage'] ?? 0).toDouble(),
            releaseDate: raw['releaseDate'] ?? '',
            overview: raw['overview'] ?? '',
            isMovie: raw['isMovie'] ?? true,
          );
          map[media.tmdbID] = media;
        }
      }
      return map.values.toList();
    } catch (_) {
      return local; // fail-safe
    }
  }

  Future<void> pushAll(List<Media> items) async {
    if (!_canSync) return;
    final doc = _doc;
    if (doc == null) return;
    final serialized = items.map(_serialize).toList();
    await doc.set({
      'items': serialized,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> add(Media media) async {
    if (!_canSync) return;
    await ensureDocument();
    final doc = _doc;
    if (doc == null) return;
    await doc.update({
      'items': FieldValue.arrayUnion([_serialize(media)]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> remove(int tmdbId) async {
    if (!_canSync) return;
    await ensureDocument();
    final doc = _doc;
    if (doc == null) return;
    // Need current snapshot to remove correct object
    final snap = await doc.get();
    final items = (snap.data()?['items'] as List?) ?? [];
    items.removeWhere((e) => e is Map && (e['tmdbID'] == tmdbId));
    await doc.set({
      'items': items,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Map<String, dynamic> _serialize(Media m) => {
        'tmdbID': m.tmdbID,
        'title': m.title,
        'posterUrl': m.posterUrl,
        'backdropUrl': m.backdropUrl,
        'voteAverage': m.voteAverage,
        'releaseDate': m.releaseDate,
        'overview': m.overview,
        'isMovie': m.isMovie,
      };
}
