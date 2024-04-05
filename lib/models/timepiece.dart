import 'dart:convert';
import 'dart:typed_data';

class Timepiece {
  final String id;
  final String brand;
  final String model;
  final String serial;
  final DateTime purchaseDate;
  final String? notes;
  final String? imageUrl;
  final Uint8List? image;
  final String? purchasePrice;
  final String? referenceNumber;
  final String? caliber;
  final String? crystalType;

  const Timepiece({
    required this.id,
    required this.brand,
    required this.model,
    required this.serial,
    required this.purchaseDate,
    this.notes,
    this.imageUrl,
    this.image,
    this.purchasePrice,
    this.referenceNumber,
    this.caliber,
    this.crystalType,
  });

  Timepiece copyWith({
    String? id,
    String? brand,
    String? model,
    String? serial,
    DateTime? purchaseDate,
    String? notes,
    String? imageUrl,
    Uint8List? image,
    String? purchasePrice,
    String? referenceNumber,
    String? caliber,
    String? crystalType,
  }) {
    return Timepiece(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serial: serial ?? this.serial,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      image: image ?? this.image,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      caliber: caliber ?? this.caliber,
      crystalType: crystalType ?? this.crystalType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'serial': serial,
      'purchaseDate': purchaseDate.toIso8601String(),
      'notes': notes,
      'imageUrl': imageUrl,
      'image': image != null ? base64Encode(image!) : null,
      'purchasePrice': purchasePrice,
      'referenceNumber': referenceNumber,
      'caliber': caliber,
      'crystalType': crystalType,
    };
  }

  factory Timepiece.fromMap(Map<String, dynamic> map) {
    return Timepiece(
      id: map['id'],
      brand: map['brand'],
      model: map['model'],
      serial: map['serial'],
      purchaseDate: DateTime.parse(map['purchaseDate']),
      notes: map['notes'],
      imageUrl: map['imageUrl'],
      image: map['image'] != null ? base64Decode(map['image']) : null,
      purchasePrice: map['purchasePrice'],
      referenceNumber: map['referenceNumber'],
      caliber: map['caliber'],
      crystalType: map['crystalType'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Timepiece.fromJson(String source) => Timepiece.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Timepiece(id: $id, brand: $brand, model: $model, serial: $serial, purchaseDate: $purchaseDate, notes: $notes, imageUrl: $imageUrl, purchasePrice: $purchasePrice, referenceNumber: $referenceNumber, caliber: $caliber, crystalType: $crystalType)';
  }
}
