double getCorrectedSG(double sg, double temperatureF) {
  final correction = {
    43: -0.001,
    50: -0.0007,
    53: -0.0005,
    60: 0,
    65: 0.0005,
    70: 0.001,
    77: 0.002,
    84: 0.003,
  };

  final nearest = correction.entries.reduce((a, b) =>
    (temperatureF - a.key).abs() < (temperatureF - b.key).abs() ? a : b);
  return sg + nearest.value;
}
