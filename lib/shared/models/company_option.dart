class CompanyOption {
  final String id;
  final String name;
  final String? subtitle;
  final String? description;
  final String? avatarUrl;

  const CompanyOption({
    required this.id,
    required this.name,
    this.subtitle,
    this.description,
    this.avatarUrl,
  });

  bool matchesQuery(String query) {
    final normalizedQuery = query.toLowerCase().trim();
    if (normalizedQuery.isEmpty) {
      return true;
    }
    final haystacks = <String>[
      name,
      if (subtitle != null) subtitle!,
      if (description != null) description!,
    ];
    return haystacks.any(
      (value) => value.toLowerCase().contains(normalizedQuery),
    );
  }
}
