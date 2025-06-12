class Law {
  final int numero;
  final String titre;
  final String texte;
  final String explication;
  final bool isFavorite;

  Law({
    required this.numero,
    required this.titre,
    required this.texte,
    required this.explication,
    this.isFavorite = false,
  });

  Law copyWith({bool? isFavorite}) {
    return Law(
      numero: numero,
      titre: titre,
      texte: texte,
      explication: explication,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  
}
