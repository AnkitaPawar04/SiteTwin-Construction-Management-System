import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AiBarcodeScanner(
      onDetect: (BarcodeCapture capture) {
        final String? scannedValue = capture.barcodes.firstOrNull?.rawValue;
        if (scannedValue != null && scannedValue.isNotEmpty) {
          Navigator.pop(context, scannedValue);
        }
      },
      controller: MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
      ),
    );
  }
}
