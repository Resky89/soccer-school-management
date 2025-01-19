class CoachModel {
  final int? idCoach;
  final String nameCoach;
  final String yearsCoach;
  final String email;
  final String nohp;
  final int statusCoach;
  final String? department;

  CoachModel({
    this.idCoach,
    required this.nameCoach,
    required this.yearsCoach,
    required this.email,
    required this.nohp,
    required this.statusCoach,
    this.department,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    return CoachModel(
      idCoach: json['id_coach'],
      nameCoach: json['name_coach'],
      yearsCoach: json['years_coach'],
      email: json['email'],
      nohp: json['nohp'],
      statusCoach: json['status_coach'],
      department: json['department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idCoach != null) 'id_coach': idCoach,
      'name_coach': nameCoach,
      'years_coach': yearsCoach,
      'email': email,
      'nohp': nohp,
      'status_coach': statusCoach,
      'department': department,
    };
  }
}
