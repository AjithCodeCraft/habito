import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const CustomErrorWidget({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 48.0 : 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Connection Error',
      message: customMessage ?? 'Please check your internet connection and try again',
      onRetry: onRetry,
      icon: Icons.wifi_off,
    );
  }
}

class UnauthorizedErrorWidget extends StatelessWidget {
  final VoidCallback? onLogin;

  const UnauthorizedErrorWidget({
    super.key,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Authentication Required',
      message: 'Please log in to access this feature',
      onRetry: onLogin,
      icon: Icons.lock_outline,
    );
  }
}

class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? errorCode;

  const ServerErrorWidget({
    super.key,
    this.onRetry,
    this.errorCode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Server Error',
      message: errorCode != null
          ? 'Server error ($errorCode). Please try again later.'
          : 'Something went wrong on our end. Please try again later.',
      onRetry: onRetry,
      icon: Icons.dns,
    );
  }
}

class ValidationErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const ValidationErrorWidget({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: theme.colorScheme.onErrorContainer,
              ),
              iconSize: 20,
            ),
          ],
        ],
      ),
    );
  }
}

class InlineErrorWidget extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? padding;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}