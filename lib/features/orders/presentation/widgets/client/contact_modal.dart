import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../shared/di/service_locator.dart';
import '../../../../../shared/utils/help_utils.dart';
import '../../../data/models/order_details_model.dart';
import '../../../data/models/company_model.dart';

/// Bottom modal sheet for contact options
/// Accepts optional order and company context for future integration
class ContactModal extends StatefulWidget {
  final OrderDetailsModel? orderContext;
  final CompanyModel? companyContext;

  const ContactModal({super.key, this.orderContext, this.companyContext});

  @override
  State<ContactModal> createState() => _ContactModalState();
}

class _ContactModalState extends State<ContactModal> {
  bool _isLoading = false;
  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = sl<ApiService>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle for the modal
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.inputBorderColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),

          // "Request a Callback" option
          GestureDetector(
            onTap: _isLoading ? null : _requestCallback,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              alignment: Alignment.centerLeft,
              child: _isLoading
                  ? Row(
                      children: [
                        SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.linkColor,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Заказываем звонок...',
                          style: AppTextStyles.linkText,
                        ),
                      ],
                    )
                  : Text(
                      'Заказать обратный звонок',
                      style: AppTextStyles.linkText,
                    ),
            ),
          ),
          Divider(color: AppColors.inputBorderColor, height: 1.h),

          // "Contact Us" option
          GestureDetector(
            onTap: () async {
              Navigator.of(context).pop();
              await HelpUtils.showSocialLinksModal(context);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              alignment: Alignment.centerLeft,
              child: Text('Связаться с Collab', style: AppTextStyles.linkText),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestCallback() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.requestHelp();

      if (mounted) {
        // Close modal and navigate to success page
        Navigator.of(context).pop();
        context.push('/callback-success');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при заказе: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
