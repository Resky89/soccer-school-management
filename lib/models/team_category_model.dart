class TeamCategoryModel {
  final int? idTeamCategory;
  final String nameTeamCategory;
  final String status;

  TeamCategoryModel({
    this.idTeamCategory,
    required this.nameTeamCategory,
    required this.status,
  });

  factory TeamCategoryModel.fromJson(Map<String, dynamic> json) {
    return TeamCategoryModel(
      idTeamCategory: json['id_team_category'],
      nameTeamCategory: json['name_team_category'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name_team_category': nameTeamCategory,
      'status': status,
    };
  }
}
