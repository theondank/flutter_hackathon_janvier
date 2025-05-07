import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerErrorWidget extends StatelessWidget {
  const ScannerErrorWidget({super.key, required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    switch (error.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = 'Controller not ready.';
      case MobileScannerErrorCode.permissionDenied:
        errorMessage = 'Permission refusé';
      case MobileScannerErrorCode.unsupported:
        errorMessage = 'Le scanner n est pas supporté sur cet appareil';
      case MobileScannerErrorCode.vcard:
        errorMessage = 'Le code barre est une vCard non valide';
      default:
        errorMessage = 'Erreur inconnue';
    }

    return AlertDialog(
      title: const Text('Erreur'),
      content: Text(errorMessage),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
