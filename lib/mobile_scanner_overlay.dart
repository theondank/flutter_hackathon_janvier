import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_hackathon/scanned_barcode_label.dart';
import 'package:flutter_hackathon/scanner_button_widgets.dart';
import 'package:flutter_hackathon/scanner_error_widget.dart';
import 'package:flutter_hackathon/deputes_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> initializeDatabase() async {
  // Obtenez le chemin par défaut des bases de données sur l'appareil
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, 'hemicycle.db');

  // Ouvrez la base de données et créez la table si nécessaire
  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          deputy_name TEXT NOT NULL,
          entry_time TEXT NOT NULL
        )
      ''');
    },
  );
}

Future<void> insertEntry(String deputyName) async {
  // Initialisez la base de données
  final db = await initializeDatabase();

  // Obtenez l'heure actuelle au format ISO 8601
  final entryTime = DateTime.now().toIso8601String();

  // Insérez les données dans la table
  await db.insert(
    'entries',
    {
      'deputy_name': deputyName,
      'entry_time': entryTime,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Map<String, dynamic>>> getEntries() async {
  // Initialisez la base de données
  final db = await initializeDatabase();

  // Récupérez toutes les entrées de la table
  return await db.query('entries', orderBy: 'entry_time DESC');
}

Future<bool> verifyDeputyData(
    Map<String, String> vCardData, List<Map<String, String>> deputies) async {
  for (final deputy in deputies) {
    if (vCardData['Nom complet'] == '${deputy['Nom']} ${deputy['Prénom']}') {
      // Vous pouvez ajouter d'autres comparaisons ici (Email, Téléphone, etc.)
      return true;
    }
  }
  return false;
}

// Fonction pour analyser une vCard
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
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scanner with Overlay Example app'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: MobileScanner(
              fit: BoxFit.contain,
              controller: controller,
              scanWindow: scanWindow,
              errorBuilder: (context, error, child) {
                return ScannerErrorWidget(error: error);
              },
              onDetect: (capture) async {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  final String? rawValue = barcode.rawValue;
                  print('QR Code scanné: $rawValue');
                  if (isVCard(rawValue)) {
                    final vCardData = parseVCard(rawValue!);
                    print('Données vCard: $vCardData');
                    final deputies = await loadDeputesData();
                    print('Premier député dans la liste: ${deputies.first}');

                    // Vérifiez si le QR code correspond à un député
                    for (final depute in deputies) {
                      print('Comparaison:');
                      print('vCard nom: ${vCardData['Nom complet']}');
                      print('Député nom: ${depute['Nom']} ${depute['Prénom']}');

                      if (vCardData['Nom complet'] ==
                          '${depute['Nom']} ${depute['Prénom']}' || vCardData['Nom complet'] == '${depute['Prénom']} ${depute['Nom']}') {
                        print('Correspondance trouvée!');
                        await insertEntry('${depute['Nom']} ${depute['Prénom']}');
                        await controller.stop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DeputePage(depute: depute.values.toList()),
                          ),
                        );
                        return; // Arrête la méthode après une correspondance.
                      }
                    }

// Si aucune correspondance n'est trouvée
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Non trouvé'),
                        content: const Text(
                            'Les informations du QR code ne correspondent à aucun député.'),
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
                  } else {
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
                  ToggleFlashlightButton(controller: controller),
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
