import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherUtil {
  /// Directly launches an Amazon search page with the specified text query.
  /// Uses LaunchMode.externalApplication so it cleanly opens in the native Amazon app
  /// or external mobile browser, avoiding third-party webview bot checks and 403 Forbidden errors.
  static Future<void> launchAmazonSearch(BuildContext context, String searchQuery) async {
    final query = searchQuery.trim();
    if (query.isEmpty) return;

    final encodedQuery = Uri.encodeComponent(query);
    final amazonUrl = 'https://www.amazon.in/s?k=$encodedQuery';

    try {
      final uri = Uri.parse(amazonUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Amazon search for "$query": $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Launches an e-commerce URL or falls back to Amazon search.
  /// If the target URL contains known anti-bot / 403 blocking domains or fails to open,
  /// it automatically redirects to Amazon search with the product query.
  static Future<void> launchEcommerceUrl(
    BuildContext context,
    String urlOrQuery, {
    String? fallbackSearchQuery,
  }) async {
    String finalUrl = urlOrQuery.trim();

    // Check for empty or non-URL string -> redirect to Amazon search directly
    if (finalUrl.isEmpty) {
      if (fallbackSearchQuery != null && fallbackSearchQuery.isNotEmpty) {
        await launchAmazonSearch(context, fallbackSearchQuery);
      } else {
        await launchAmazonSearch(context, 'agricultural fertilizer and plant medicine');
      }
      return;
    }

    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      // It's a text query, search directly on Amazon
      await launchAmazonSearch(context, finalUrl);
      return;
    }

    // If the URL is already an Amazon link, launch with external application directly
    if (finalUrl.contains('amazon.in') || finalUrl.contains('amazon.com')) {
      try {
        final uri = Uri.parse(finalUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open Amazon link: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // For third-party URLs that may throw 403 Forbidden in in-app webviews,
    // launch in external system browser first
    try {
      final uri = Uri.parse(finalUrl);
      bool launched = false;
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (!launched) {
        // Fallback to Amazon search to prevent 403 blocking
        if (fallbackSearchQuery != null && fallbackSearchQuery.isNotEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Redirecting to Amazon search for "$fallbackSearchQuery"...'),
                backgroundColor: Colors.orange[800],
                duration: const Duration(seconds: 2),
              ),
            );
            await launchAmazonSearch(context, fallbackSearchQuery);
          }
        }
      }
    } catch (_) {
      // On any failure, gracefully fallback to Amazon search with prefilled query text
      if (!context.mounted) return;
      if (fallbackSearchQuery != null && fallbackSearchQuery.isNotEmpty) {
        await launchAmazonSearch(context, fallbackSearchQuery);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open store link: $finalUrl'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
