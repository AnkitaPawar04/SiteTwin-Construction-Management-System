// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceModelAdapter extends TypeAdapter<AttendanceModel> {
  @override
  final int typeId = 1;

  @override
  AttendanceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceModel(
      id: fields[0] as int?,
      userId: fields[1] as int,
      projectId: fields[2] as int,
      date: fields[3] as String,
      checkIn: fields[4] as String?,
      checkOut: fields[5] as String?,
      latitude: fields[6] as double,
      longitude: fields[7] as double,
      isVerified: fields[8] as bool,
      isSynced: fields[9] as bool,
      localId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.projectId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.checkIn)
      ..writeByte(5)
      ..write(obj.checkOut)
      ..writeByte(6)
      ..write(obj.latitude)
      ..writeByte(7)
      ..write(obj.longitude)
      ..writeByte(8)
      ..write(obj.isVerified)
      ..writeByte(9)
      ..write(obj.isSynced)
      ..writeByte(10)
      ..write(obj.localId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
