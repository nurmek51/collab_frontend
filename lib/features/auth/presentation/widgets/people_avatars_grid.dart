import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// People avatars grid widget matching Figma design
class PeopleAvatarsGrid extends StatelessWidget {
  const PeopleAvatarsGrid({super.key});

  static const _avatarAssets = <String>[
    'assets/images/andrey_avatar.png',
    'assets/images/eva_avatar.png',
    'assets/images/anton_avatar.png',
    'assets/images/profile_avatar.png',
    'assets/images/temp.png',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive avatar size based on available width and height
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        // Calculate avatar size to fit 5 avatars per row with spacing
        final avatarSize = (availableWidth - (4 * 12.w)) / 5;

        // Calculate spacing based on available height
        final spacing = (availableHeight - (4 * avatarSize)) / 3;
        final clampedSpacing = spacing.clamp(8.h, 20.h);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // First row
            _buildAvatarRow(avatarSize, _avatarAssets),

            // Second row
            _buildAvatarRow(avatarSize, _avatarAssets),

            // Third row
            _buildAvatarRow(avatarSize, _avatarAssets),

            // Fourth row
            _buildAvatarRow(avatarSize, _avatarAssets),
          ],
        );
      },
    );
  }

  Widget _buildAvatarRow(double avatarSize, List<String> imagePaths) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: imagePaths
          .map((imagePath) => _buildAvatar(avatarSize, imagePath))
          .toList(),
    );
  }

  Widget _buildAvatar(double size, String imagePath) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0x4D0C0C0D), // rgba(12, 12, 13, 0.3)
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: -8,
          ),
        ],
      ),
      child: ClipOval(
        child: Container(
          color: const Color(0xFFD9D9D9), // Fallback color
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFD9D9D9),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: size * 0.5,
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: const Color(0xFFD9D9D9),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
