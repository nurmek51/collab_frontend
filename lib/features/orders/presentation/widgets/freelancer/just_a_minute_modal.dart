import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/contract_document.dart';

/// Modal widget that appears when user clicks "Respond" to show required contracts
class JustAMinuteModal extends StatelessWidget {
  final VoidCallback onSignDocuments;
  final VoidCallback? onClarifyDetails;

  const JustAMinuteModal({
    super.key,
    required this.onSignDocuments,
    this.onClarifyDetails,
  });

  @override
  Widget build(BuildContext context) {
    final contracts = MockContractData.getRequiredContracts();

    return Container(
      height: 798.h,
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Stack(
        children: [
          // Close button positioned at top right
          Positioned(
            top: 16.h,
            right: 14.w,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 30.w,
                height: 30.h,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 16.w, color: AppColors.black),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60.h),

                // Title
                Text(
                  'Минутку!',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w700,
                    fontSize: 26.sp,
                    height: 1.149,
                    color: AppColors.primaryText,
                  ),
                ),

                SizedBox(height: 25.h),

                // Description text
                Text(
                  'Прежде, чем откликнуться в первый раз, подпишите пожалуйста пару документов через eGOV.\n\nЭто нужно только один раз при отклике на самый первый оффер. Благодарим за понимание.',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    height: 1.3,
                    color: AppColors.primaryText,
                  ),
                ),

                SizedBox(height: 21.h),

                // Contract items - dynamically generated from mock data
                ...contracts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final contract = entry.value;
                  return Column(
                    children: [
                      if (index > 0) SizedBox(height: 20.h),
                      _ContractItem(
                        title: contract.title,
                        onTap: () {
                          // TODO: Handle contract tap - could show contract details
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Просмотр документа: ${contract.title}',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }).toList(),

                const Spacer(),

                // Action buttons at bottom
                Column(
                  children: [
                    // Main sign button
                    SizedBox(
                      width: 354.w,
                      child: ElevatedButton(
                        onPressed: onSignDocuments,
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
                          'Подписать через ЭЦП',
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

                    SizedBox(height: 14.h),

                    // Clarify details link
                    if (onClarifyDetails != null)
                      GestureDetector(
                        onTap: onClarifyDetails,
                        child: Text(
                          'Уточнить детали',
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            height: 1.3,
                            color: AppColors.blueAccent,
                          ),
                        ),
                      ),

                    SizedBox(height: 26.h),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual contract item widget
class _ContractItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ContractItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 354.w,
        height: 62.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  height: 1.3,
                  color: AppColors.primaryText,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 19.72.w,
              color: const Color(0xFFA9B6B9),
            ),
          ],
        ),
      ),
    );
  }
}
