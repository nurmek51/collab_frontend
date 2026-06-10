import '../api/auth_api.dart';
import '../api/avatar_models.dart';

class _CachedAvatarUrl {
  final String url;
  final DateTime expiresAt;

  const _CachedAvatarUrl({required this.url, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class AvatarUrlCache {
  final AuthApi _authApi;
  final Map<String, _CachedAvatarUrl> _cache = {};

  AvatarUrlCache(this._authApi);

  static const String _meKey = '__me__';

  String _keyFor(String? userId) => userId ?? _meKey;

  void invalidate({String? userId}) {
    _cache.remove(_keyFor(userId));
  }

  void clear() => _cache.clear();

  Future<String?> resolveUrl({
    String? userId,
    required bool hasAvatar,
  }) async {
    if (!hasAvatar) return null;

    final key = _keyFor(userId);
    final cached = _cache[key];
    if (cached != null && !cached.isExpired) {
      return cached.url;
    }

    final AvatarDownloadResult result = userId == null
        ? await _authApi.getMyAvatarDownloadUrl()
        : await _authApi.getUserAvatarDownloadUrl(userId);

    final bufferSeconds = result.expiresInSeconds > 120
        ? 60
        : (result.expiresInSeconds / 2).floor();

    _cache[key] = _CachedAvatarUrl(
      url: result.downloadUrl,
      expiresAt: DateTime.now().add(
        Duration(seconds: result.expiresInSeconds - bufferSeconds),
      ),
    );

    return result.downloadUrl;
  }
}
