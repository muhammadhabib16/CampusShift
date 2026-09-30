import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class EmptyView extends StatelessWidget {
  final String message;

  const EmptyView({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(message),
      leading: const Icon(Icons.error_outline),
      actions: [
        TextButton(
          onPressed: onRetry,
          child: const Text('Coba Lagi'),
        ),
      ],
    );
  }
}