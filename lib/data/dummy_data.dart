import '../models/timepiece.dart';

List<Timepiece> timepieces = [
  Timepiece(
    id: '1',
    brand: 'Rolex',
    model: '114060',
    serial: 'XYZ1234',
    purchaseDate: DateTime(2020, 11, 26),
    notes: 'Purchased for 30th birthday.',
    imageUrl: 'https://cdn2.jomashop.com/media/catalog/product/cache/fde19e4197824625333be074956e7640/r/o/rolex-submariner-automatic-chronometer-black-dial-mens-watch-126610lnbkso.jpg?width=546&height=546',
  ),
  Timepiece(
    id: '2',
    brand: 'Omega',
    model: '311.30.42.30.01.005',
    serial: 'ABC5678',
    purchaseDate: DateTime(2021, 6, 15),
    imageUrl: 'https://i.redd.it/uc05o9f07gb61.jpg',
  ),
  Timepiece(
    id: '3',
    brand: 'TAG Heuer',
    model: 'CBG2A1Z.FT6157',
    serial: 'DEF9101',
    purchaseDate: DateTime(2022, 1, 10),
    notes: 'Gift from wife.',
    imageUrl: 'https://preview.redd.it/9d10cwv4bwj21.png?width=536&format=png&auto=webp&v=enabled&s=6b002e35d68f0bc8ed9773e688ab92f841e6600b',
  ),
];
