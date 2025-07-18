double getSulfitePPM(double pH) {
  if (pH <= 3.0) return 40;
  if (pH >= 3.9) return 200;
  return 40 + (pH - 3.0) * ((200 - 40) / (3.9 - 3.0));
}
