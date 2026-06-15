import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

class ContactSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String value;

  const ContactSearchBar({
    super.key,
    required this.onChanged,
    this.value = '',
  });

  @override
  State<ContactSearchBar> createState() => _ContactSearchBarState();
}

class _ContactSearchBarState extends State<ContactSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: _isFocused ? AppColors.primary : AppColors.border,
            width: _isFocused ? 1.5 : 1,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: 'Search contacts...',
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: Icon(
                LucideIcons.search,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 42,
              minHeight: 0,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _controller.clear();
                      widget.onChanged('');
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        LucideIcons.x,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 0,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
