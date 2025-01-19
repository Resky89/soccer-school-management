class AssessmentSettingModel {
  final int? idAssessmentSetting;
  final String yearAcademic;
  final String yearAssessment;
  final String nameCoach;
  final String nameAspect;
  final String nameAspectSub;
  final int bobot;

  AssessmentSettingModel({
    this.idAssessmentSetting,
    required this.yearAcademic,
    required this.yearAssessment,
    required this.nameCoach,
    required this.nameAspect,
    required this.nameAspectSub,
    required this.bobot,
  });

  factory AssessmentSettingModel.fromJson(Map<String, dynamic> json) {
    return AssessmentSettingModel(
      idAssessmentSetting: json['id_assessment_setting'],
      yearAcademic: json['year_academic']?.toString() ?? '',
      yearAssessment: json['year_assessment']?.toString() ?? '',
      nameCoach: json['coach']?.toString() ?? '',
      nameAspect: json['aspect']?.toString() ?? '',
      nameAspectSub: json['sub_aspect']?.toString() ?? '',
      bobot: int.tryParse(json['bobot']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year_academic': yearAcademic,
      'year_assessment': yearAssessment,
      'id_coach': int.parse(nameCoach),
      'name_aspect': nameAspect,
      'id_aspect_sub': int.parse(nameAspectSub),
      'bobot': bobot,
    };
  }
}

class AssessmentDetail {
  final int? id;
  final String coach;
  final String aspect;
  final String subAspect;
  final int bobot;

  AssessmentDetail({
    this.id,
    required this.coach,
    required this.aspect,
    required this.subAspect,
    required this.bobot,
  });

  factory AssessmentDetail.fromJson(Map<String, dynamic> json) {
    return AssessmentDetail(
      id: json['id_assessment_setting'],
      coach: json['coach']?.toString() ?? '',
      aspect: json['aspect']?.toString() ?? '',
      subAspect: json['sub_aspect']?.toString() ?? '',
      bobot: int.tryParse(json['bobot']?.toString() ?? '0') ?? 0,
    );
  }
}

class AssessmentSettingResponse {
  final String yearAcademic;
  final String yearAssessment;
  final List<AssessmentDetail> assessments;

  AssessmentSettingResponse({
    required this.yearAcademic,
    required this.yearAssessment,
    required this.assessments,
  });

  factory AssessmentSettingResponse.fromJson(Map<String, dynamic> json) {
    return AssessmentSettingResponse(
      yearAcademic: json['year_academic'],
      yearAssessment: json['year_assessment'],
      assessments: (json['assessments'] as List)
          .map((item) => AssessmentDetail.fromJson(item))
          .toList(),
    );
  }
}
