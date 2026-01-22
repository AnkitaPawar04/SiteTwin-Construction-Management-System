import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/localization/app_localizations.dart';
import 'package:mobile/providers/connectivity_provider.dart';

class ConnectionIndicator extends ConsumerWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);

    return connectivity.when(
      data: (statuses) {
        final status = statuses.isNotEmpty ? statuses.last : ConnectivityResult.none;
        final isOffline = status == ConnectivityResult.none;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 32,
          width: double.infinity,
          color: isOffline ? Colors.red.shade600 : Colors.green.shade600,
          child: Center(
            child: Text(
              isOffline
                  ? AppLocalizations.of(context).translate('offline')
                  : AppLocalizations.of(context).translate('online'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
      loading: () => SizedBox(
        height: 32,
        child: Center(
          child: Text(
            AppLocalizations.of(context).translate('checking_connection'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
