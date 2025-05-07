class Depute {
  final String IDENTIFIANT;
  final String PRENOM;
  final String NOM;
  final String REGION;
  final String DEPARTEMENT;
  final String NUMERO_CIRCONSCRIPTION;
  final String PROFESSION;
  final String GROUPE_POLITIQUE_COMPLET;
  final String GROUPE_POLITIQUE_ABREGE;

  Depute({
    required this.IDENTIFIANT,
    required this.PRENOM,
    required this.NOM,
    required this.REGION,
    required this.DEPARTEMENT,
    required this.NUMERO_CIRCONSCRIPTION,
    required this.PROFESSION,
    required this.GROUPE_POLITIQUE_COMPLET,
    required this.GROUPE_POLITIQUE_ABREGE,
  });

  factory Depute.fromJson(Map<String, dynamic> json) {
    return Depute(
      IDENTIFIANT: json['IDENTIFIANT']?.toString() ?? '',
      PRENOM: json['PRENOM'] ?? '',
      NOM: json['NOM'] ?? '',
      REGION: json['REGION'] ?? '',
      DEPARTEMENT: json['DEPARTEMENT'] ?? '',
      NUMERO_CIRCONSCRIPTION: json['NUMERO DE CIRCONSCRIPTION']?.toString() ?? '',
      PROFESSION: json['PROFESSION'] ?? '',
      GROUPE_POLITIQUE_COMPLET: json['GROUPE POLITIQUE (COMPLET)'] ?? '',
      GROUPE_POLITIQUE_ABREGE: json['GROUPE POLITIQUE (ABREGE)'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDENTIFIANT': IDENTIFIANT,
      'PRENOM': PRENOM,
      'NOM': NOM,
      'REGION': REGION,
      'DEPARTEMENT': DEPARTEMENT,
      'NUMERO DE CIRCONSCRIPTION': NUMERO_CIRCONSCRIPTION,
      'PROFESSION': PROFESSION,
      'GROUPE POLITIQUE (COMPLET)': GROUPE_POLITIQUE_COMPLET,
      'GROUPE POLITIQUE (ABREGE)': GROUPE_POLITIQUE_ABREGE,
    };
  }
}