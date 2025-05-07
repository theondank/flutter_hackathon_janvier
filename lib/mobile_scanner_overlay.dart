import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_hackathon/scanned_barcode_label.dart';
import 'package:flutter_hackathon/scanner_button_widgets.dart';
import 'package:flutter_hackathon/scanner_error_widget.dart';
import 'package:flutter_hackathon/services/deputes_service.dart';
import 'package:flutter_hackathon/modele/deputes.dart';
import 'package:flutter_hackathon/app_bar.dart';

class BarcodeScannerWithOverlay extends StatefulWidget {
  const BarcodeScannerWithOverlay({super.key});

  @override
  _BarcodeScannerWithOverlayState createState() => _BarcodeScannerWithOverlayState();
}

class _BarcodeScannerWithOverlayState extends State<BarcodeScannerWithOverlay> {
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  List<Depute> _deputes = []; // Liste des députés
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeputesData();
  }

  Future<void> _loadDeputesData() async {
    try {
      final deputies = await DeputeService.fetchDeputes();
      setState(() {
        _deputes = deputies;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des députés : $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fonction pour vérifier si les données d'une vCard correspondent à un député
  bool verifyDeputyData(Map<String, String> vCardData, Depute depute) {
    String fullName1 = '${depute.NOM} ${depute.PRENOM}';
    String fullName2 = '${depute.PRENOM} ${depute.NOM}';
    return vCardData['Nom complet'] == fullName1 || vCardData['Nom complet'] == fullName2;
  }

  // Fonction pour analyser une vCard et extraire le nom/prénom
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
      appBar: const CustomAppBar(title: 'Scannez un QR code'),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Stack(
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

                        if (isVCard(rawValue)) {
                          final vCardData = parseVCard(rawValue!);

                          for (final depute in _deputes) {
                            if (verifyDeputyData(vCardData, depute)) {
                              await controller.stop();

                              // Navigation vers la page du député
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DeputePage(
                                    depute: depute,
                                    entries: [], // Peut être rempli si API d'historique disponible
                                  ),
                                ),
                              );
                              return;
                            }
                          }

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
                    if (!value.isInitialized || !value.isRunning || value.error != null) {
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
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndCorners(scanWindow, 
        topLeft: Radius.circular(borderRadius),
        topRight: Radius.circular(borderRadius),
        bottomLeft: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ));

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOver;

    final backgroundWithCutout = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(RRect.fromRectAndCorners(scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    ), borderPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow || borderRadius != oldDelegate.borderRadius;
  }
}

// Page à définir pour afficher les détails d'un député
class DeputePage extends StatelessWidget {
  final Depute depute;
  final List<dynamic> entries;

  const DeputePage({
    Key? key,
    required this.depute,
    required this.entries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '${depute.PRENOM} ${depute.NOM}'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${depute.PRENOM} ${depute.NOM}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8.0),
                    Text('Groupe: ${depute.GROUPE_POLITIQUE_COMPLET}'),
                    Text('Région: ${depute.REGION}'),
                    Text('Département: ${depute.DEPARTEMENT}'),
                    Text('Circonscription: ${depute.NUMERO_CIRCONSCRIPTION}'),
                    Text('Profession: ${depute.PROFESSION}'),
                  ],
                ),
              ),
            ),
            if (entries.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              Text(
                'Historique',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    title: Text(entry['title'] ?? ''),
                    subtitle: Text(entry['date'] ?? ''),
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}