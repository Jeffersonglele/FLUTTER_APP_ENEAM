class UserModel {
  final int id;
  final String nom;
  final String prenom;
  final int age;
  final String email;
  final String sexe;

  UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.age,
    required this.email,
    required this.sexe,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      nom: json["nom"],
      prenom: json["prenom"],
      age: json["age"],
      email: json["email"],
      sexe: json["sexe"],
    );
  }
}
