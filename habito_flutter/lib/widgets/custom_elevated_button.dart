import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final Size? minimumSize;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.minimumSize,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: minimumSize ?? const Size(double.infinity, 48),
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
        elevation: elevation ?? 2,
        shadowColor: theme.colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  foregroundColor ?? theme.colorScheme.onPrimary,
                ),
              ),
            )
          : child,
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final Size? minimumSize;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;

  const CustomOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.minimumSize,
    this.padding,
    this.borderColor,
    this.foregroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: minimumSize ?? const Size(double.infinity, 48),
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        foregroundColor: foregroundColor ?? theme.colorScheme.primary,
        side: BorderSide(
          color: borderColor ?? theme.colorScheme.primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  foregroundColor ?? theme.colorScheme.primary,
                ),
              ),
            )
          : child,
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final Color? foregroundColor;

  const CustomTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.padding,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        foregroundColor: foregroundColor ?? theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  foregroundColor ?? theme.colorScheme.primary,
                ),
              ),
            )
          : child,
    );
  }
}