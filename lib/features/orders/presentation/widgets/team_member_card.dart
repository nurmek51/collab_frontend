import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/specialization_constants.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../domain/entities/team_member.dart';

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
            UserAvatar(
              userId: teamMember.id,
              hasAvatar: teamMember.hasAvatar,
              fallbackName: teamMember.name,
              size: 51.w,
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

}
