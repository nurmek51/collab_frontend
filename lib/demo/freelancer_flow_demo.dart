import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/navigation/app_router.dart';

/// Demo page to showcase the freelancer flow implementation
class FreelancerFlowDemo extends StatelessWidget {
  const FreelancerFlowDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Freelancer Flow Demo',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w700,
                    fontSize: 24.sp,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 30.h),
                Text(
                  'Implementation Complete:',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                    fontSize: 18.sp,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 20.h),
                _buildFeatureItem('✅ Step 2: Specialization Selection Modal'),
                _buildFeatureItem('✅ Step 3: Project Offer Page'),
                _buildFeatureItem('✅ Step 4: "Just a Minute" Modal'),
                _buildFeatureItem('✅ Mock Contract Data Integration'),
                _buildFeatureItem('✅ Complete Flow Integration'),
                _buildFeatureItem('✅ Feed Integration'),
                _buildFeatureItem('✅ API Integration'),
                _buildFeatureItem('✅ Pixel-perfect UI from Figma'),
                _buildFeatureItem('✅ Navigation Flow'),
                SizedBox(height: 40.h),
                Text(
                  'Flow:',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                    fontSize: 18.sp,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 15.h),
                Text(
                  '1. User clicks "Подробнее" on feed card\n'
                  '2. If multiple specializations → Modal opens\n'
                  '3. User selects specialization\n'
                  '4. Navigate to Project Offer Page\n'
                  '5. User clicks "Откликнуться" (Respond)\n'
                  '6. "Just a Minute" modal appears\n'
                  '7. User reviews contracts & signs via ЭЦП\n'
                  '8. Response submitted to project',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    height: 1.5,
                    color: AppColors.primaryText,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push(AppRouter.myOrdersRoute),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                    ),
                    child: Text(
                      'Go to Feed Page to Test',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontSize: 17.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}
