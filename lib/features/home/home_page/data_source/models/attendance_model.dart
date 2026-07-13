import 'dart:convert';

class AttendanceModel {
  String? date;
  String? checkInTime;
  String? status;
  String? checkOutTime;
  String? totalTime;
  String? name;
  String? email;
  bool? takeBreak;
  String? delay;

  AttendanceModel({
    this.date,
    this.checkInTime,
    this.status,
    this.checkOutTime,
    this.totalTime,
    this.takeBreak,
    this.name,
    this.email,
    this.delay,
  });

  factory AttendanceModel.fromMap(Map data) {
    return AttendanceModel(
      date: data['Date'],
      checkInTime: data['Check_In_Time'],
      status: data['Status'],
      checkOutTime: data['Check_Out_Time'],
      totalTime: data['Total_Time'],
      takeBreak: data['Take_Break'],
      name: data['Name'],
      email: data['Email'],
      delay: data['Delay'],
    );
  }

  Map<String, dynamic> toMap() => {
        'Date': date,
        'Check_In_Time': checkInTime,
        'Status': status,
        'Check_Out_Time': checkOutTime,
        'Total_Time': totalTime,
        'Take_Break': takeBreak,
        'Name': name,
        'Email': email,
        'Delay': delay,
      };

  String toJson() => json.encode(toMap());
}
