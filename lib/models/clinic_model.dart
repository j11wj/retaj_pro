import 'package:hive/hive.dart';

part 'clinic_model.g.dart';

@HiveType(typeId: 5)
class ClinicModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String specialty; // نوع العيادة (أسنان، باطنية، جلدية، إلخ)

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String? imageUrl;

  @HiveField(5)
  final String? doctorName;

  @HiveField(6)
  final String? doctorPhone;

  @HiveField(7)
  final String? location; // موقع العيادة في المجمع

  ClinicModel({
    required this.id,
    required this.name,
    required this.specialty,
    this.description,
    this.imageUrl,
    this.doctorName,
    this.doctorPhone,
    this.location,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      doctorName: json['doctorName'],
      doctorPhone: json['doctorPhone'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'description': description,
      'imageUrl': imageUrl,
      'doctorName': doctorName,
      'doctorPhone': doctorPhone,
      'location': location,
    };
  }
}

