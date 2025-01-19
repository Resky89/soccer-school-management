class AspectModel {
  final int? id;
  final String nameAspect;

  AspectModel({
    this.id,
    required this.nameAspect,
  });

  factory AspectModel.fromJson(Map<String, dynamic> json) {
    return AspectModel(
      id: json['id_aspect'],
      nameAspect: json['name_aspect'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_aspect': id,
      'name_aspect': nameAspect,
    };
  }
}
