import 'package:flutter/material.dart';

class ConnectionAlertDialog extends StatelessWidget {
  const ConnectionAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text('No Internet Connection'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Please check your internet connection...'),
        ],
      ),
    );
  }
}
