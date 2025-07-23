class SugarType {
  final String name;
  final double sgPerGramPerLiter; // How much SG 1g/L raises

  SugarType(this.name, this.sgPerGramPerLiter);
}

final List<SugarType> sugarTypes = [
  SugarType("Table Sugar (Sucrose)", 0.00046),
  SugarType("Honey", 0.00035),
  SugarType("Apple Juice Concentrate", 0.00030),
];