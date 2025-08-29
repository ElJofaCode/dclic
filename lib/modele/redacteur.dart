class Redacteur {
  int? id;
  String nom;
  String prenom;
  String email;

  Redacteur({this.id, required this.nom, required this.prenom, required this.email});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nom': nom,
      'prenom': prenom,
      'email': email,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Redacteur.fromMap(Map<String, dynamic> map) {
    return Redacteur(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['email'],
    );
  }
}
