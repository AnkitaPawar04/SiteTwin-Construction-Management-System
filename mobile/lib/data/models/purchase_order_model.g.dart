// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchaseOrderModelAdapter extends TypeAdapter<PurchaseOrderModel> {
  @override
  final int typeId = 10;

  @override
  PurchaseOrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseOrderModel(
      id: fields[0] as int,
      materialRequestId: fields[1] as int?,
      vendorId: fields[2] as int,
      poNumber: fields[3] as String,
      poDate: fields[4] as String,
      totalAmount: fields[5] as double,
      gstType: fields[6] as String,
      status: fields[7] as String,
      items: (fields[8] as List).cast<PurchaseOrderItemModel>(),
      vendorName: fields[9] as String?,
      notes: fields[10] as String?,
      invoiceUrl: fields[11] as String?,
      deliveryDate: fields[12] as String?,
      createdAt: fields[13] as String,
      updatedAt: fields[14] as String,
      isSynced: fields[15] as bool,
      localId: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseOrderModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.materialRequestId)
      ..writeByte(2)
      ..write(obj.vendorId)
      ..writeByte(3)
      ..write(obj.poNumber)
      ..writeByte(4)
      ..write(obj.poDate)
      ..writeByte(5)
      ..write(obj.totalAmount)
      ..writeByte(6)
      ..write(obj.gstType)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.items)
      ..writeByte(9)
      ..write(obj.vendorName)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.invoiceUrl)
      ..writeByte(12)
      ..write(obj.deliveryDate)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.isSynced)
      ..writeByte(16)
      ..write(obj.localId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PurchaseOrderItemModelAdapter
    extends TypeAdapter<PurchaseOrderItemModel> {
  @override
  final int typeId = 11;

  @override
  PurchaseOrderItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseOrderItemModel(
      id: fields[0] as int,
      purchaseOrderId: fields[1] as int,
      productId: fields[2] as int,
      productName: fields[3] as String,
      quantity: fields[4] as int,
      unitPrice: fields[5] as double,
      gstRate: fields[6] as double,
      totalPrice: fields[7] as double,
      unit: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseOrderItemModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.purchaseOrderId)
      ..writeByte(2)
      ..write(obj.productId)
      ..writeByte(3)
      ..write(obj.productName)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.unitPrice)
      ..writeByte(6)
      ..write(obj.gstRate)
      ..writeByte(7)
      ..write(obj.totalPrice)
      ..writeByte(8)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrderItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
