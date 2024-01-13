import 'dart:typed_data';

class Timepiece {
  const Timepiece({
    required this.id,
    required this.brand,
    required this.model,
    required this.serial,
    required this.purchaseDate,
    this.notes,
    this.imageUrl,
    this.image,
    this.purchasePrice, // New field
    this.referenceNumber, // New field
    this.caliber, // New field
    this.crystalType, // New field
  });

  final String id;
  final String brand;
  final String model;
  final String serial;
  final DateTime purchaseDate;
  final String? notes;
  final String? imageUrl;
  final Uint8List? image;
  final String? purchasePrice; // New field
  final String? referenceNumber; // New field
  final String? caliber; // New field
  final String? crystalType; // New field

  Timepiece copyWith({
    String? id,
    String? brand,
    String? model,
    String? serial,
    DateTime? purchaseDate,
    String? notes,
    String? imageUrl,
    Uint8List? image,
    String? purchasePrice, // New field
    String? referenceNumber, // New field
    String? caliber, // New field
    String? crystalType, // New field
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
      'purchaseDate': purchaseDate.millisecondsSinceEpoch,
      'notes': notes,
      'imageUrl': imageUrl,
      'image': image,
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
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(map['purchaseDate']),
      notes: map['notes'],
      imageUrl: map['imageUrl'],
      image: map['image'],
      purchasePrice: map['purchasePrice'],
      referenceNumber: map['referenceNumber'],
      caliber: map['caliber'],
      crystalType: map['crystalType'],
    );
  }

  @override
  String toString() {
    return 'Timepiece(id: $id, brand: $brand, model: $model, image: ${image != null ? 'Image available' : 'No image'}, purchasePrice: $purchasePrice, referenceNumber: $referenceNumber, caliber: $caliber, crystalType: $crystalType)';
  }
}
