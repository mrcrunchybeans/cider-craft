

class CiderUtils {
  /// Acidity classification based on pH
  ///
  /// | pH Range   | Description                         |
  /// |------------|-------------------------------------|
  /// | < 3.2      | Very High (Cooking apples, crabs)   |
  /// | 3.2–3.4    | High (Many table apples)            |
  /// | 3.4–3.6    | Medium (Balanced, ideal for cider)  |
  /// | > 3.6      | Low (Sweet apples)                  |
  static String classifyAcidity(double ph) {
    if (ph >= 0 && ph < 3.2) {
      return 'Very High (Cooking apples, crabs)';
    }
    if (ph >= 3.2 && ph < 3.4) {
      return 'High (Many table apples)';
    }
    if (ph >= 3.4 && ph < 3.6) {
      return 'Medium (Balanced, ideal for cider)';
    }
    if (ph >= 3.6) {
      return 'Low (Sweet apples)';
    }
    return 'Unknown';
  }

  /// Acidity classification based on TA (titratable acidity in g/L as malic acid)
  ///
  /// | TA (g/L)   | Description                         |
  /// |------------|-------------------------------------|
  /// | < 4.5      | Low (Sweet apples)                  |
  /// | 4.5–7.5    | Medium (Balanced, ideal for cider)  |
  /// | 7.5–11     | High (Many table apples)            |
  /// | > 11       | Very High (Cooking apples, crabs)   |
  static String classifyTA(double ta) {
    if (ta < 4.5) {
      return 'Low (Sweet apples)';
    }
    if (ta < 7.5) {
      return 'Medium (Balanced, ideal for cider)';
    }
    if (ta < 11) {
      return 'High (Many table apples)';
    }
    return 'Very High (Cooking apples, crabs)';
  }

  /// Sugar content classification based on SG (specific gravity)
  ///
  /// | SG         | Description                         |
  /// |------------|-------------------------------------|
  /// | ≤ 1.045    | Low (Summer/cooking apples)         |
  /// | ≤ 1.060    | Medium (Good)                       |
  /// | ≤ 1.070    | High (Ideal)                        |
  /// | > 1.070    | Very High (Crabapples, exceptional) |
  static String classifySugarSG(double sg) {
    if (sg <= 1.045) {
      return 'Low (Summer/cooking apples)';
    }
    if (sg <= 1.060) {
      return 'Medium (Good)';
    }
    if (sg <= 1.070) {
      return 'High (Ideal)';
    }
    return 'Very High (Crabapples, exceptional)';
  }

  /// Correct SG based on temperature (Hydrometer calibrated at 60°F)
  static double correctedSG(double measuredSG, double tempF) {
    double correction = 0.0;
    if (tempF < 43) {
      correction = -0.001;
    } else if (tempF < 50) {
      correction = -0.0007;
    } else if (tempF < 53) {
      correction = -0.0005;
    } else if (tempF < 60) {
      correction = -0.0002;
    } else if (tempF == 60) {
      correction = 0;
    } else if (tempF <= 65) {
      correction = 0.0005;
    } else if (tempF <= 70) {
      correction = 0.001;
    } else if (tempF <= 77) {
      correction = 0.002;
    } else {
      correction = 0.003;
    }
    return measuredSG + correction;
  }

  /// Calculate ABV from OG and FG
  static double calculateABV(double og, double fg) {
    return (og - fg) * 131.25;
  }

  /// Estimate FG assuming full fermentation
  static double estimateFG() {
    return 1.000;
  }

  /// Recommended free SO₂ level (ppm) from pH
  ///
  /// Based on Claude Jolicoeur’s chart (pg. 213):
  ///
  /// | pH   | Free SO₂ (ppm) |
  /// |------|----------------|
  /// | ≤3.0 | 30             |
  /// | ≤3.1 | 40             |
  /// | ≤3.2 | 50             |
  /// | ≤3.3 | 60             |
  /// | ≤3.4 | 75             |
  /// | ≤3.5 | 90             |
  /// | ≤3.6 | 120            |
  /// | ≤3.7 | 150            |
  /// | ≤3.8 | 200            |
  /// | >3.8 | 250            |
static double recommendedFreeSO2ppm(double ph) {
  final points = {
    3.0: 40,
    3.1: 50,
    3.2: 60,
    3.3: 70,
    3.4: 80,
    3.5: 100,
    3.6: 125,
    3.7: 150,
    3.8: 190,
    3.9: 220,
  };

  // Clamp input pH to range
  if (ph <= 3.0) return 40;
  if (ph >= 3.9) return 220;

  // Find nearest two points for linear interpolation
  final keys = points.keys.toList()..sort();
  for (var i = 0; i < keys.length - 1; i++) {
    final x0 = keys[i];
    final x1 = keys[i + 1];
    if (ph >= x0 && ph <= x1) {
      final y0 = points[x0]!;
      final y1 = points[x1]!;
      final slope = (y1 - y0) / (x1 - x0);
      return y0 + slope * (ph - x0);
    }
  }

  return 0; // Should never hit this
}





  /// Converts Campden tablets to grams of potassium metabisulphite
  /// (1 tablet ≈ 0.44g)
  static double campdenToGrams(int tablets) {
    return tablets * 0.44;
  }

  /// Calculate grams of sulfite (KMS) needed to hit target ppm in given volume
  static double sulfiteGramsForVolume(double volumeLiters, double targetPPM) {
    double totalMg = targetPPM * volumeLiters;
    return totalMg / 1000.0;
  }

  /// Convert gallons to liters
  static double gallonsToLiters(double gallons) {
    return gallons * 3.78541;
  }

  /// Convert milliliters to ounces
  static double mlToOz(double ml) {
    return ml * 0.033814;
  }

  /// Convert ounces to milliliters
  static double ozToMl(double oz) {
    return oz * 29.5735;
  }

  /// Round to two decimal places
  static double round2(double val) {
    return (val * 100).round() / 100.0;
  }

  /// Return a default FG of 1.000 (placeholder for future attenuation calc)
  static double calculateFG(double og) {
    return estimateFG();
  }

  static double ppmToGrams(double gallons, int ppm) {
  return ppm * gallons * 3.78541 / 1000;
}

}
