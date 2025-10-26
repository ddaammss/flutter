import 'package:flutter/material.dart';
import 'package:sajunara_app/models/store.dart';

class StoreState extends ChangeNotifier {
  final List<Store> _stores = [];
  final List<Store> _popularStores = [];
  final List<Store> _nearbyStores = [];

  List<Store> get stores => _stores;
  List<Store> get popularStores => _popularStores;
  List<Store> get nearbyStores => _nearbyStores;

}
