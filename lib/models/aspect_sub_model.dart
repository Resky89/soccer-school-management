class AspectSubModel {
  final int? idAspectSub;
  final int idAspect;
  final String nameAspectSub;
  final String ketAspectSub;
  final String nameAspect;

  AspectSubModel({
    this.idAspectSub,
    required this.idAspect,
    required this.nameAspectSub,
    required this.ketAspectSub,
    required this.nameAspect,
  });

  factory AspectSubModel.fromJson(Map<String, dynamic> json) {
    return AspectSubModel(
      idAspectSub: json['id_aspect_sub'],
      idAspect: json['id_aspect'],
      nameAspectSub: json['name_aspect_sub'],
      ketAspectSub: json['ket_aspect_sub'],
      nameAspect: json['name_aspect'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_aspect_sub': idAspectSub,
      'id_aspect': idAspect,
      'name_aspect_sub': nameAspectSub,
      'ket_aspect_sub': ketAspectSub,
    };
  }
}
