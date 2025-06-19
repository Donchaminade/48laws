class Law {
  final int numero;
  final String titre;
  final String texte;
  final String explication;
  final bool isFavorite; // Ajout de cette ligne

  Law({
    required this.numero,
    required this.titre,
    required this.texte,
    required this.explication,
    this.isFavorite = false, // Initialise à false par défaut
  });

  Law copyWith({
    int? numero,
    String? titre,
    String? texte,
    String? explication,
    bool? isFavorite, // Ajout de cette ligne
  }) {
    return Law(
      numero: numero ?? this.numero,
      titre: titre ?? this.titre,
      texte: texte ?? this.texte,
      explication: explication ?? this.explication,
      isFavorite: isFavorite ?? this.isFavorite, // Utilise la nouvelle propriété
    );
  }
}