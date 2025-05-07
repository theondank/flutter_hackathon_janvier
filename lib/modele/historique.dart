import 'package:flutter_hackathon/modele/deputes.dart';

class Historique {
  final int identifiant;
  final String scanDate;
  final int deputeId;
  final Depute? depute; // Objet de type Depute lié à cet historique

  Historique({
    required this.identifiant,
    required this.scanDate,
    required this.deputeId,
    this.depute,
  });

  factory Historique.fromJson(Map<String, dynamic> json) {
    return Historique(
      identifiant: json['IDENTIFIANT'],
      scanDate: json['scan_date'],
      deputeId: json['depute_id'],
      depute: json['depute'] != null ? Depute.fromJson(json['depute']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDENTIFIANT': identifiant,
      'scan_date': scanDate,
      'depute_id': deputeId,
      if (depute != null) 'depute': depute!.toJson(),
    };
  }
}
