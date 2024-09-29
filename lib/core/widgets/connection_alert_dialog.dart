import 'package:flutter/material.dart';
import 'package:trade_stream/core/consts.dart';

/// A dialog widget that displays a connection alert when there's no internet connectivity.
///
/// This widget creates an [AlertDialog] with a custom appearance to inform the user
/// about the lack of internet connection and shows a loading indicator.
class ConnectionAlertDialog extends StatelessWidget {
  /// Creates a [ConnectionAlertDialog].
  ///
  /// The [key] parameter is optional and can be used to provide a key for this widget.
  const ConnectionAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppMargins.margin16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // WiFi off icon container
          Container(
            width: AppMargins.margin80,
            height: AppMargins.margin80,
            decoration: BoxDecoration(
              color: AppColors.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.wifi_off_rounded,
                size: AppMargins.margin40,
                color: AppColors.accentColorLight,
              ),
            ),
          ),
          const SizedBox(height: AppMargins.margin08),
          // Connection check message
          const Text(
            'Please check your internet connection...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppMargins.margin20),
          // Loading indicator
          const SizedBox(
            width: AppMargins.margin40,
            height: AppMargins.margin40,
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.accentColorLight),
              strokeWidth: 3,
            ),
          ),
        ],
      ),
    );
  }
}
