class ManagementModel {
  final int? idManagement;
  final String name;
  final String gender;
  final String dateBirth;
  final String email;
  final String nohp;
  final int idDepartement;
  final int status;
  final String? nameDepartement;

  ManagementModel({
    this.idManagement,
    required this.name,
    required this.gender,
    required this.dateBirth,
    required this.email,
    required this.nohp,
    required this.idDepartement,
    required this.status,
    this.nameDepartement,
  });

  factory ManagementModel.fromJson(Map<String, dynamic> json) {
    return ManagementModel(
      idManagement: json['id_management'],
      name: json['name'],
      gender: json['gender'],
      dateBirth: json['date_birth'].toString().split('T')[0],
      email: json['email'],
      nohp: json['nohp'],
      idDepartement: json['id_departement'],
      status: json['status'],
      nameDepartement: json['name_departement'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'date_birth': dateBirth,
      'email': email,
      'nohp': nohp,
      'id_departement': idDepartement,
      'status': status,
    };
  }
}

class DepartmentTotal {
  final String nameDepartement;
  final int totalEmployees;

  DepartmentTotal({
    required this.nameDepartement,
    required this.totalEmployees,
  });

  factory DepartmentTotal.fromJson(Map<String, dynamic> json) {
    return DepartmentTotal(
      nameDepartement: json['name_departement'] ?? 'Unknown',
      totalEmployees: json['total_employees'] ?? 0,
    );
  }
}
