class CoachTeamCategoryModel {
  final int? idCoachTeam;
  final int? idCoach;
  final int? idTeamCategory;
  final String nameCoach;
  final String nameTeamCategory;
  final int isActive;

  CoachTeamCategoryModel({
    this.idCoachTeam,
    this.idCoach,
    this.idTeamCategory,
    required this.nameCoach,
    required this.nameTeamCategory,
    required this.isActive,
  });

  factory CoachTeamCategoryModel.fromJson(Map<String, dynamic> json) {
    return CoachTeamCategoryModel(
      idCoachTeam: json['id_coach_team'],
      idCoach: json['id_coach'],
      idTeamCategory: json['id_team_category'],
      nameCoach: json['name_coach'],
      nameTeamCategory: json['name_team_category'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id_coach': idCoach,
        'id_team_category': idTeamCategory,
        'name_coach': nameCoach,
        'name_team_category': nameTeamCategory,
        'is_active': isActive,
      };
}
