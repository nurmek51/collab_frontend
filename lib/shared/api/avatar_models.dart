class AvatarUploadResult {
  final bool hasAvatar;
  final DateTime? avatarUploadedAt;

  const AvatarUploadResult({
    required this.hasAvatar,
    this.avatarUploadedAt,
  });

  factory AvatarUploadResult.fromJson(Map<String, dynamic> json) {
    return AvatarUploadResult(
      hasAvatar: json['has_avatar'] as bool? ?? true,
      avatarUploadedAt: json['avatar_uploaded_at'] != null
          ? DateTime.tryParse(json['avatar_uploaded_at'] as String)
          : null,
    );
  }
}

class AvatarDownloadResult {
  final String downloadUrl;
  final int expiresInSeconds;

  const AvatarDownloadResult({
    required this.downloadUrl,
    required this.expiresInSeconds,
  });

  factory AvatarDownloadResult.fromJson(Map<String, dynamic> json) {
    return AvatarDownloadResult(
      downloadUrl: json['download_url'] as String,
      expiresInSeconds: json['expires_in_seconds'] as int? ?? 3600,
    );
  }
}

class AvatarDeleteResult {
  final bool deleted;

  const AvatarDeleteResult({required this.deleted});

  factory AvatarDeleteResult.fromJson(Map<String, dynamic> json) {
    return AvatarDeleteResult(deleted: json['deleted'] as bool? ?? true);
  }
}
