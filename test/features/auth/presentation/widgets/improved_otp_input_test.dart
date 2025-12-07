import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Collab/features/auth/presentation/widgets/improved_otp_input.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  group('ImprovedOtpInput', () {
    testWidgets('should build without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: ImprovedOtpInput(length: 4, onCompleted: (value) {}),
            ),
          ),
        ),
      );

      expect(find.byType(ImprovedOtpInput), findsOneWidget);
    });

    testWidgets('should have correct number of text fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: ImprovedOtpInput(length: 4, onCompleted: (value) {}),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(4));
    });
  });
}
