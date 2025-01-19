class UserModel {
  final String name;
  final String email;
  final String nohp;
  final int status;
  final String nameDepartement;
  final String dateBirth;
  final String gender;

  UserModel({
    required this.name,
    required this.email,
    required this.nohp,
    required this.status,
    required this.nameDepartement,
    required this.dateBirth,
    required this.gender,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      nohp: json['nohp'] ?? '',
      status: json['status'] ?? 0,
      nameDepartement: json['name_departement'] ?? '',
      dateBirth: json['date_birth'] ?? '',
      gender: json['gender'] ?? '',
    );
  }
}
