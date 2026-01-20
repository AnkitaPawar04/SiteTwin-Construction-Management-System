// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dpr_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DprModelAdapter extends TypeAdapter<DprModel> {
  @override
  final int typeId = 3;

  @override
  DprModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DprModel(
      id: fields[0] as int?,
      projectId: fields[1] as int,
      userId: fields[2] as int,
      workDescription: fields[3] as String,
      reportDate: fields[4] as String,
      latitude: fields[5] as double,
      longitude: fields[6] as double,
      status: fields[7] as String,
      photoUrls: (fields[8] as List).cast<String>(),
      localPhotoPaths: (fields[9] as List).cast<String>(),
      isSynced: fields[10] as bool,
      localId: fields[11] as String?,
      projectName: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DprModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.workDescription)
      ..writeByte(4)
      ..write(obj.reportDate)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.photoUrls)
      ..writeByte(9)
      ..write(obj.localPhotoPaths)
      ..writeByte(10)
      ..write(obj.isSynced)
      ..writeByte(11)
      ..write(obj.localId)
      ..writeByte(12)
      ..write(obj.projectName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DprModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
