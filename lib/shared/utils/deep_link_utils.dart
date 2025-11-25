import 'package:url_launcher/url_launcher.dart';

class DeepLinkUtils {
  static Future<bool> openDeepLink(String? link) async {
    if (link == null || link.isEmpty) {
      return false;
    }

    try {
      // Ensure external URLs have proper scheme
      String url = link;
      if (!link.startsWith('http://') && !link.startsWith('https://')) {
        url = 'https://$link';
      }

      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
        return true;
      }
    } catch (e) {
      try {
        // Fallback: try with https:// prefix if not already present
        String fallbackUrl = link;
        if (!link.startsWith('http://') && !link.startsWith('https://')) {
          fallbackUrl = 'https://$link';
        }
        await launchUrl(
          Uri.parse(fallbackUrl),
          mode: LaunchMode.platformDefault,
        );
        return true;
      } catch (e) {
        return false;
      }
    }
  }
}
