import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/specialization_constants.dart';
import '../../domain/entities/team_member.dart';
import 'colleague_info_modal_new.dart';

/// Widget displaying team member information card
class TeamMemberCard extends StatelessWidget {
  final TeamMember teamMember;

  const TeamMemberCard({super.key, required this.teamMember});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement colleague info modal
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 51.w,
              height: 51.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightGrayBackground,
              ),
              child: teamMember.avatarUrl != null
                  ? ClipOval(child: _getAvatarImage())
                  : const Icon(Icons.person, color: AppColors.profileIconColor),
            ),

            SizedBox(width: 16.w),

            // Team member info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    teamMember.name,
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      height: 1.3,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Role
                  Text(
                    SpecializationConstants.getDisplayNameFromKey(
                      teamMember.role,
                    ),
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                      height: 1.3,
                      color: const Color(0xFF96A4B3),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Rate
                  Text(
                    teamMember.rate,
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
                      fontSize: 13.sp,
                      height: 1.3,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getAvatarImage() {
    // Map team member names to local assets
    switch (teamMember.name) {
      case 'Ева Дева':
        return Image.asset('assets/images/eva_avatar.png', fit: BoxFit.cover);
      case 'Андрей Водолей':
        return Image.asset(
          'assets/images/andrey_avatar.png',
          fit: BoxFit.cover,
        );
      case 'Антон Скорпион':
        return Image.asset('assets/images/anton_avatar.png', fit: BoxFit.cover);
      default:
        return Container(
          color: AppColors.lightGrayBackground,
          child: const Icon(Icons.person, color: AppColors.profileIconColor),
        );
    }
  }
}
