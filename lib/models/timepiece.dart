import 'dart:typed_data';

enum MovementType {
  auto,
  manual,
  quartz,
  other,
}

class Timepiece {
  const Timepiece({
    required this.id,
    required this.brand,
    required this.model,
    required this.serial,
    required this.purchaseDate,
    //this.name,
    //this.movementType,
    this.notes,
    this.imageUrl,
    this.image,
  });

  final String id;
  final String brand;
  final String model;
  final String serial;
  final DateTime purchaseDate;
  //final String? name;
  //final MovementType? movementType;

  final String? notes;
  final String? imageUrl;
  final Uint8List? image; // Use Uint8List to store image bytes

  Timepiece copyWith({
    String? id,
    //String? name,
    String? brand,
    String? model,
    String? serial,
    //MovementType? movementType,
    DateTime? purchaseDate,
    String? notes,
    String? imageUrl,
    Uint8List? image,
  }) {
    return Timepiece(
      id: id ?? this.id,
      //name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serial: serial ?? this.serial,
      //movementType: movementType ?? this.movementType,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      //'name': name,
      'brand': brand,
      'model': model,
      'serial': serial,
      //'movementType': movementType.index,
      'purchaseDate': purchaseDate.millisecondsSinceEpoch,
      'notes': notes,
      'imageUrl': imageUrl,
      'image': image, // Store the image bytes
    };
  }

  factory Timepiece.fromMap(Map<String, dynamic> map) {
    return Timepiece(
      id: map['id'],
      //name: map['name'],
      brand: map['brand'],
      model: map['model'],
      serial: map['serial'],
      //movementType: MovementType.values[map['movementType']],
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(map['purchaseDate']),
      notes: map['notes'],
      imageUrl: map['imageUrl'],
      image: map['image'], // Retrieve the image bytes
    );
  }
}
