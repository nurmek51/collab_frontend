import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/animations/animations.dart';
import '../../../../../shared/api/companies_api.dart';
import '../../../../../shared/di/service_locator.dart';
import '../../../data/models/order_feed_model.dart';
import '../../../../../core/constants/specialization_constants.dart';

/// Card widget for displaying order feed items - matches Figma design exactly
class OrderFeedCard extends StatefulWidget {
  final OrderFeedModel orderFeed;
  final VoidCallback onTapMoreDetails;

  const OrderFeedCard({
    super.key,
    required this.orderFeed,
    required this.onTapMoreDetails,
  });

  @override
  State<OrderFeedCard> createState() => _OrderFeedCardState();
}

class _OrderFeedCardState extends State<OrderFeedCard> {
  String? _companyLogo;
  String? _companyName;
  bool _isLoadingCompany = false;
  late final CompaniesApi _companiesApi;

  @override
  void initState() {
    super.initState();
    _companiesApi = sl<CompaniesApi>();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    setState(() {
      _isLoadingCompany = true;
    });

    try {
      final companyData = await _companiesApi.getCompanyById(
        widget.orderFeed.companyId,
      );
      setState(() {
        if (companyData != null) {
          _companyLogo = _extractStringValue(companyData['company_logo']);
          _companyName = _extractStringValue(companyData['company_name']);
        }
        _isLoadingCompany = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCompany = false;
      });
    }
  }

  /// Extract string value from dynamic data, handling null and non-string types
  String? _extractStringValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      // If it's a map, try to get 'url' or 'path' or just the first string value
      final url = value['url'] as String?;
      if (url != null && url.isNotEmpty) return url;
      final path = value['path'] as String?;
      if (path != null && path.isNotEmpty) return path;
      // fallback to first string value in the map (safe check)
      final firstString = value.values.whereType<String>().toList();
      if (firstString.isNotEmpty) return firstString.first;
      return null;
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 26.h),
      padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      width: 354.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main content container - width 308
          SizedBox(
            width: 308.w,
            child: Column(
              children: [
                // Content sections - width 306
                SizedBox(
                  width: 306.w,
                  child: Column(
                    children: [
                      // Company header with name and logo
                      SizedBox(
                        width: 306.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Company name - allow ellipsis for long names
                            Expanded(
                              child: Text(
                                _getCompanyName(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 21.sp,
                                  height: 1.149,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // Company logo
                            Container(
                              width: 37.56.w,
                              height: 33.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: _buildCompanyLogo(),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 18.h),

                      // Task section
                      SizedBox(
                        width: 308.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 306.w,
                              child: Text(
                                'Задача',
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                  height: 1.3,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            SizedBox(
                              width: 306.w,
                              child: Text(
                                widget.orderFeed.orderDescription,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
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
                      ),

                      SizedBox(height: 18.h),

                      // Specializations section
                      SizedBox(
                        width: 308.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 306.w,
                              child: Text(
                                'Кого ищем',
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                  height: 1.3,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            SizedBox(
                              width: 306.w,
                              child: Text(
                                widget.orderFeed.orderSpecializations
                                    .map(
                                      (spec) =>
                                          SpecializationConstants.getDisplayNameFromKey(
                                            spec.specialization,
                                          ),
                                    )
                                    .join(', '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
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
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 26.h),

                // More details button with animation
                SizedBox(
                  width: 306.w,
                  child: AnimatedScaleButton(
                    onTap: widget.onTapMoreDetails,
                    duration: AnimationConstants.fast,
                    scale: AnimationConstants.buttonPressScale,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        'Подробнее',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.w500,
                          fontSize: 17.sp,
                          height: 1.149,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get company name from order data
  String _getCompanyName() {
    // For now, we extract company name from order title or use a placeholder
    // In the future, this should come from a proper company entity
    return _companyName ?? widget.orderFeed.orderTitle.split(' ').first;
  }

  /// Build company logo widget
  Widget _buildCompanyLogo() {
    if (_isLoadingCompany) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.lightGrayBackground,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.primaryText),
            ),
          ),
        ),
      );
    }

    if (_companyLogo != null && _companyLogo!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.network(
          _companyLogo!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultLogo();
          },
        ),
      );
    }

    return _buildDefaultLogo();
  }

  Widget _buildDefaultLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.asset(
        'assets/images/invictus_logo-3e4cfa.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.lightGrayBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.business,
              size: 20.w,
              color: AppColors.primaryText,
            ),
          );
        },
      ),
    );
  }
}
