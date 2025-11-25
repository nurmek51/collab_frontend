import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/specialization_constants.dart';

class SpecializationWithLevel extends Equatable {
  final String specialization;
  final String? skillLevel;

  const SpecializationWithLevel({
    required this.specialization,
    this.skillLevel,
  });

  SpecializationWithLevel copyWith({
    String? specialization,
    String? skillLevel,
  }) {
    return SpecializationWithLevel(
      specialization: specialization ?? this.specialization,
      skillLevel: skillLevel ?? this.skillLevel,
    );
  }

  Map<String, dynamic> toJson() {
    // Send the actual specialization text - works for both standard and custom
    // Standard specializations: sent as their display names
    // Custom "Other" specializations: sent as user-entered text
    return {
      'specialization': specialization,
      if (skillLevel != null && skillLevel!.isNotEmpty) 'level': skillLevel,
    };
  }

  Map<String, dynamic> toApiJson() {
    // Send the actual specialization text - works for both standard and custom
    // Standard specializations: sent as their display names
    // Custom "Other" specializations: sent as user-entered text
    return {
      'specialization': specialization,
      if (skillLevel != null && skillLevel!.isNotEmpty) 'level': skillLevel,
    };
  }

  Map<String, dynamic> toStorageJson() {
    return {
      'specialization': specialization,
      if (skillLevel != null && skillLevel!.isNotEmpty)
        'skill_level': skillLevel,
    };
  }

  factory SpecializationWithLevel.fromJson(Map<String, dynamic> json) {
    final specializationValue = json['specialization'] as String;

    final displayName =
        SpecializationConstants.keyToDisplayName.containsKey(
          specializationValue,
        )
        ? SpecializationConstants.getDisplayNameFromKey(specializationValue)
        : specializationValue;

    return SpecializationWithLevel(
      specialization: displayName,
      skillLevel: (json['skill_level'] ?? json['level']) as String?,
    );
  }

  factory SpecializationWithLevel.fromApi(Map<String, dynamic> json) {
    return SpecializationWithLevel.fromJson(json);
  }

  @override
  List<Object?> get props => [specialization, skillLevel];
}

class FreelancerOnboardingState extends Equatable {
  final String? selectedRole;
  final String? phoneNumber;
  final String? iin;
  final String? city;
  final String? email;
  final String? name;
  final String? surname;
  final List<SpecializationWithLevel> specializationsWithLevels;
  final Map<String, dynamic> socialLinks;
  final Map<String, dynamic> portfolioLinks;
  final Map<String, dynamic> paymentInfo;
  final String? bio;
  final String? avatarUrl;
  final bool hasProfile;

  const FreelancerOnboardingState({
    this.selectedRole,
    this.phoneNumber,
    this.iin,
    this.city,
    this.email,
    this.name,
    this.surname,
    this.specializationsWithLevels = const [],
    this.socialLinks = const {},
    this.portfolioLinks = const {},
    this.paymentInfo = const {},
    this.bio,
    this.avatarUrl,
    this.hasProfile = false,
  });

  FreelancerOnboardingState copyWith({
    String? selectedRole,
    String? phoneNumber,
    String? iin,
    String? city,
    String? email,
    String? name,
    String? surname,
    List<SpecializationWithLevel>? specializationsWithLevels,
    Map<String, dynamic>? socialLinks,
    Map<String, dynamic>? portfolioLinks,
    Map<String, dynamic>? paymentInfo,
    String? bio,
    String? avatarUrl,
    bool? hasProfile,
  }) {
    return FreelancerOnboardingState(
      selectedRole: selectedRole ?? this.selectedRole,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      iin: iin ?? this.iin,
      city: city ?? this.city,
      email: email ?? this.email,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      specializationsWithLevels:
          specializationsWithLevels ?? this.specializationsWithLevels,
      socialLinks: socialLinks ?? this.socialLinks,
      portfolioLinks: portfolioLinks ?? this.portfolioLinks,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasProfile: hasProfile ?? this.hasProfile,
    );
  }

  Map<String, dynamic> toApiPayload() {
    return <String, dynamic>{
      'specializations_with_levels': specializationsWithLevels
          .map((spec) => spec.toApiJson())
          .toList(),
      'social_links': socialLinks,
      'portfolio_links': portfolioLinks,
      'payment_info': paymentInfo,
      'city': city ?? '',
      'email': email ?? '',
      'iin': iin ?? '',
      'phone_number': phoneNumber ?? '',
      'name': name ?? '',
      'surname': surname ?? '',
      'bio': bio ?? '',
      if (avatarUrl != null && avatarUrl!.isNotEmpty) 'avatar_url': avatarUrl,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedRole': selectedRole,
      'phoneNumber': phoneNumber,
      'iin': iin,
      'city': city,
      'email': email,
      'name': name,
      'surname': surname,
      'specializationsWithLevels': specializationsWithLevels
          .map((e) => e.toStorageJson())
          .toList(),
      'socialLinks': socialLinks,
      'portfolioLinks': portfolioLinks,
      'paymentInfo': paymentInfo,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'hasProfile': hasProfile,
    };
  }

  factory FreelancerOnboardingState.fromJson(Map<String, dynamic> json) {
    return FreelancerOnboardingState(
      selectedRole: json['selectedRole'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      iin: json['iin'] as String?,
      city: json['city'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      specializationsWithLevels:
          (json['specializationsWithLevels'] as List<dynamic>?)
              ?.map(
                (e) => SpecializationWithLevel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [],
      socialLinks: Map<String, dynamic>.from(json['socialLinks'] as Map? ?? {}),
      portfolioLinks: Map<String, dynamic>.from(
        json['portfolioLinks'] as Map? ?? {},
      ),
      paymentInfo: Map<String, dynamic>.from(json['paymentInfo'] as Map? ?? {}),
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      hasProfile: json['hasProfile'] as bool? ?? false,
    );
  }

  factory FreelancerOnboardingState.fromApi(Map<String, dynamic> json) {
    return FreelancerOnboardingState(
      phoneNumber: json['phone_number'] as String?,
      iin: json['iin'] as String?,
      city: json['city'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      specializationsWithLevels:
          (json['specializations_with_levels'] as List<dynamic>? ?? [])
              .map(
                (e) => SpecializationWithLevel.fromApi(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
      socialLinks: Map<String, dynamic>.from(
        json['social_links'] as Map? ?? {},
      ),
      portfolioLinks: Map<String, dynamic>.from(
        json['portfolio_links'] as Map? ?? {},
      ),
      paymentInfo: Map<String, dynamic>.from(
        json['payment_info'] as Map? ?? {},
      ),
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      hasProfile: true,
    );
  }

  bool get isReadyForSubmission {
    return bio != null && bio!.trim().isNotEmpty;
  }

  @override
  List<Object?> get props => [
    selectedRole,
    phoneNumber,
    iin,
    city,
    email,
    name,
    surname,
    specializationsWithLevels,
    socialLinks,
    portfolioLinks,
    paymentInfo,
    bio,
    avatarUrl,
    hasProfile,
  ];
}

class FreelancerOnboardingStore {
  static const String _stateKey = 'freelancer_onboarding_state';
  static const String _roleKey = 'selected_role';
  static const String _phoneKey = 'phone_number';

  Future<void> saveState(FreelancerOnboardingState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_stateKey, jsonEncode(state.toJson()));
    } catch (_) {}
  }

  Future<FreelancerOnboardingState> loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_stateKey);
      if (jsonString == null) {
        return const FreelancerOnboardingState();
      }
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return FreelancerOnboardingState.fromJson(json);
    } catch (_) {
      return const FreelancerOnboardingState();
    }
  }

  Future<void> saveRole(String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_roleKey, role);
    } catch (_) {}
  }

  Future<String?> loadRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_roleKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePhoneNumber(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_phoneKey, phoneNumber);
      final current = await loadState();
      await saveState(current.copyWith(phoneNumber: phoneNumber));
    } catch (_) {}
  }

  Future<String?> loadPhoneNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_phoneKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_stateKey),
        prefs.remove(_roleKey),
        prefs.remove(_phoneKey),
      ]);
    } catch (_) {}
  }

  Future<void> updateField(String field, dynamic value) async {
    final currentState = await loadState();
    FreelancerOnboardingState newState;

    switch (field) {
      case 'iin':
        newState = currentState.copyWith(iin: value as String?);
        break;
      case 'city':
        newState = currentState.copyWith(city: value as String?);
        break;
      case 'email':
        newState = currentState.copyWith(email: value as String?);
        break;
      case 'name':
        newState = currentState.copyWith(name: value as String?);
        break;
      case 'surname':
        newState = currentState.copyWith(surname: value as String?);
        break;
      case 'specializationsWithLevels':
        newState = currentState.copyWith(
          specializationsWithLevels: value as List<SpecializationWithLevel>?,
        );
        break;
      case 'socialLinks':
        newState = currentState.copyWith(
          socialLinks: Map<String, dynamic>.from(value as Map? ?? {}),
        );
        break;
      case 'portfolioLinks':
        newState = currentState.copyWith(
          portfolioLinks: Map<String, dynamic>.from(value as Map? ?? {}),
        );
        break;
      case 'paymentInfo':
        newState = currentState.copyWith(
          paymentInfo: Map<String, dynamic>.from(value as Map? ?? {}),
        );
        break;
      case 'bio':
        newState = currentState.copyWith(bio: value as String?);
        break;
      case 'avatarUrl':
        newState = currentState.copyWith(avatarUrl: value as String?);
        break;
      case 'phoneNumber':
        final phone = value as String?;
        newState = currentState.copyWith(phoneNumber: phone);
        if (phone != null) {
          await savePhoneNumber(phone);
          return;
        }
        break;
      case 'hasProfile':
        newState = currentState.copyWith(hasProfile: value as bool? ?? false);
        break;
      default:
        return;
    }

    await saveState(newState);
  }
}
