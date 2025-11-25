import 'package:flutter/material.dart';
import '../widgets/social_links_modal.dart';

/// Helper functions for handling help-related UI actions
class HelpUtils {
  HelpUtils._();

  /// Shows the social links modal for help/support
  static Future<void> showSocialLinksModal(BuildContext context) async {
    return await SocialLinksModal.show(context);
  }
}
