// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinic_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClinicModelAdapter extends TypeAdapter<ClinicModel> {
  @override
  final int typeId = 5;

  @override
  ClinicModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClinicModel(
      id: fields[0] as String,
      name: fields[1] as String,
      specialty: fields[2] as String,
      description: fields[3] as String?,
      imageUrl: fields[4] as String?,
      doctorName: fields[5] as String?,
      doctorPhone: fields[6] as String?,
      location: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ClinicModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.specialty)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.doctorName)
      ..writeByte(6)
      ..write(obj.doctorPhone)
      ..writeByte(7)
      ..write(obj.location);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
