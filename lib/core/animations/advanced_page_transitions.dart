import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'animation_constants.dart';

enum PageTransitionType {
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  scale,
  fade,
  zoom,
  rotate,
  slideUpFade,
  slideDownFade,
  scaleRotate,
  depth,
  cube,
  flip,
}

class AdvancedPageTransitions {
  static PageTransitionType getTransitionType(String routeName) {
    // Different transitions for different page types
    if (routeName.contains('feed') || routeName.contains('my-work')) {
      return PageTransitionType.slideUpFade;
    } else if (routeName.contains('profile') ||
        routeName.contains('settings')) {
      return PageTransitionType.scale;
    } else if (routeName.contains('success') ||
        routeName.contains('callback')) {
      return PageTransitionType.zoom;
    } else if (routeName.contains('specialization') ||
        routeName.contains('experience')) {
      return PageTransitionType.slideRight;
    } else if (routeName.contains('project-info') ||
        routeName.contains('project-offer')) {
      return PageTransitionType.depth;
    } else {
      return PageTransitionType.slideUpFade;
    }
  }

  static CustomTransitionPage<T> buildTransition<T extends Object?>({
    required Widget child,
    required LocalKey key,
    required PageTransitionType type,
    Duration? duration,
  }) {
    final transitionDuration = duration ?? AnimationConstants.pageTransition;

    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: transitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransitionWidget(
          type: type,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  static Widget _buildTransitionWidget({
    required PageTransitionType type,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: AnimationConstants.smoothCurve,
    );

    final entranceAnimation = CurvedAnimation(
      parent: animation,
      curve: AnimationConstants.entranceCurve,
    );

    final gentleAnimation = CurvedAnimation(
      parent: animation,
      curve: AnimationConstants.gentleCurve,
    );

    switch (type) {
      case PageTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(gentleAnimation),
          child: child,
        );

      case PageTransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(gentleAnimation),
          child: child,
        );

      case PageTransitionType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(gentleAnimation),
          child: child,
        );

      case PageTransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(gentleAnimation),
          child: child,
        );

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: AnimationConstants.defaultScale, end: 1.0)
              .animate(
                CurvedAnimation(
                  parent: animation,
                  curve: AnimationConstants.bounceGentle,
                ),
              ),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );

      case PageTransitionType.fade:
        return FadeTransition(opacity: curvedAnimation, child: child);

      case PageTransitionType.zoom:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: AnimationConstants.bounceGentle,
            ),
          ),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(gentleAnimation),
            child: child,
          ),
        );

      case PageTransitionType.rotate:
        return RotationTransition(
          turns: Tween<double>(begin: -0.1, end: 0.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: AnimationConstants.bounceGentle,
            ),
          ),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: AnimationConstants.defaultScale,
              end: 1.0,
            ).animate(curvedAnimation),
            child: FadeTransition(opacity: curvedAnimation, child: child),
          ),
        );

      case PageTransitionType.slideUpFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.3),
            end: Offset.zero,
          ).animate(gentleAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.7,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );

      case PageTransitionType.slideDownFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -0.3),
            end: Offset.zero,
          ).animate(gentleAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.7,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );

      case PageTransitionType.scaleRotate:
        return RotationTransition(
          turns: Tween<double>(begin: 0.1, end: 0.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: AnimationConstants.bounceGentle,
            ),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.7, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: AnimationConstants.bounceGentle,
              ),
            ),
            child: FadeTransition(opacity: curvedAnimation, child: child),
          ),
        );

      case PageTransitionType.depth:
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(
              Tween<double>(
                begin: 0.2,
                end: 0.0,
              ).animate(curvedAnimation).value,
            ),
          alignment: Alignment.center,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: AnimationConstants.defaultScale,
              end: 1.0,
            ).animate(curvedAnimation),
            child: FadeTransition(opacity: curvedAnimation, child: child),
          ),
        );

      case PageTransitionType.cube:
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(
              1,
              3,
              Tween<double>(
                begin: 50.0,
                end: 0.0,
              ).animate(curvedAnimation).value,
            )
            ..rotateX(
              Tween<double>(
                begin: 0.2,
                end: 0.0,
              ).animate(curvedAnimation).value,
            ),
          alignment: Alignment.center,
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );

      case PageTransitionType.flip:
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(
              Tween<double>(
                begin: -0.5,
                end: 0.0,
              ).animate(entranceAnimation).value,
            ),
          alignment: Alignment.center,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: AnimationConstants.defaultScale,
              end: 1.0,
            ).animate(curvedAnimation),
            child: FadeTransition(opacity: curvedAnimation, child: child),
          ),
        );
    }
  }
}

class UniquePageTransitionsBuilder extends PageTransitionsBuilder {
  const UniquePageTransitionsBuilder();

  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final routeName = route.settings.name ?? '';
    final transitionType = AdvancedPageTransitions.getTransitionType(routeName);

    return AdvancedPageTransitions._buildTransitionWidget(
      type: transitionType,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}
