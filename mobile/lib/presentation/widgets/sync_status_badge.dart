import 'package:flutter/material.dart';

class SyncStatusBadge extends StatelessWidget {
  final bool isSynced;
  final bool isSmall;

  const SyncStatusBadge({
    super.key,
    required this.isSynced,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSynced) {
      return isSmall 
          ? Icon(
              Icons.cloud_done,
              size: 16,
              color: Colors.green.shade600,
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_done,
                    size: 14,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Synced',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
    } else {
      return isSmall
          ? Icon(
              Icons.cloud_off,
              size: 16,
              color: Colors.orange.shade600,
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 14,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Pending Sync',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
    }
  }
}
