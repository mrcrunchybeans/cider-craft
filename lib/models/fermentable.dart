import '../utils/utils.dart';

enum AbvSource {
  measured,
  adjusted,
}

class Fermentable {
  final double? amount;
  final VolumeUnit? unit;
  final double? sg;

  Fermentable({this.amount, this.unit, this.sg});
}
