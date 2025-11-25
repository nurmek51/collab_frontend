/// Profile entity representing user profile
class Profile {
  final String id;
  final String userId;
  final String? name;
  final String? surname;
  final String? email;
  final String? phoneNumber;
  final String? iin;
  final String? city;
  final String? bio;
  final String? avatar;
  final List<String> skills;
  final List<SocialLink> socialLinks;
  final List<PortfolioItem> portfolio;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.userId,
    this.name,
    this.surname,
    this.email,
    this.phoneNumber,
    this.iin,
    this.city,
    this.bio,
    this.avatar,
    required this.skills,
    required this.socialLinks,
    required this.portfolio,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get full name
  String get fullName {
    if (name != null && surname != null) {
      return '$name $surname';
    }
    if (name != null) {
      return name!;
    }
    return 'User';
  }

  /// Check if profile is complete
  bool get isComplete {
    return name != null &&
        surname != null &&
        email != null &&
        phoneNumber != null &&
        skills.isNotEmpty;
  }

  /// Get completion percentage
  double get completionPercentage {
    int filledFields = 0;
    const int totalFields = 8;

    if (name != null && name!.isNotEmpty) filledFields++;
    if (surname != null && surname!.isNotEmpty) filledFields++;
    if (email != null && email!.isNotEmpty) filledFields++;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) filledFields++;
    if (iin != null && iin!.isNotEmpty) filledFields++;
    if (city != null && city!.isNotEmpty) filledFields++;
    if (bio != null && bio!.isNotEmpty) filledFields++;
    if (skills.isNotEmpty) filledFields++;

    return filledFields / totalFields;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Profile(id: $id, name: $fullName)';
}

/// Social link entity
class SocialLink {
  final String platform;
  final String url;

  const SocialLink({required this.platform, required this.url});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SocialLink &&
        other.platform == platform &&
        other.url == url;
  }

  @override
  int get hashCode => platform.hashCode ^ url.hashCode;
}

/// Portfolio item entity
class PortfolioItem {
  final String title;
  final String description;
  final String url;
  final List<String> images;

  const PortfolioItem({
    required this.title,
    required this.description,
    required this.url,
    required this.images,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortfolioItem && other.title == title && other.url == url;
  }

  @override
  int get hashCode => title.hashCode ^ url.hashCode;
}
