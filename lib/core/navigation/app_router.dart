import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'auth_refresh_notifier.dart';
import '../animations/smooth_page_transition.dart';
import '../animations/animation_constants.dart';
import '../../features/auth/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/phone_number_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/select_role_page.dart';
import '../../features/auth/presentation/pages/freelancer_form_page.dart';
import '../../features/auth/presentation/pages/specializations_page.dart';
import '../../features/auth/presentation/pages/specialization_levels_page.dart';
import '../../features/auth/presentation/pages/experience_page.dart';
import '../../features/auth/presentation/pages/success_page.dart';
import '../../features/orders/presentation/pages/freelancer/feed_page.dart';
import '../../features/orders/presentation/pages/client/my_orders_page.dart';
import '../../features/orders/presentation/pages/client/new_order_page.dart';
import '../../features/orders/presentation/pages/client/client_order_details_page.dart';
import '../../features/orders/presentation/pages/client/documents_list_page.dart';
import '../../features/orders/presentation/pages/freelancer/response_success_page.dart';
import '../../features/orders/presentation/pages/freelancer/callback_success_page.dart';
import '../../features/orders/presentation/pages/client/callback_accepted_page.dart';
import '../../features/orders/presentation/pages/freelancer/my_work_page.dart';
import '../../features/orders/presentation/pages/freelancer/project_details_page.dart';
import '../../features/profile/presentation/pages/client_profile_page.dart';
import '../../features/profile/presentation/pages/freelancer_profile_page.dart';
import '../../features/profile/presentation/pages/my_specializations_page.dart';
import '../../features/profile/presentation/pages/specialization_details_page.dart';
import '../../features/payments/presentation/pages/payments_soon_page.dart';
import '../../../shared/widgets/unified_freelancer_bottom_tab_bar.dart';
import '../../features/admin/presentation/pages/admin_orders_page.dart';
import '../../features/admin/presentation/pages/admin_freelancers_page.dart';
import '../../features/admin/presentation/pages/admin_login_page.dart';
import '../../features/onboarding/presentation/pages/client_onboarding_flow_page.dart';
import '../../../shared/di/service_locator.dart';
import '../../../shared/guards/admin_auth_guard.dart';
import '../../../shared/guards/freelancer_profile_guard.dart';
import '../../../shared/guards/client_guard.dart';
import '../../../shared/state/auth.dart';
import '../../../shared/state/freelancer_onboarding_state.dart';

class AppRouter {
  AppRouter._();

  static const String welcomeRoute = '/welcome';
  static const String phoneNumberRoute = '/phone-number';
  static const String otpRoute = '/otp';
  static const String selectRoleRoute = '/select-role';
  static const String freelancerFormRoute = '/freelancer-form';
  static const String specializationsRoute = '/specializations';
  static const String specializationLevelsRoute = '/specialization-levels';
  static const String experienceRoute = '/experience';
  static const String successRoute = '/success';
  static const String feedRoute = '/feed';
  static const String myOrdersRoute = '/my-orders';
  static const String newOrderRoute = '/new-order';
  static const String clientOrderDetailsRoute = '/client-order-details';
  static const String clientDocumentsRoute = '/client-documents';
  static const String responseSuccessRoute = '/response-success';
  static const String callbackSuccessRoute = '/callback-success';
  static const String callbackAcceptedRoute = '/callback-accepted';
  static const String myWorkRoute = '/my-work';
  static const String paymentsRoute = '/payments';
  static const String projectDetailsRoute = '/project-details';
  static const String clientProfileRoute = '/client-profile';
  static const String freelancerProfileRoute = '/freelancer-profile';
  static const String mySpecializationsRoute = '/my-specializations';
  static const String specializationDetailsRoute = '/specialization-details';
  static const String adminRoute = '/manage/admin/panel';
  static const String adminLoginRoute = '/manage/admin/panel/login';
  static const String adminFreelancersRoute = '/manage/admin/panel/freelancers';
  static const String clientOnboardingRoute = '/client-onboarding';

  static const List<String> _freelancerOnboardingRoutes = [
    freelancerFormRoute,
    specializationsRoute,
    specializationLevelsRoute,
    experienceRoute,
    successRoute,
  ];

  static const List<String> _authFlowRoutes = [
    '/',
    welcomeRoute,
    phoneNumberRoute,
    otpRoute,
    selectRoleRoute,
  ];

  static const List<String> _clientAppRoutes = [
    myOrdersRoute,
    newOrderRoute,
    clientOnboardingRoute,
    clientProfileRoute,
    clientOrderDetailsRoute,
    clientDocumentsRoute,
    callbackAcceptedRoute,
  ];

  static final AuthRefreshNotifier authRefreshNotifier = AuthRefreshNotifier();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: authRefreshNotifier,
    redirect: (context, state) async {
      final path = state.uri.path;

      // Handle admin auth - but skip the login page itself
      if (path.startsWith(adminRoute) && path != adminLoginRoute) {
        final adminGuard = sl<AdminAuthGuard>();
        return await adminGuard.checkAdminAuth(state);
      }

      // Check if user is authenticated first
      final authStore = sl<AuthStore>();
      final isAuthenticated = await authStore.isAuthenticated();

      // If not authenticated, allow access to auth flow pages only
      if (!isAuthenticated) {
        final allowedRoutes = [
          ..._authFlowRoutes,
          adminLoginRoute,
        ];

        if (!allowedRoutes.contains(path) && !path.startsWith(adminRoute)) {
          return '/';
        }
        return null;
      }

      // User is authenticated - check role and profile status
      final role = await authStore.getRole();

      if (role == null || role.isEmpty) {
        if (path != selectRoleRoute && !path.startsWith(adminRoute)) {
          return selectRoleRoute;
        }
        return null;
      }

      if (role == 'freelancer') {
        final guard = sl<FreelancerProfileGuard>();
        final redirectRoute = await guard.getRequiredRedirect();
        final canAccessOrderFlow = await guard.canAccessOrderFlow();

        // Authenticated freelancers must not stay on pre-auth screens (e.g. /welcome)
        final isPreAuthRoute =
            path == welcomeRoute ||
            path == phoneNumberRoute ||
            path == otpRoute ||
            path == selectRoleRoute;

        if (isPreAuthRoute) {
          if (canAccessOrderFlow) {
            return myWorkRoute;
          }
          return redirectRoute ?? freelancerFormRoute;
        }

        // Preserve URL on web refresh during onboarding / pending review
        if (_freelancerOnboardingRoutes.contains(path)) {
          if (path == successRoute && canAccessOrderFlow) {
            return myWorkRoute;
          }
          if (canAccessOrderFlow && path != successRoute) {
            return myWorkRoute;
          }
          return null;
        }

        final orderFlowRoutes = [
          myWorkRoute,
          feedRoute,
          paymentsRoute,
          projectDetailsRoute,
          freelancerProfileRoute,
          responseSuccessRoute,
          callbackSuccessRoute,
          mySpecializationsRoute,
          specializationDetailsRoute,
        ];

        final dynamicOrderFlowPatterns = [
          projectDetailsRoute,
          clientOrderDetailsRoute,
          clientDocumentsRoute,
        ];

        if (!canAccessOrderFlow) {
          var isAccessingOrderFlow = orderFlowRoutes.contains(path);

          if (!isAccessingOrderFlow) {
            for (final pattern in dynamicOrderFlowPatterns) {
              if (path.startsWith('$pattern/')) {
                isAccessingOrderFlow = true;
                break;
              }
            }
          }

          if (isAccessingOrderFlow) {
            return redirectRoute ?? successRoute;
          }
        }

        if (path == '/') {
          if (redirectRoute != null) {
            return redirectRoute;
          }
          if (canAccessOrderFlow) {
            return myWorkRoute;
          }
          return freelancerFormRoute;
        }
      } else if (role == 'client') {
        final clientGuard = sl<ClientGuard>();
        final clientRedirect = await clientGuard.getRequiredRedirect();

        final isClientAppRoute =
            _clientAppRoutes.contains(path) ||
            path.startsWith('$clientOrderDetailsRoute/') ||
            path.startsWith('$clientDocumentsRoute/');

        if (clientRedirect != null &&
            path != clientOnboardingRoute &&
            !isClientAppRoute) {
          return clientRedirect;
        }

        if (path == '/') {
          return clientRedirect ?? myOrdersRoute;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'landing',
        pageBuilder: (context, state) => SmoothPageTransition.build(
          key: state.pageKey,
          child: const LandingPage(),
        ),
      ),
      GoRoute(
        path: adminRoute,
        name: 'admin',
        builder: (context, state) => const AdminOrdersPage(),
      ),
      GoRoute(
        path: adminFreelancersRoute,
        name: 'admin-freelancers',
        builder: (context, state) => const AdminFreelancersPage(),
      ),
      GoRoute(
        path: adminLoginRoute,
        name: 'admin-login',
        builder: (context, state) {
          final redirectPath = state.uri.queryParameters['redirect'];
          return AdminLoginPage(redirectPath: redirectPath);
        },
      ),
      GoRoute(
        path: welcomeRoute,
        name: 'welcome',
        pageBuilder: (context, state) => SmoothPageTransition.build(
          key: state.pageKey,
          child: const WelcomePage(),
        ),
      ),
      GoRoute(
        path: phoneNumberRoute,
        name: 'phone-number',
        pageBuilder: (context, state) => SmoothPageTransition.build(
          key: state.pageKey,
          child: const PhoneNumberPage(),
        ),
      ),
      GoRoute(
        path: otpRoute,
        name: 'otp',
        pageBuilder: (context, state) {
          final phoneNumber = state.extra as String?;
          return SmoothPageTransition.build(
            key: state.pageKey,
            child: OtpPage(phoneNumber: phoneNumber),
          );
        },
      ),
      GoRoute(
        path: selectRoleRoute,
        name: 'select-role',
        pageBuilder: (context, state) => SmoothPageTransition.build(
          key: state.pageKey,
          child: const SelectRolePage(),
        ),
      ),
      GoRoute(
        path: freelancerFormRoute,
        name: 'freelancer-form',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final isFromSuccessPage = extra['isEditMode'] as bool? ?? false;

          return SmoothPageTransition.build(
            key: state.pageKey,
            child: FreelancerFormPage(isFromSuccessPage: isFromSuccessPage),
          );
        },
      ),
      GoRoute(
        path: specializationsRoute,
        name: 'specializations',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final isFromSuccessPage = extra['isEditMode'] as bool? ?? false;
          final isFromMySpecializations =
              extra['isFromMySpecializations'] as bool? ?? false;

          return SmoothPageTransition.build(
            key: state.pageKey,
            child: SpecializationsPage(
              isFromSuccessPage: isFromSuccessPage,
              isFromMySpecializations: isFromMySpecializations,
            ),
          );
        },
      ),
      GoRoute(
        path: specializationLevelsRoute,
        name: 'specialization-levels',
        pageBuilder: (context, state) => SmoothPageTransition.build(
          key: state.pageKey,
          child: const SpecializationLevelsPage(),
        ),
      ),
      GoRoute(
        path: experienceRoute,
        name: 'experience',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final isFromSuccessPage = extra['isEditMode'] as bool? ?? false;
          final isFromMySpecializations =
              extra['isFromMySpecializations'] as bool? ?? false;

          return SmoothPageTransition.build(
            key: state.pageKey,
            child: ExperiencePage(
              isFromSuccessPage: isFromSuccessPage,
              isFromMySpecializations: isFromMySpecializations,
            ),
          );
        },
      ),
      GoRoute(
        path: successRoute,
        name: 'success',
        pageBuilder: (context, state) => SmoothPageTransition.scaleIn(
          key: state.pageKey,
          child: const SuccessPage(),
        ),
      ),

      // Freelancer shell route with persistent bottom tab bar
      ShellRoute(
        builder: (context, state, child) {
          return _FreelancerShell(child: child);
        },
        routes: [
          GoRoute(
            path: feedRoute,
            name: 'feed',
            redirect: (context, state) async {
              // Additional protection: ensure freelancer can access order flow
              final guard = sl<FreelancerProfileGuard>();
              final canAccess = await guard.canAccessOrderFlow();

              if (!canAccess) {
                final redirectRoute = await guard.getRequiredRedirect();
                return redirectRoute ?? successRoute;
              }
              return null; // Allow access
            },
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const FeedPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: AnimationConstants.fast,
            ),
          ),
          GoRoute(
            path: myWorkRoute,
            name: 'my-work',
            redirect: (context, state) async {
              // Additional protection: ensure freelancer can access order flow
              final guard = sl<FreelancerProfileGuard>();
              final canAccess = await guard.canAccessOrderFlow();

              if (!canAccess) {
                final redirectRoute = await guard.getRequiredRedirect();
                return redirectRoute ?? successRoute;
              }
              return null; // Allow access
            },
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const MyWorkPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: AnimationConstants.fast,
            ),
          ),
          GoRoute(
            path: paymentsRoute,
            name: 'payments',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const PaymentsSoonPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: AnimationConstants.fast,
            ),
          ),
          GoRoute(
            path: freelancerProfileRoute,
            name: 'freelancer-profile',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const FreelancerProfilePage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: AnimationConstants.fast,
            ),
          ),
        ],
      ),

      // My Specializations route (modal)
      GoRoute(
        path: mySpecializationsRoute,
        name: 'my-specializations',
        pageBuilder: (context, state) {
          final specs = state.extra as List? ?? [];
          return SmoothPageTransition.build(
            key: state.pageKey,
            child: MySpecializationsPage(
              specializationsWithLevels: specs.cast<SpecializationWithLevel>(),
            ),
          );
        },
      ),

      // Specialization Details route
      GoRoute(
        path: specializationDetailsRoute,
        name: 'specialization-details',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return SmoothPageTransition.build(
            key: state.pageKey,
            child: SpecializationDetailsPage(
              specialization: data['specialization'] as String,
              skillLevel: data['skillLevel'] as String,
              isNew: data['isNew'] as bool,
            ),
          );
        },
      ),

      // Other routes (client flow, modals, etc.)
      GoRoute(
        path: myOrdersRoute,
        name: 'my-orders',
        redirect: (context, state) async {
          final authStore = sl<AuthStore>();
          final role = await authStore.getRole();

          if (role == 'client') {
            final clientGuard = sl<ClientGuard>();
            return await clientGuard.getRequiredRedirect();
          }
          return null;
        },
        pageBuilder: (context, state) => SmoothPageTransition.build(
          key: state.pageKey,
          child: const MyOrdersPage(),
        ),
      ),
      GoRoute(
        path: newOrderRoute,
        name: 'new-order',
        pageBuilder: (context, state) => SmoothPageTransition.build(
          key: state.pageKey,
          child: const NewOrderPage(),
        ),
      ),
      GoRoute(
        path: '$clientOrderDetailsRoute/:orderId',
        name: 'client-order-details',
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return SmoothPageTransition.build(
            key: ValueKey('client-order-details-$orderId'),
            child: ClientOrderDetailsPage(orderId: orderId),
          );
        },
      ),
      GoRoute(
        path: '$clientDocumentsRoute/:orderId',
        name: 'client-documents',
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return SmoothPageTransition.build(
            key: ValueKey('client-documents-$orderId'),
            child: DocumentsListPage(orderId: orderId),
          );
        },
      ),
      GoRoute(
        path: responseSuccessRoute,
        name: 'response-success',
        pageBuilder: (context, state) => SmoothPageTransition.scaleIn(
          key: state.pageKey,
          child: const ResponseSuccessPage(),
        ),
      ),
      GoRoute(
        path: callbackSuccessRoute,
        name: 'callback-success',
        pageBuilder: (context, state) => SmoothPageTransition.scaleIn(
          key: state.pageKey,
          child: const CallbackSuccessPage(),
        ),
      ),
      GoRoute(
        path: callbackAcceptedRoute,
        name: 'callback-accepted',
        pageBuilder: (context, state) => SmoothPageTransition.scaleIn(
          key: state.pageKey,
          child: const CallbackAcceptedPage(),
        ),
      ),
      GoRoute(
        path: '$projectDetailsRoute/:orderId',
        name: 'project-details',
        redirect: (context, state) async {
          // Additional protection: ensure freelancer can access order flow
          final guard = sl<FreelancerProfileGuard>();
          final canAccess = await guard.canAccessOrderFlow();

          if (!canAccess) {
            final redirectRoute = await guard.getRequiredRedirect();
            return redirectRoute ?? successRoute;
          }
          return null; // Allow access
        },
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          final selectedSpecialization =
              state.uri.queryParameters['specialization'];
          final vacancyId = state.uri.queryParameters['vacancy_id'];
          final fromMyWork =
              state.extra is Map<String, dynamic> &&
              (state.extra as Map<String, dynamic>)['fromMyWork'] == true;

          debugPrint(
            'AppRouter: Building project details page for orderId=$orderId, selectedSpecialization=$selectedSpecialization, vacancyId=$vacancyId, fromMyWork=$fromMyWork',
          );

          return SmoothPageTransition.build(
            key: ValueKey(
              'project-details-$orderId-$selectedSpecialization-$vacancyId',
            ),
            child: ProjectDetailsPage(
              orderId: orderId,
              selectedSpecialization: selectedSpecialization,
              vacancyId: vacancyId,
              fromMyWork: fromMyWork,
            ),
          );
        },
      ),
      GoRoute(
        path: clientOnboardingRoute,
        name: 'client-onboarding',
        pageBuilder: (context, state) => SmoothPageTransition.build(
          key: state.pageKey,
          child: ClientOnboardingFlowPage(returnPath: state.extra as String?),
        ),
      ),
      GoRoute(
        path: clientProfileRoute,
        name: 'client-profile',
        pageBuilder: (context, state) => SmoothPageTransition.build(
          key: state.pageKey,
          child: const ClientProfilePage(),
        ),
      ),
    ],
  );
}

/// Freelancer shell widget that provides persistent bottom navigation
class _FreelancerShell extends StatefulWidget {
  final Widget child;

  const _FreelancerShell({required this.child});

  @override
  State<_FreelancerShell> createState() => _FreelancerShellState();
}

class _FreelancerShellState extends State<_FreelancerShell> {
  late int _currentIndex;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter.of(context);

    // Initialize current index based on current route
    final initialLocation = _router.routerDelegate.currentConfiguration.uri
        .toString();
    _currentIndex = _getIndexFromLocation(initialLocation);

    // Listen to route changes
    _router.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    final location = _router.routerDelegate.currentConfiguration.uri.toString();
    _updateCurrentIndex(location);
  }

  int _getIndexFromLocation(String location) {
    if (location == '/feed' || location.startsWith('/feed')) {
      return 0;
    } else if (location == '/my-work' || location.startsWith('/my-work')) {
      return 1;
    } else if (location == '/payments' || location.startsWith('/payments')) {
      return 2;
    } else if (location == '/freelancer-profile' ||
        location.startsWith('/freelancer-profile')) {
      return 3;
    } else {
      return 0; // Default to feed
    }
  }

  void _updateCurrentIndex(String location) {
    final newIndex = _getIndexFromLocation(location);

    if (newIndex != _currentIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: UnifiedFreelancerBottomTabBar(
        currentIndex: _currentIndex,
      ),
      extendBody: true,
    );
  }
}
