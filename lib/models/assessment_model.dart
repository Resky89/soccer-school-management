class AssessmentModel {
  final String idAssessment;
  final String nameAspectSub;
  final String notes;
  final int point;
  final String dateAssessment;
  final String yearAcademic;
  final String yearAssessment;
  final int? regIdStudent;
  final String? idCoach;
  final String? idAspectSub;

  AssessmentModel({
    required this.idAssessment,
    required this.nameAspectSub,
    required this.notes,
    required this.point,
    required this.dateAssessment,
    required this.yearAcademic,
    required this.yearAssessment,
    this.regIdStudent,
    this.idCoach,
    this.idAspectSub,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      idAssessment: json['id_assessment']?.toString() ?? '',
      nameAspectSub: json['name_aspect_sub']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      point: int.tryParse(json['point']?.toString() ?? '0') ?? 0,
      dateAssessment: json['date_assessment']?.toString() ?? '',
      yearAcademic: json['year_academic']?.toString() ?? '',
      yearAssessment: json['year_assessment']?.toString() ?? '',
      regIdStudent: int.tryParse(json['reg_id_student']?.toString() ?? ''),
      idCoach: json['id_coach']?.toString(),
      idAspectSub: json['id_aspect_sub']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'id_assessment': idAssessment,
      'id_aspect_sub': idAspectSub ?? '',
      'ket': notes.isEmpty ? '-' : notes,
      'point': point,
      'date_assessment': dateAssessment,
      'year_academic': yearAcademic,
      'year_assessment': yearAssessment,
      'reg_id_student': regIdStudent?.toString() ?? '',
      'id_coach': idCoach ?? '',
    };
    print('Converting to JSON: $map');
    return map;
  }
}
