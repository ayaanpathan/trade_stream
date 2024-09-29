import 'package:flutter/material.dart';
import 'package:trade_stream/core/consts.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

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
