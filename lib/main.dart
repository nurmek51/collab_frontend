import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Conditional import for web-only code
import 'core/utils/url_strategy_stub.dart'
    if (dart.library.html) 'core/utils/url_strategy_web.dart';

// Core
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/widgets/conditional_responsive_wrapper.dart';
import 'l10n/app_localizations.dart';

// Shared DI (temporary backwards compatibility)
import 'shared/di/service_locator.dart' as legacy_di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure URL strategy (no-op on mobile platforms)
  configureUrlStrategy();

  // Initialize legacy dependencies (backwards compatibility)
  await legacy_di.initializeDependencies();

  runApp(const CollabApp());
}

class CollabApp extends StatelessWidget {
  const CollabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Collab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return ConditionalResponsiveWrapper(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
