import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_hackathon/scanned_barcode_label.dart';
import 'package:flutter_hackathon/scanner_button_widgets.dart';
import 'package:flutter_hackathon/scanner_error_widget.dart';
import 'package:flutter_hackathon/deputes_page.dart';
import 'package:flutter_hackathon/database_helpers.dart';
import 'package:flutter_hackathon/app_bar.dart';

// Instance du gestionnaire de base de données
final dbHelper = DatabaseHelper();

// Fonction pour vérifier si les données d'une vCard correspondent à un député
bool verifyDeputyData(Map<String, String> vCardData, Map<String, String> depute) {
  String fullName1 = '${depute['Nom']} ${depute['Prénom']}';
  String fullName2 = '${depute['Prénom']} ${depute['Nom']}';
  return vCardData['Nom complet'] == fullName1 || vCardData['Nom complet'] == fullName2;
}

// Fonction pour analyser une vCard et extraire le nom/prenom
Map<String, String> parseVCard(String vCard) {
  final lines = vCard.split('\n');
  final data = <String, String>{};

  for (final line in lines) {
    if (line.startsWith('FN:')) {
      data['Nom complet'] = line.substring(3).trim();
    }
  }

  return data;
}

class BarcodeScannerWithOverlay extends StatefulWidget {
  const BarcodeScannerWithOverlay({super.key});

  @override
  _BarcodeScannerWithOverlayState createState() =>
      _BarcodeScannerWithOverlayState();
}

class _BarcodeScannerWithOverlayState extends State<BarcodeScannerWithOverlay> {
  // Contrôleur du scanner mobile, configuré pour lire uniquement les QR codes
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  // Vérifie si le QR code contient une vCard valide
  bool isVCard(String? rawValue) {
    return rawValue != null &&
        rawValue.startsWith('BEGIN:VCARD') &&
        rawValue.contains('END:VCARD');
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: 200,
      height: 200,
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 58, 57, 57),
      appBar: const CustomAppBar(title: 'Scannnez un QR code'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: MobileScanner(
              fit: BoxFit.contain,
              controller: controller,
              scanWindow: scanWindow,
              // Affiche un widget personnalisé en cas d'erreur de scanner
              errorBuilder: (context, error, child) {
                return ScannerErrorWidget(error: error);
              },
              onDetect: (capture) async {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final String? rawValue = barcode.rawValue;

                  if (isVCard(rawValue)) {
                    // Charge les données du QR code de type vCard
                    final vCardData = parseVCard(rawValue!);
                    
                    // Charge les données des députés
                    final deputies = await loadDeputesData();

                    // Vérifie si les données du QR code correspondent à un député
                    for (final depute in deputies) {
                      String nomComplet = '${depute['Nom']} ${depute['Prénom']}';
                      if (verifyDeputyData(vCardData, depute)) {
                        // Insère une entrée dans la base de données
                        await dbHelper.insertEntry(nomComplet);
                        await controller.stop();

                        // Récupère les entrées associées au député
                        List<Map<String, dynamic>> entries = await dbHelper.getEntriesForDepute(nomComplet);

                        // Navigue vers la page des détails du député
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DeputePage(depute: depute, entries: entries),
                          ),
                        );
                        return; // Arrête la méthode après une correspondance.
                      }
                    }

                    // Affiche un pop-up d'erreur si aucune correspondance n'est trouvée
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Non trouvé'),
                        content: const Text(
                            'Les informations du QR code ne correspondent à aucun député.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              controller.stop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Affiche un pop-up d'erreur pour les QR codes non pris en charge
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Erreur'),
                        content: const Text(
                            'Le QR code scanné n\'est pas pris en charge, veuillez réessayer.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              // Ajoute un label pour les codes-barres détectés
              overlayBuilder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ScannedBarcodeLabel(barcodes: controller.barcodes),
                  ),
                );
              },
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              if (!value.isInitialized ||
                  !value.isRunning ||
                  value.error != null) {
                return const SizedBox();
              }

              // Affiche un overlay de scan autour de la fenêtre définie
              return CustomPaint(
                painter: ScannerOverlay(scanWindow: scanWindow),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Bouton pour activer/désactiver la lampe torche
                  ToggleFlashlightButton(controller: controller),
                  // Bouton pour changer de caméra
                  SwitchCameraButton(controller: controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await controller.dispose();
  }
}


class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 12.0,
  });

  final Rect scanWindow;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOver;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}
