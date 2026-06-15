import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

class ModernInput extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData? icon;
  final String? value;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool multiline;
  final int maxLines;
  final bool useMono;
  final bool enabled;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;

  const ModernInput({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.value,
    this.onChanged,
    this.keyboardType,
    this.multiline = false,
    this.maxLines = 1,
    this.useMono = false,
    this.enabled = true,
    this.obscureText = false,
    this.validator,
    this.controller,
  });

  @override
  State<ModernInput> createState() => _ModernInputState();
}

class _ModernInputState extends State<ModernInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.value ?? '');
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(ModernInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null &&
        widget.value != null &&
        widget.value != _controller.text) {
      _controller.text = widget.value!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.useMono
        ? AppTypography.mono.copyWith(color: AppColors.textPrimary)
        : AppTypography.bodyLarge.copyWith(
            fontSize: 15,
            color: AppColors.textPrimary,
          );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: _isFocused ? AppColors.primary : AppColors.border,
          width: _isFocused ? 1.5 : 1,
        ),
      ),
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        enabled: widget.enabled,
        obscureText: widget.obscureText,
        validator: widget.validator,
        keyboardType: widget.multiline
            ? TextInputType.multiline
            : widget.keyboardType,
        maxLines: widget.multiline ? widget.maxLines : 1,
        style: textStyle,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: _isFocused ? AppColors.primary : AppColors.textSecondary,
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          floatingLabelStyle: AppTypography.labelSmall.copyWith(
            color: _isFocused ? AppColors.primary : AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
          prefixIcon: widget.icon != null
              ? Icon(
                  widget.icon,
                  size: 16,
                  color: AppColors.primary,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: widget.icon != null ? AppSpacing.xxs : AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }
}
