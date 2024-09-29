import 'package:flutter/material.dart';
import 'package:trade_stream/core/consts.dart';

/// A custom search bar widget for the home screen.
///
/// This widget provides a search input field with a search icon and customized styling.
/// It is designed to be used for searching trading symbols or instruments.
class HomeSearchBar extends StatelessWidget {
  /// The controller for the search input field.
  final TextEditingController controller;

  /// Callback function triggered when the search input changes.
  final ValueChanged<String> onChanged;

  /// Creates a [HomeSearchBar].
  ///
  /// The [controller] and [onChanged] parameters are required.
  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppMargins.margin04),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search symbols..',
          hintStyle: TextStyle(color: AppColors.textPrimary.withOpacity(0.5)),
          prefixIcon:
              Icon(Icons.search, color: AppColors.textPrimary.withOpacity(0.5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppMargins.margin28),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.secondaryBackground,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
