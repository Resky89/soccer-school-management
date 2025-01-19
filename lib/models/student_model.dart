class StudentModel {
  final int? regIdStudent;
  final String? idStudent;
  final String name;
  final String dateBirth;
  final String gender;
  final String? photo;
  final String email;
  final String nohp;
  final String? position;
  final String? dominantFoot;
  final int? heightCm;
  final int? weightKg;
  final String? shirtNumber;
  final int? idTeamCategory;
  String? teamCategoryName; // Tambahkan field ini
  final int status;
  final String? registrationDate;

  StudentModel({
    this.regIdStudent,
    this.idStudent,
    required this.name,
    required this.dateBirth,
    required this.gender,
    this.photo,
    required this.email,
    required this.nohp,
    this.position,
    this.dominantFoot,
    this.heightCm,
    this.weightKg,
    this.shirtNumber,
    this.idTeamCategory,
    this.teamCategoryName,
    required this.status,
    this.registrationDate,
  });

  StudentModel copyWith({
    int? regIdStudent,
    String? idStudent,
    String? name,
    String? dateBirth,
    String? gender,
    String? photo,
    String? email,
    String? nohp,
    String? position,
    String? dominantFoot,
    int? heightCm,
    int? weightKg,
    String? shirtNumber,
    int? idTeamCategory,
    String? teamCategoryName,
    int? status,
    String? registrationDate,
  }) {
    return StudentModel(
      regIdStudent: regIdStudent ?? this.regIdStudent,
      idStudent: idStudent ?? this.idStudent,
      name: name ?? this.name,
      dateBirth: dateBirth ?? this.dateBirth,
      gender: gender ?? this.gender,
      photo: photo ?? this.photo,
      email: email ?? this.email,
      nohp: nohp ?? this.nohp,
      position: position ?? this.position,
      dominantFoot: dominantFoot ?? this.dominantFoot,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      shirtNumber: shirtNumber ?? this.shirtNumber,
      idTeamCategory: idTeamCategory ?? this.idTeamCategory,
      teamCategoryName: teamCategoryName ?? this.teamCategoryName,
      status: status ?? this.status,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      regIdStudent: json['reg_id_student'],
      idStudent: json['id_student'],
      name: json['name'] ?? '',
      dateBirth: json['date_birth'] ?? '',
      gender: json['gender'] ?? '',
      photo: json['photo'],
      email: json['email'] ?? '',
      nohp: json['nohp'] ?? '',
      position: json['position'],
      dominantFoot: json['dominant_foot'],
      heightCm: json['height_cm'],
      weightKg: json['weight_kg'],
      shirtNumber: json['shirt_number']?.toString(),
      idTeamCategory: json['id_team_category'],
      teamCategoryName: json['team_category_name'],
      status: json['status'] ?? 0,
      registrationDate: json['registration_date'],
    );
  }

  Map<String, String> toFormData() {
    return {
      if (idStudent != null) 'id_student': idStudent!,
      'name': name,
      'date_birth': dateBirth,
      'gender': gender,
      if (photo != null && photo!.isNotEmpty) 'photo': photo!,
      'email': email,
      'nohp': nohp,
      if (position != null) 'position': position!,
      if (dominantFoot != null) 'dominant_foot': dominantFoot!,
      if (heightCm != null) 'height_cm': heightCm.toString(),
      if (weightKg != null) 'weight_kg': weightKg.toString(),
      if (shirtNumber != null) 'shirt_number': shirtNumber!,
      if (idTeamCategory != null) 'id_team_category': idTeamCategory.toString(),
      'status': status.toString(),
    };
  }
}

// Add this new class to handle the team category totals
class TeamCategoryTotal {
  final String nameTeamCategory;
  final int totalActivePlayers;

  TeamCategoryTotal({
    required this.nameTeamCategory,
    required this.totalActivePlayers,
  });

  factory TeamCategoryTotal.fromJson(Map<String, dynamic> json) {
    return TeamCategoryTotal(
      nameTeamCategory: json['name_team_category'],
      totalActivePlayers: json['total_active_players'],
    );
  }
}
