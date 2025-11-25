import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Mixin that provides common functionality for all freelancer flow pages
/// This reduces code duplication and ensures consistent behavior
mixin FreelancerPageMixin<T extends StatefulWidget> on State<T> {
  /// Builds the unified bottom tab bar for freelancer pages
  /// Note: This is now handled by the shell route, so this method returns empty
  @deprecated
  Widget buildFreelancerBottomTabBar(int currentIndex) {
    return const SizedBox.shrink();
  }

  /// Common error handling widget for freelancer pages
  Widget buildErrorState({
    required String message,
    required VoidCallback onRetry,
    String retryButtonText = 'Попробовать снова',
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.w, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              'Ошибка',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                retryButtonText,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Common loading state widget for freelancer pages
  Widget buildLoadingState({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.black),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Common empty state widget for freelancer pages
  Widget buildEmptyState({
    required String title,
    required String description,
    IconData icon = Icons.inbox_outlined,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64.w, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[SizedBox(height: 24.h), action],
          ],
        ),
      ),
    );
  }
}
