// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VendorModelAdapter extends TypeAdapter<VendorModel> {
  @override
  final int typeId = 12;

  @override
  VendorModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VendorModel(
      id: fields[0] as int,
      name: fields[1] as String,
      contactPerson: fields[2] as String?,
      phone: fields[3] as String?,
      email: fields[4] as String?,
      address: fields[5] as String?,
      gstNumber: fields[6] as String?,
      panNumber: fields[7] as String?,
      vendorType: fields[8] as String?,
      createdAt: fields[9] as String,
      updatedAt: fields[10] as String,
      isSynced: fields[11] as bool,
      localId: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VendorModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.contactPerson)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.gstNumber)
      ..writeByte(7)
      ..write(obj.panNumber)
      ..writeByte(8)
      ..write(obj.vendorType)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.isSynced)
      ..writeByte(12)
      ..write(obj.localId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VendorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
