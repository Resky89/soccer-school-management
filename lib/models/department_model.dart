class DepartmentModel {
  final int? id;
  final String nameDepartement;
  final int status;

  DepartmentModel({
    this.id,
    required this.nameDepartement,
    required this.status,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id_departement'],
      nameDepartement: json['name_departement'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name_departement': nameDepartement,
      'status': status,
    };
  }
} 