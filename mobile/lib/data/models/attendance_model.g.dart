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
      markedLatitude: fields[6] as double,
      markedLongitude: fields[7] as double,
      distanceFromGeofence: fields[8] as int?,
      isWithinGeofence: fields[9] as bool,
      isVerified: fields[10] as bool,
      isSynced: fields[11] as bool,
      localId: fields[12] as String?,
      userName: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceModel obj) {
    writer
      ..writeByte(14)
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
      ..write(obj.markedLatitude)
      ..writeByte(7)
      ..write(obj.markedLongitude)
      ..writeByte(8)
      ..write(obj.distanceFromGeofence)
      ..writeByte(9)
      ..write(obj.isWithinGeofence)
      ..writeByte(10)
      ..write(obj.isVerified)
      ..writeByte(11)
      ..write(obj.isSynced)
      ..writeByte(12)
      ..write(obj.localId)
      ..writeByte(13)
      ..write(obj.userName);
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
