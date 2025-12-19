import 'package:flutter/material.dart';

class DentalAppointmentModel {
  final String id;
  final String childId;
  final String purpose;
  final String doctorName;
  final DateTime appointmentDate;
  final DateTime? reminderDate;
  final bool isDone;
  final String? notes;
  final String parentId;

  DentalAppointmentModel({
    required this.id,
    required this.childId,
    required this.parentId,
    required this.purpose,
    required this.doctorName,
    required this.appointmentDate,
    this.reminderDate,
    this.isDone = false,
    this.notes,
  });

  TimeOfDay get time => TimeOfDay.fromDateTime(appointmentDate);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'purpose': purpose,
      'doctorName': doctorName,
      'appointmentDate': appointmentDate.toIso8601String(),
      'reminderDate': reminderDate?.toIso8601String(),
      'isDone': isDone,
      'notes': notes,
      'parentId': parentId,
    };
  }

  factory DentalAppointmentModel.fromMap(Map<String, dynamic> map) {
    return DentalAppointmentModel(
      id: map['id'] ?? '',
      childId: map['childId'] ?? '',
      purpose: map['purpose'] ?? '',
      doctorName: map['doctorName'] ?? '',
      appointmentDate: DateTime.parse(map['appointmentDate']),
      reminderDate: map['reminderDate'] != null ? DateTime.parse(map['reminderDate']) : null,
      isDone: map['isDone'] ?? false,
      notes: map['notes'],
      parentId: map['parentId'] ?? '',
    );
  }
}
