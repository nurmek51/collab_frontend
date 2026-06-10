class ResumeUploadResult {
  final bool hasResume;
  final String resumeFilename;
  final DateTime resumeUploadedAt;

  const ResumeUploadResult({
    required this.hasResume,
    required this.resumeFilename,
    required this.resumeUploadedAt,
  });

  factory ResumeUploadResult.fromJson(Map<String, dynamic> json) {
    return ResumeUploadResult(
      hasResume: json['has_resume'] as bool? ?? true,
      resumeFilename: json['resume_filename'] as String,
      resumeUploadedAt: DateTime.parse(json['resume_uploaded_at'] as String),
    );
  }
}

class ResumeDownloadResult {
  final String downloadUrl;
  final String resumeFilename;
  final int expiresInSeconds;

  const ResumeDownloadResult({
    required this.downloadUrl,
    required this.resumeFilename,
    required this.expiresInSeconds,
  });

  factory ResumeDownloadResult.fromJson(Map<String, dynamic> json) {
    return ResumeDownloadResult(
      downloadUrl: json['download_url'] as String,
      resumeFilename: json['resume_filename'] as String,
      expiresInSeconds: json['expires_in_seconds'] as int? ?? 3600,
    );
  }
}

class ResumeDeleteResult {
  final bool deleted;

  const ResumeDeleteResult({required this.deleted});

  factory ResumeDeleteResult.fromJson(Map<String, dynamic> json) {
    return ResumeDeleteResult(deleted: json['deleted'] as bool? ?? true);
  }
}
