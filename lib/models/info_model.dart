class InfoModel {
  final int? idInformation;
  final String nameInfo;
  final String dateInfo;
  final String? photo;
  final int statusInfo;
  final String info;

  InfoModel({
    this.idInformation,
    required this.nameInfo,
    required this.dateInfo,
    this.photo,
    required this.statusInfo,
    required this.info,
  });

  factory InfoModel.fromJson(Map<String, dynamic> json) {
    return InfoModel(
      idInformation: json['id_information'],
      nameInfo: json['name_info'],
      dateInfo: json['date_info'],
      photo: json['photo'],
      statusInfo: json['status_info'],
      info: json['info'],
    );
  }

  Map<String, String> toFormData() {
    return {
      if (idInformation != null) 'id_information': idInformation.toString(),
      'name_info': nameInfo,
      'date_info': dateInfo,
      'status_info': statusInfo.toString(),
      'info': info,
    };
  }
}
