import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../animations/animations.dart';
import '../utils/modal_debug_utils.dart';

/// Enhanced modal system that ensures proper stacking and visibility
class AnimatedModalBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? height,
    bool useRootNavigator = true,
    bool dismissible = true,
  }) {
    try {
      // Debug: Log modal creation
      debugPrint(
        'AnimatedModalBottomSheet: Creating modal with height: $height',
      );

      // Validate context before proceeding
      if (!ModalDebugUtils.isContextValid(context)) {
        ModalDebugUtils.logError('Invalid context for modal creation');
        return Future.value(null);
      }

      // Check if we're already in a modal context
      final navigator = Navigator.maybeOf(context, rootNavigator: true);
      if (navigator == null) {
        ModalDebugUtils.logError('No root navigator available');
        return Future.value(null);
      }

      // Always use root navigator to escape shell route stacking contexts
      final rootNavigator = Navigator.of(context, rootNavigator: true);

      return rootNavigator.push<T>(
        _FullScreenModalRoute<T>(
          child: _RootLevelModalWrapper<T>(
            backgroundColor: backgroundColor,
            height: height,
            enableDrag: enableDrag,
            dismissible: dismissible,
            child: child,
          ),
        ),
      );
    } catch (e, stackTrace) {
      ModalDebugUtils.logError('Failed to create modal: $e', stackTrace);
      return Future.value(null);
    }
  }
}

/// Full-screen modal route that ensures proper stacking above all UI elements
class _FullScreenModalRoute<T> extends PopupRoute<T> {
  final Widget child;

  _FullScreenModalRoute({required this.child});

  @override
  Color? get barrierColor => Colors.black.withValues(alpha: 0.5);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss modal';

  @override
  Duration get transitionDuration => AnimationConstants.medium;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    debugPrint('_FullScreenModalRoute: Building page');
    try {
      return child;
    } catch (e, stackTrace) {
      ModalDebugUtils.logError('Error building modal page: $e', stackTrace);
      return Container(); // Fallback empty container
    }
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    debugPrint('_FullScreenModalRoute: Building transitions');
    try {
      return FadeTransition(opacity: animation, child: child);
    } catch (e, stackTrace) {
      ModalDebugUtils.logError(
        'Error building modal transitions: $e',
        stackTrace,
      );
      return child; // Return child without transition as fallback
    }
  }
}

/// Root-level modal wrapper that handles positioning, animations, and accessibility
class _RootLevelModalWrapper<T> extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? height;
  final bool enableDrag;
  final bool dismissible;

  const _RootLevelModalWrapper({
    required this.child,
    this.backgroundColor,
    this.height,
    this.enableDrag = true,
    this.dismissible = true,
  });

  @override
  State<_RootLevelModalWrapper<T>> createState() =>
      _RootLevelModalWrapperState<T>();
}

class _RootLevelModalWrapperState<T> extends State<_RootLevelModalWrapper<T>>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late FocusNode _focusNode;

  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    debugPrint('_RootLevelModalWrapper: Initializing modal');

    try {
      // Initialize focus for accessibility
      _focusNode = FocusNode();
      debugPrint('_RootLevelModalWrapper: FocusNode created');

      // Setup animations
      _slideController = AnimationController(
        duration: AnimationConstants.medium,
        vsync: this,
      );
      debugPrint('_RootLevelModalWrapper: SlideController created');

      _fadeController = AnimationController(
        duration: AnimationConstants.fast,
        vsync: this,
      );
      debugPrint('_RootLevelModalWrapper: FadeController created');

      _slideAnimation =
          Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutCubic,
            ),
          );
      debugPrint('_RootLevelModalWrapper: SlideAnimation created');

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
      );
      debugPrint('_RootLevelModalWrapper: FadeAnimation created');

      _isInitialized = true;

      // Start animations
      _fadeController.forward();
      _slideController.forward();
      debugPrint('_RootLevelModalWrapper: Animations started');

      // Focus the modal for accessibility
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          _focusNode.requestFocus();
          debugPrint('_RootLevelModalWrapper: Modal focused and visible');
        }
      });
    } catch (e, stackTrace) {
      ModalDebugUtils.logError('Failed to initialize modal: $e', stackTrace);
      // Try to clean up on error
      _disposeControllers();
    }
  }

  @override
  void dispose() {
    debugPrint('_RootLevelModalWrapper: Disposing modal');
    _isDisposed = true;
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    try {
      if (_isInitialized) {
        _slideController.dispose();
        debugPrint('_RootLevelModalWrapper: SlideController disposed');
      }
    } catch (e) {
      debugPrint('_RootLevelModalWrapper: Error disposing slideController: $e');
    }

    try {
      if (_isInitialized) {
        _fadeController.dispose();
        debugPrint('_RootLevelModalWrapper: FadeController disposed');
      }
    } catch (e) {
      debugPrint('_RootLevelModalWrapper: Error disposing fadeController: $e');
    }

    try {
      _focusNode.dispose();
      debugPrint('_RootLevelModalWrapper: FocusNode disposed');
    } catch (e) {
      debugPrint('_RootLevelModalWrapper: Error disposing focusNode: $e');
    }
  }

  void _dismiss() {
    if (!widget.dismissible || _isDisposed || !_isInitialized) {
      debugPrint(
        '_RootLevelModalWrapper: Dismiss blocked - dismissible: ${widget.dismissible}, disposed: $_isDisposed, initialized: $_isInitialized',
      );
      return;
    }

    debugPrint('_RootLevelModalWrapper: Dismissing modal');
    try {
      _slideController
          .reverse()
          .then((_) {
            if (mounted && !_isDisposed) {
              debugPrint(
                '_RootLevelModalWrapper: Modal animation completed, popping',
              );
              Navigator.of(context).pop();
            } else {
              debugPrint(
                '_RootLevelModalWrapper: Widget not mounted or disposed, skipping pop',
              );
            }
          })
          .catchError((error) {
            ModalDebugUtils.logError(
              'Error during modal dismissal animation: $error',
            );
            // Force pop if animation fails
            if (mounted && !_isDisposed) {
              Navigator.of(context).pop();
            }
          });
    } catch (e, stackTrace) {
      ModalDebugUtils.logError('Failed to dismiss modal: $e', stackTrace);
      // Force pop as fallback
      try {
        if (mounted && !_isDisposed) {
          Navigator.of(context).pop();
        }
      } catch (fallbackError) {
        ModalDebugUtils.logError('Fallback pop also failed: $fallbackError');
      }
    }
  }

  @override
  void didUpdateWidget(_RootLevelModalWrapper<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_isDisposed) {
      debugPrint('_RootLevelModalWrapper: Widget disposed, skipping update');
      return;
    }

    debugPrint('_RootLevelModalWrapper: Widget updated');

    // Handle widget updates if needed
    if (oldWidget.dismissible != widget.dismissible) {
      debugPrint(
        '_RootLevelModalWrapper: Dismissible changed to ${widget.dismissible}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('_RootLevelModalWrapper: Building modal');

    if (_isDisposed) {
      debugPrint(
        '_RootLevelModalWrapper: Widget is disposed, returning empty container',
      );
      return Container();
    }

    try {
      final screenHeight = MediaQuery.of(context).size.height;
      final modalHeight = widget.height ?? (screenHeight * 0.6);

      debugPrint(
        '_RootLevelModalWrapper: Screen height: $screenHeight, Modal height: $modalHeight',
      );

      return KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          // Handle ESC key to close modal
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape &&
              widget.dismissible &&
              !_isDisposed) {
            debugPrint('_RootLevelModalWrapper: ESC key pressed, dismissing');
            _dismiss();
          }
        },
        child: PopScope(
          canPop: widget.dismissible,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && widget.dismissible && !_isDisposed) {
              debugPrint(
                '_RootLevelModalWrapper: Back button pressed, dismissing',
              );
              _dismiss();
            }
          },
          child: Focus(
            focusNode: _focusNode,
            child: Semantics(
              label: 'Modal dialog',
              child: Material(
                type: MaterialType.transparency,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _slideAnimation,
                    _fadeAnimation,
                  ]),
                  builder: (context, child) {
                    if (_isDisposed) {
                      return Container();
                    }

                    try {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: GestureDetector(
                          onTap: widget.dismissible && !_isDisposed
                              ? _dismiss
                              : null,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            // Full screen overlay to ensure no UI leaks through
                            color: Colors.transparent,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap:
                                      () {}, // Prevent tap-through to background
                                  child: SlideTransition(
                                    position: _slideAnimation,
                                    child: Container(
                                      width: double.infinity,
                                      constraints: BoxConstraints(
                                        maxHeight: modalHeight,
                                        minHeight: 200.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            widget.backgroundColor ??
                                            Colors.transparent,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(24.r),
                                          topRight: Radius.circular(24.r),
                                        ),
                                      ),
                                      child: widget.child,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } catch (e, stackTrace) {
                      ModalDebugUtils.logError(
                        'Error building modal UI: $e',
                        stackTrace,
                      );
                      return Container(); // Return empty container as fallback
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      ModalDebugUtils.logError('Critical error building modal: $e', stackTrace);
      return Container(); // Return empty container as fallback
    }
  }
}

class AnimatedDialog extends StatefulWidget {
  final Widget child;
  final bool barrierDismissible;
  final Color? barrierColor;

  const AnimatedDialog({
    super.key,
    this.barrierDismissible = true,
    this.barrierColor,
    required this.child,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      builder: (context) => AnimatedDialog(
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        child: child,
      ),
    );
  }

  @override
  State<AnimatedDialog> createState() => _AnimatedDialogState();
}

class _AnimatedDialogState extends State<AnimatedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationConstants.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationConstants.elasticCurve,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationConstants.defaultCurve,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: _AnimatedSnackBarContent(
          message: message,
          type: type,
          onTap: onTap,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
      ),
    );
  }
}

class _AnimatedSnackBarContent extends StatefulWidget {
  final String message;
  final SnackBarType type;
  final VoidCallback? onTap;

  const _AnimatedSnackBarContent({
    required this.message,
    required this.type,
    this.onTap,
  });

  @override
  State<_AnimatedSnackBarContent> createState() =>
      _AnimatedSnackBarContentState();
}

class _AnimatedSnackBarContentState extends State<_AnimatedSnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationConstants.medium,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationConstants.elasticCurve,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case SnackBarType.success:
        return Colors.green;
      case SnackBarType.error:
        return Colors.red;
      case SnackBarType.warning:
        return Colors.orange;
      case SnackBarType.info:
        return Colors.blue;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: _getBackgroundColor().withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(_getIcon(), color: Colors.white, size: 20.w),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

enum SnackBarType { success, error, warning, info }
