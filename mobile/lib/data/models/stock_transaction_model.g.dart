// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockTransactionModelAdapter extends TypeAdapter<StockTransactionModel> {
  @override
  final int typeId = 13;

  @override
  StockTransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockTransactionModel(
      id: fields[0] as int,
      projectId: fields[1] as int,
      transactionType: fields[2] as String,
      source: fields[3] as String,
      sourceId: fields[4] as int?,
      transactionDate: fields[5] as String,
      items: (fields[6] as List).cast<StockItemModel>(),
      projectName: fields[7] as String?,
      vendorName: fields[8] as String?,
      poNumber: fields[9] as String?,
      notes: fields[10] as String?,
      isSynced: fields[11] as bool,
      syncError: fields[12] as String?,
      createdAt: fields[13] as String,
      updatedAt: fields[14] as String,
      createdBy: fields[15] as int?,
      createdByName: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StockTransactionModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.transactionType)
      ..writeByte(3)
      ..write(obj.source)
      ..writeByte(4)
      ..write(obj.sourceId)
      ..writeByte(5)
      ..write(obj.transactionDate)
      ..writeByte(6)
      ..write(obj.items)
      ..writeByte(7)
      ..write(obj.projectName)
      ..writeByte(8)
      ..write(obj.vendorName)
      ..writeByte(9)
      ..write(obj.poNumber)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.isSynced)
      ..writeByte(12)
      ..write(obj.syncError)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.createdBy)
      ..writeByte(16)
      ..write(obj.createdByName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockTransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StockItemModelAdapter extends TypeAdapter<StockItemModel> {
  @override
  final int typeId = 14;

  @override
  StockItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockItemModel(
      id: fields[0] as int,
      materialId: fields[1] as int,
      materialName: fields[2] as String,
      quantity: fields[3] as double,
      unit: fields[4] as String,
      gstType: fields[5] as String,
      unitPrice: fields[6] as double?,
      totalAmount: fields[7] as double?,
      batchNumber: fields[8] as String?,
      expiryDate: fields[9] as String?,
      remarks: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StockItemModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.materialId)
      ..writeByte(2)
      ..write(obj.materialName)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.gstType)
      ..writeByte(6)
      ..write(obj.unitPrice)
      ..writeByte(7)
      ..write(obj.totalAmount)
      ..writeByte(8)
      ..write(obj.batchNumber)
      ..writeByte(9)
      ..write(obj.expiryDate)
      ..writeByte(10)
      ..write(obj.remarks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
