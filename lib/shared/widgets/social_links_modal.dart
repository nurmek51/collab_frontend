import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';

class SocialLinksModal extends StatelessWidget {
  final String telegramUrl;
  final String whatsAppUrl;

  const SocialLinksModal({
    super.key,
    this.telegramUrl = 'https://t.me/nurmek51',
    this.whatsAppUrl = 'https://t.me/nurmek51',
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      height: 382.h,
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16.h,
            right: 16.w,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 30.w,
                height: 30.h,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            top: 52.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Collab на связи!',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w700,
                    fontSize: 26.sp,
                    height: 1.149,
                    color: const Color(0xFF353F49),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Текст о том, что мы на связи в телеграм (а может и в вацапе), Мария приди!',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w400,
                    fontSize: 17.sp,
                    height: 1.3,
                    color: const Color(0xFF353F49),
                  ),
                ),
                SizedBox(height: 21.h),
                Column(
                  children: [
                    _buildSocialButton(
                      onTap: _openTelegram,
                      backgroundColor: const Color(0xFF1EA1F3),
                      borderColor: Colors.white.withValues(alpha: 0.12),
                      text: 'Поддержка в Telegram',
                      iconAsset: 'assets/svgs/telegram_icon.svg',
                      screenWidth: screenWidth,
                    ),
                    SizedBox(height: 12.h),
                    _buildSocialButton(
                      onTap: _openWhatsApp,
                      backgroundColor: const Color(0xFF25D366),
                      borderColor: const Color(0xFF25D366),
                      text: 'Поддержка в Whatsapp',
                      iconAsset: 'assets/svgs/whatsapp_icon.svg',
                      screenWidth: screenWidth,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color borderColor,
    required String text,
    required double screenWidth,
    required String? iconAsset,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth - 40.w,
        height: 54.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(iconAsset!, width: 24.w, height: 24.h),
              SizedBox(width: 8.w),
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w500,
                  fontSize: 17.sp,
                  height: 1.149,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openTelegram() async {
    final Uri uri = Uri.parse(telegramUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      await launchUrl(Uri.parse(telegramUrl), mode: LaunchMode.platformDefault);
    }
  }

  Future<void> _openWhatsApp() async {
    final Uri uri = Uri.parse(whatsAppUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      await launchUrl(Uri.parse(whatsAppUrl), mode: LaunchMode.platformDefault);
    }
  }

  static Future<void> show(BuildContext context) async {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) => const SocialLinksModal(),
    );
  }
}
