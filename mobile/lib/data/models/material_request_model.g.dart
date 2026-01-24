// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_request_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaterialRequestModelAdapter extends TypeAdapter<MaterialRequestModel> {
  @override
  final int typeId = 6;

  @override
  MaterialRequestModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialRequestModel(
      id: fields[0] as int,
      projectId: fields[1] as int,
      requestedBy: fields[2] as int,
      status: fields[3] as String,
      description: fields[4] as String?,
      approvedBy: fields[5] as String?,
      approvedAt: fields[6] as String?,
      createdAt: fields[7] as String,
      updatedAt: fields[8] as String,
      projectName: fields[9] as String?,
      requestedByName: fields[10] as String?,
      items: (fields[11] as List).cast<MaterialRequestItemModel>(),
      isSynced: fields[12] as bool,
      localId: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialRequestModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.requestedBy)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.approvedBy)
      ..writeByte(6)
      ..write(obj.approvedAt)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.projectName)
      ..writeByte(10)
      ..write(obj.requestedByName)
      ..writeByte(11)
      ..write(obj.items)
      ..writeByte(12)
      ..write(obj.isSynced)
      ..writeByte(13)
      ..write(obj.localId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialRequestModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MaterialRequestItemModelAdapter
    extends TypeAdapter<MaterialRequestItemModel> {
  @override
  final int typeId = 7;

  @override
  MaterialRequestItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialRequestItemModel(
      id: fields[0] as int,
      materialRequestId: fields[1] as int,
      materialId: fields[2] as int,
      quantity: fields[3] as int,
      materialName: fields[4] as String?,
      unit: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialRequestItemModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.materialRequestId)
      ..writeByte(2)
      ..write(obj.materialId)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.materialName)
      ..writeByte(5)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialRequestItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
