class ScheduleModel {
  final int? idSchedule;
  final String nameSchedule;
  final String dateSchedule;
  final int statusSchedule;

  ScheduleModel({
    this.idSchedule,
    required this.nameSchedule,
    required this.dateSchedule,
    required this.statusSchedule,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      idSchedule: json['id_schedule'],
      nameSchedule: json['name_schedule'],
      dateSchedule: json['date_schedule'],
      statusSchedule: json['status_schedule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name_schedule': nameSchedule,
      'date_schedule': dateSchedule,
      'status_schedule': statusSchedule,
    };
  }
}
