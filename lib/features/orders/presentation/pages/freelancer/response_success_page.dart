import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/navigation/app_router.dart';

/// Success page displayed after user successfully responds to a project offer
class ResponseSuccessPage extends StatelessWidget {
  const ResponseSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 394.w,
        height: double.infinity,
        decoration: const BoxDecoration(color: AppColors.backgroundColor),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main success card
              Container(
                width: 354.w,
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(32.r),
                ),
                padding: EdgeInsets.fromLTRB(43.w, 24.h, 43.w, 34.h),
                child: Column(
                  children: [
                    // Success emoji
                    Text(
                      '👌🏻',
                      style: TextStyle(
                        fontFamily: 'SF Compact',
                        fontWeight: FontWeight.w800,
                        fontSize: 58.sp,
                        height: 1.193,
                        color: AppColors.black,
                      ),
                    ),

                    SizedBox(height: 19.h),

                    // Content section
                    Column(
                      children: [
                        // Title
                        Text(
                          'Готово!',
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.w700,
                            fontSize: 21.sp,
                            height: 1.149,
                            color: AppColors.primaryText,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // Description
                        SizedBox(
                          width: 290.w,
                          child: Text(
                            'Вы успешно откликнулись на оффер. За статусом отклика можно следить на странице «Моя работа»',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              height: 1.3,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 19.h),

                    // Action button
                    SizedBox(
                      width: 272.w,
                      child: ElevatedButton(
                        onPressed: () => _navigateToWorkPage(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: Text(
                          'На страницу работы',
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.w500,
                            fontSize: 17.sp,
                            height: 1.3,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToWorkPage(BuildContext context) {
    // Navigate to "My Work" page to see the response status
    context.go(AppRouter.myWorkRoute);
  }
}
