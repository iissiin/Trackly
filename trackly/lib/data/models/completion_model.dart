import 'package:cloud_firestore/cloud_firestore.dart';

/// Модель отметки о выполнении трекера.
class CompletionModel {
  final String id;
  final String trackerId;
  final String userId;
  final DateTime date;

  const CompletionModel({
    required this.id,
    required this.trackerId,
    required this.userId,
    required this.date,
  });

  factory CompletionModel.fromJson(Map<String, dynamic> json, String id) {
    return CompletionModel(
      id: id,
      trackerId: json['trackerId'] as String,
      userId: json['userId'] as String,
      date: (json['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'trackerId': trackerId,
    'userId': userId,
    'date': Timestamp.fromDate(date),
  };
}
