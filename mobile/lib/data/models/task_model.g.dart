// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 2;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as int?,
      projectId: fields[1] as int,
      assignedTo: fields[2] as int,
      assignedBy: fields[3] as int,
      title: fields[4] as String,
      description: fields[5] as String,
      status: fields[6] as String,
      isSynced: fields[7] as bool,
      localId: fields[8] as String?,
      projectName: fields[9] as String?,
      assignedByName: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.assignedTo)
      ..writeByte(3)
      ..write(obj.assignedBy)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.isSynced)
      ..writeByte(8)
      ..write(obj.localId)
      ..writeByte(9)
      ..write(obj.projectName)
      ..writeByte(10)
      ..write(obj.assignedByName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
