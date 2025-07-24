import 'package:flutter/material.dart';
import '../utils/utils.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/utils/sugar_gravity_data.dart';





class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Cider Tools"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.science), text: "ABV"),
              Tab(icon: Icon(Icons.trending_up), text: "SG Correction"),
              Tab(icon: Icon(Icons.biotech), text: "SO₂ Calculator"),
              Tab(icon: Icon(Icons.compare_arrows), text: "Unit Converter"),
              Tab(icon: Icon(Icons.bubble_chart), text: "Bubble Counter"),
              Tab(icon: Icon(Icons.tune), text: "Gravity Adjuster"),
              Tab(icon: Icon(Icons.calendar_month), text: "FSU"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ABVCalculatorTab(),
            SGCorrectionTab(),
            SulfiteToolTab(),
            UnitConverterTab(),
            BubbleCounterTab(),
            GravityAdjustTool(),
            FSUCalculatorTab(),
          ],
        ),
      ),
    );
  }
}

class ABVCalculatorTab extends StatefulWidget {
  const ABVCalculatorTab({super.key});

  @override
  State<ABVCalculatorTab> createState() => _ABVCalculatorTabState();
}

class _ABVCalculatorTabState extends State<ABVCalculatorTab> {
  double og = 1.050;
  double fg = 1.000;

  final ogController = TextEditingController();
  final fgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ogController.text = og.toStringAsFixed(3);
    fgController.text = fg.toStringAsFixed(3);

    
  }

  @override
  Widget build(BuildContext context) {
    final abv = CiderUtils.calculateABV(og, fg);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Original Gravity (OG)"),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: og,
                min: 1.000,
                max: 1.150,
                divisions: 150,
                label: og.toStringAsFixed(3),
                onChanged: (val) => setState(() {
                  og = val;
                  ogController.text = val.toStringAsFixed(3);
                }),
              ),
            ),
            SizedBox(
              width: 70,
              child: TextField(
                controller: ogController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null) setState(() => og = parsed);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text("Final Gravity (FG)"),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: fg,
                min: 0.990,
                max: 1.050,
                divisions: 60,
                label: fg.toStringAsFixed(3),
                onChanged: (val) => setState(() {
                  fg = val;
                  fgController.text = val.toStringAsFixed(3);
                }),
              ),
            ),
            SizedBox(
              width: 70,
              child: TextField(
                controller: fgController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null) setState(() => fg = parsed);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text("Estimated ABV: ${abv.toStringAsFixed(2)}%"),
      ],
    );
  }
}

class SGCorrectionTab extends StatefulWidget {
  const SGCorrectionTab({super.key});

  @override
  State<SGCorrectionTab> createState() => _SGCorrectionTabState();
}

class _SGCorrectionTabState extends State<SGCorrectionTab> {
  double sg = 1.050;
  double tempF = 60;

  final sgController = TextEditingController();
  final tempController = TextEditingController();

  @override
  void initState() {
    super.initState();
    sgController.text = sg.toStringAsFixed(3);
    tempController.text = tempF.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final corrected = CiderUtils.correctedSG(sg, tempF);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Measured SG"),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: sg,
                min: 1.000,
                max: 1.150,
                divisions: 150,
                label: sg.toStringAsFixed(3),
                onChanged: (val) => setState(() {
                  sg = val;
                  sgController.text = val.toStringAsFixed(3);
                }),
              ),
            ),
            SizedBox(
              width: 70,
              child: TextField(
                controller: sgController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null) setState(() => sg = parsed);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text("Temperature (°F)"),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: tempF,
                min: 40,
                max: 90,
                divisions: 50,
                label: tempF.toStringAsFixed(1),
                onChanged: (val) => setState(() {
                  tempF = val;
                  tempController.text = val.toStringAsFixed(1);
                }),
              ),
            ),
            SizedBox(
              width: 70,
              child: TextField(
                controller: tempController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null) setState(() => tempF = parsed);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text("Corrected SG: ${corrected.toStringAsFixed(3)}"),
      ],
    );
  }
}

// ###################### Start of Sulfite Tool Tab #############################

class SulfiteToolTab extends StatefulWidget {
  const SulfiteToolTab({super.key});

  @override
  State<SulfiteToolTab> createState() => _SulfiteToolTabState();
}

class _SulfiteToolTabState extends State<SulfiteToolTab> {
  double pH = 3.4;
  int customPPM = 50;
  bool useRecommendedPPM = true;
  double volume = 5.0;
  bool useGallons = true;
  bool isPerry = false;
  String selectedSource = 'Potassium Metabisulphite';

  final pHController = TextEditingController();
  final volumeController = TextEditingController();
  final ppmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pHController.text = pH.toStringAsFixed(2);
    volumeController.text = volume.toStringAsFixed(1);
    ppmController.text = customPPM.toString();
  }

  @override
  Widget build(BuildContext context) {
    final recommendedPPM = CiderUtils.recommendedFreeSO2ppm(pH);
    final basePPM = useRecommendedPPM ? recommendedPPM : customPPM.toDouble();
    final actualPPM = isPerry ? basePPM + 50 : basePPM;
    final liters = useGallons ? volume * 3.78541 : volume;

    double grams = 0;
    double tablets = 0;
    double mL = 0;
    String resultText = '';
    String sourceNote = '';

    switch (selectedSource) {
      case 'Potassium Metabisulphite':
        grams = (actualPPM * liters) / 1000 / 0.50;
        resultText = "${grams.toStringAsFixed(2)} grams of K-Meta";
        sourceNote = "Using 50% SO₂ yield from Potassium Metabisulphite.";
        break;
      case 'Sodium Metabisulphite':
        final gramsLow = (actualPPM * liters) / 1000 / 0.60;
        final gramsHigh = (actualPPM * liters) / 1000 / 0.55;
        resultText = "${gramsLow.toStringAsFixed(2)}–${gramsHigh.toStringAsFixed(2)} grams of Na-Meta";
        sourceNote = "Using 55–60% SO₂ yield from Sodium Metabisulphite.";
        break;
      case 'Campden Tablets':
        tablets = (actualPPM * liters) / (50 * 4.546);
        resultText = "${tablets.toStringAsFixed(1)} Campden tablets";
        sourceNote = "1 tablet = 50 ppm SO₂ in 1 imperial gallon (4.546 L).";
        break;
      case '5% Stock Solution':
        mL = actualPPM * liters / 50;
        resultText = "${mL.toStringAsFixed(2)} mL of 5% SO₂ stock solution";
        sourceNote = "Mix 10g K-Meta with 100mL water (SG ~1.0275). 1mL per liter yields 50 ppm.";
        break;
    }

    final warning = actualPPM > 200
        ? "⚠️ Warning: SO₂ level above 200 ppm may be unsafe for consumption."
        : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("SO₂ Dosage Calculator", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text("Must pH"),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: pH,
                min: 2.8,
                max: 4.2,
                divisions: 140,
                label: pH.toStringAsFixed(2),
                onChanged: (val) => setState(() {
                  pH = val;
                  pHController.text = val.toStringAsFixed(2);
                }),
              ),
            ),
            SizedBox(
              width: 70,
              child: TextField(
                controller: pHController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null) setState(() => pH = parsed);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text("Recommended Free SO₂: ${recommendedPPM.toStringAsFixed(0)} ppm", style: const TextStyle(color: Colors.teal)),
        if (warning != null) ...[
          const SizedBox(height: 4),
          Text(warning, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 8),
        if (pH <= 3.0)
          const Text("Note: pH ≤ 3.0 is generally protective; sulfite addition may not be necessary.", style: TextStyle(fontSize: 13)),
        if (pH >= 3.8)
          const Text("Note: pH ≥ 3.8 — consider blending with more acidic juice to increase protection.", style: TextStyle(fontSize: 13)),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text("Use recommended PPM from pH"),
          value: useRecommendedPPM,
          onChanged: (val) => setState(() => useRecommendedPPM = val),
        ),
        if (!useRecommendedPPM)
          TextField(
            controller: ppmController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Target Free SO₂ (ppm)"),
            onChanged: (val) {
              final parsed = int.tryParse(val);
              if (parsed != null) setState(() => customPPM = parsed);
            },
          ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text("Perry (add 50 ppm)"),
          value: isPerry,
          onChanged: (val) => setState(() => isPerry = val),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text("Batch Volume:"),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: volumeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(suffixText: "Volume"),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null) setState(() => volume = parsed);
                },
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<bool>(
              value: useGallons,
              onChanged: (val) => setState(() => useGallons = val!),
              items: const [
                DropdownMenuItem(value: true, child: Text("Gallons")),
                DropdownMenuItem(value: false, child: Text("Liters")),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSourceButton(Icons.science, 'Potassium Metabisulphite'),
              _buildSourceButton(Icons.science_outlined, 'Sodium Metabisulphite'),
              _buildSourceButton(Icons.tablet, 'Campden Tablets'),
              _buildSourceButton(Icons.water_drop, '5% Stock Solution'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                "Use: $resultText",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: "Copy to clipboard",
              onPressed: () {
                Clipboard.setData(ClipboardData(text: resultText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Copied: $resultText")),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(sourceNote, style: const TextStyle(fontSize: 13, color: Colors.teal)),
        const Divider(thickness: 5),
        const SizedBox(height: 24),
        const Text("Recommended Free SO₂ (ppm) vs pH", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              minX: 3.0,
              maxX: 3.9,
              minY: 0,
              maxY: 240,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((LineBarSpot spot) {
                      return LineTooltipItem(
                        'pH: ${spot.x.toStringAsFixed(2)}\nppm: ${spot.y.toStringAsFixed(0)}',
                        const TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                ),
              ),

              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  spots: List.generate(
                    91,
                    (i) {
                      final phVal = 3.0 + i * 0.01;
                      final ppm = CiderUtils.recommendedFreeSO2ppm(phVal);
                      return FlSpot(phVal, ppm.toDouble());
                    },
                  ),
                  barWidth: 3,
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade900, Colors.teal.shade300],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  dotData: FlDotData(show: false),
                ),
              ],
              extraLinesData: ExtraLinesData(
                verticalLines: [
                  VerticalLine(
                    x: pH,
                    color: Colors.redAccent,
                    strokeWidth: 2,
                    dashArray: [4, 4],
                    label: VerticalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      labelResolver: (line) => "pH ${pH.toStringAsFixed(2)}\n${CiderUtils.recommendedFreeSO2ppm(pH).round()} ppm",
                    ),
                  ),
                ],
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 0.40,
                    reservedSize: 40,
                    getTitlesWidget: (value, _) => Text(value.toStringAsFixed(1)),
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              gridData: FlGridData(show: true),
            ),
          ),
        ),
      ],
    );
  }
   Widget _buildSourceButton(IconData icon, String label) {
    final isSelected = selectedSource == label;
    return GestureDetector(
      onTap: () => setState(() => selectedSource = label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: isSelected ? Colors.teal : Colors.grey.shade300,
            child: Icon(icon, color: isSelected ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}




// ############### Start of Unit Converter Tab ###############

class UnitConverterTab extends StatelessWidget {
  const UnitConverterTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: const [
          TabBar(
            tabs: [
              Tab(text: "Volume"),
              Tab(text: "Mass"),
              Tab(text: "Temperature"),
              Tab(text: "Gravity"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                UnitConverterCategoryTab(category: 'Volume'),
                UnitConverterCategoryTab(category: 'Mass'),
                UnitConverterCategoryTab(category: 'Temperature'),
                UnitConverterCategoryTab(category: 'Gravity'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UnitConverterCategoryTab extends StatefulWidget {
  final String category;

  const UnitConverterCategoryTab({required this.category, super.key});

  @override
  State<UnitConverterCategoryTab> createState() => _UnitConverterCategoryTabState();
}

class _UnitConverterCategoryTabState extends State<UnitConverterCategoryTab> {
  double inputValue = 1.0;
  final inputController = TextEditingController(text: '1.0');

  late String fromUnit;
  late String toUnit;

  final Map<String, double> volumeUnits = {
    'mL': 1.0,
    'L': 1000.0,
    'fl oz': 29.5735,
    'cup': 236.588,
    'pint': 473.176,
    'quart': 946.353,
    'gal': 3785.41,
    '12 oz bottle': 355.0,
  };

  final Map<String, double> massUnits = {
    'mg': 0.001,
    'g': 1.0,
    'kg': 1000.0,
    'oz': 28.3495,
    'lb': 453.592,
  };

  final List<String> tempUnits = ['°C', '°F', 'K'];

  final List<String> gravityUnits = ['SG', 'SGP', '°Brix', '°Plato'];


  @override
  void initState() {
    super.initState();
    switch (widget.category) {
      case 'Volume':
        fromUnit = 'gal';
        toUnit = '12 oz bottle';
        break;
      case 'Mass':
        fromUnit = 'g';
        toUnit = 'lb';
        break;
      case 'Temperature':
        fromUnit = '°C';
        toUnit = '°F';
        break;
      case 'Gravity':
        fromUnit = 'SG';
        toUnit = '°Brix';
        break;
    }
  }

  List<String> getUnits() {
    if (widget.category == 'Volume') return volumeUnits.keys.toList();
    if (widget.category == 'Mass') return massUnits.keys.toList();
    if (widget.category == 'Gravity') return gravityUnits.toList();

    return tempUnits;
  }

  double convert() {
  switch (widget.category) {
    case 'Temperature':
      return _convertTemp(inputValue, fromUnit, toUnit);
    case 'Gravity':
      return convertGravity(inputValue, fromUnit, toUnit);
    case 'Volume':
      return _convertWithMap(volumeUnits);
    case 'Mass':
      return _convertWithMap(massUnits);
    default:
      return 0;
  }
}

double _convertWithMap(Map<String, double> units) {
  final fromFactor = units[fromUnit];
  final toFactor = units[toUnit];

  if (fromFactor == null || toFactor == null) return 0;
  return (inputValue * fromFactor) / toFactor;
}



  double _convertTemp(double val, String from, String to) {
    if (from == to) return val;
    if (from == '°C') return to == '°F' ? val * 9 / 5 + 32 : val + 273.15;
    if (from == '°F') return to == '°C' ? (val - 32) * 5 / 9 : (val - 32) * 5 / 9 + 273.15;
    if (from == 'K') return to == '°C' ? val - 273.15 : (val - 273.15) * 9 / 5 + 32;
    return val;
  }

double convertGravity(double val, String from, String to) {
  double sg = val;

  // Step 1: Convert everything to SG
  switch (from) {
    case 'SG':
      sg = val;
      break;
    case 'SGP':
      sg = 1.000 + (val / 1000); // 50 -> 1.050
      break;
    case '°Brix':
      sg = (val / (258.6 - ((val / 258.2) * 227.1))) + 1.0;
      break;
    case '°Plato':
      sg = 1 + val / (258.6 - ((val / 258.2) * 227.1)); // Similar to Brix
      break;
  }

  // Step 2: Convert SG to target
  switch (to) {
    case 'SG':
      return sg;
    case 'SGP':
      return (sg - 1.0) * 1000;
    case '°Brix':
    case '°Plato':
      return ((182.4601 * sg - 775.6821) * sg + 1262.7794) * (sg - 1.0);
  }

  return val;
}

// ######## Start Converter Help Text ########

String normalizeUnit(String unit) {
  final u = unit.trim().toLowerCase();
  if (u.contains('specific gravity') || u == 'sg') return 'SG';
  if (u.contains('sgp') || u.contains('points')) return 'SGP';
  if (u.contains('brix')) return 'Brix';
  if (u.contains('plato') || u.contains('°p')) return 'Plato';
  return unit;
}
String getFormulaHint() {
  if (widget.category == 'Temperature') {
    return "Temperature Conversion:\n"
        "°F ↔ °C: (°F - 32) × 5/9 = °C\n"
        "°C ↔ K: °C + 273.15 = K";
  }

  if (widget.category == 'Mass' || widget.category == 'Volume') {
    final Map<String, double> unitMap =
        widget.category == 'Mass' ? massUnits : volumeUnits;

    final fromFactor = unitMap[fromUnit];
    final toFactor = unitMap[toUnit];

    if (fromFactor == null || toFactor == null) {
      return "Conversion formula unavailable.";
    }

    final multiplier = fromFactor / toFactor;
    return "1 $fromUnit = ${multiplier.toStringAsFixed(3)} $toUnit";
  }

  if (widget.category == 'Gravity') {
    final from = normalizeUnit(fromUnit);
    final to = normalizeUnit(toUnit);

    if (from == 'SG' && to == 'Brix') {
      return "SG → Brix:\n"
          "Brix = (182.4601 × SG³) - (775.6821 × SG²) + (1262.7794 × SG) - 669.5622";
    }
    if (from == 'Brix' && to == 'SG') {
      return "Brix → SG:\n"
          "SG ≈ 1 + (Brix / (258.6 - (Brix / 258.2 × 227.1)))";
    }

    if (from == 'SG' && to == 'Plato') {
      return "SG → Plato:\n"
          "°P = -616.868 + 1111.14×SG - 630.272×SG² + 135.997×SG³";
    }
    if (from == 'Plato' && to == 'SG') {
      return "Plato → SG:\n"
          "SG ≈ 1 + (°P / (258.6 - (°P / 258.2 × 227.1)))";
    }

    if (from == 'SG' && to == 'SGP') {
      return "SG → SGP:\n"
          "SGP = (SG - 1.000) × 1000";
    }
    if (from == 'SGP' && to == 'SG') {
      return "SGP → SG:\n"
          "SG = (SGP / 1000) + 1.000";
    }

    if ((from == 'Brix' && to == 'Plato') || (from == 'Plato' && to == 'Brix')) {
      return "Brix ↔ Plato:\n"
          "Brix and Plato are functionally equivalent in brewing.\n"
          "Use interchangeably unless precise distinction is needed.";
    }

    if (from == 'Brix' && to == 'SGP') {
      return "Brix → SGP:\n"
          "SG = 1 + (Brix / (258.6 - (Brix / 258.2 × 227.1)))\n"
          "SGP = (SG - 1.000) × 1000";
    }
    if (from == 'SGP' && to == 'Brix') {
      return "SGP → Brix:\n"
          "SG = (SGP / 1000) + 1.000\n"
          "Brix = (182.4601 × SG³) - (775.6821 × SG²) + (1262.7794 × SG) - 669.5622";
    }

    if (from == 'Plato' && to == 'SGP') {
      return "Plato → SGP:\n"
          "SG = 1 + (Plato / (258.6 - (Plato / 258.2 × 227.1)))\n"
          "SGP = (SG - 1.000) × 1000";
    }
    if (from == 'SGP' && to == 'Plato') {
      return "SGP → Plato:\n"
          "SG = (SGP / 1000) + 1.000\n"
          "°P = -616.868 + 1111.14×SG - 630.272×SG² + 135.997×SG³";
    }

    return "Unrecognized gravity unit combination: $fromUnit → $toUnit";
  }

  return "No conversion formula available.";
}

// ######## End Converter Help Text ########



String formatNumber(double value) {
    if (widget.category == 'Gravity') {
    return value.toStringAsFixed(4);
  }
  if (value >= 10000 || value < 0.001) {
    return value.toStringAsExponential(3); // e.g. 1.234e+5
  } else {
    return value.toStringAsFixed(3).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }
}

  @override
  Widget build(BuildContext context) {
    final units = getUnits();
    final result = convert();
    final resultText = "$result $toUnit";

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Input
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: inputController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                      onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null) {
                        setState(() => inputValue = parsed);
                      }
                    },
                      
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    DropdownButton<String>(
                      value: fromUnit,
                      isExpanded: true,
                      onChanged: (val) => setState(() => fromUnit = val!),
                      items: units
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Text("=", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              // Output
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            formatNumber(result),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          tooltip: "Copy to clipboard",
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: resultText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Copied: $resultText')),
                            );
                          },
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: toUnit,
                      isExpanded: true,
                      onChanged: (val) => setState(() => toUnit = val!),
                      items: units
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.amber.shade100,
              child: Text(
                getFormulaHint(),
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//Start of Bubble Counter Tab

class BubbleCounterTab extends StatefulWidget {
  const BubbleCounterTab({super.key});

  @override
  State<BubbleCounterTab> createState() => _BubbleCounterTabState();
}

class _BubbleCounterTabState extends State<BubbleCounterTab> {
  List<DateTime> tapTimes = [];
  double avgInterval = 0.0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void recordTap() {
    final now = DateTime.now();

    setState(() {
      tapTimes.add(now);

      if (tapTimes.length >= 2) {
        List<double> intervals = [];
        for (int i = 1; i < tapTimes.length; i++) {
          intervals.add(
              tapTimes[i].difference(tapTimes[i - 1]).inMilliseconds / 1000.0);
        }

        final filtered =
            intervals.where((i) => i > 0.2 && i < 120).toList();

        if (filtered.isNotEmpty) {
          avgInterval = filtered.reduce((a, b) => a + b) / filtered.length;
        } else {
          avgInterval = 0.0;
        }
      }
    });
  }

  void reset() {
    setState(() {
      tapTimes.clear();
      avgInterval = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bubblesPerMin =
        avgInterval > 0 ? (60 / avgInterval).toStringAsFixed(1) : "--";
    final lastTap = tapTimes.isNotEmpty ? tapTimes.last : null;
    final timeSinceLast = lastTap != null
        ? (DateTime.now().difference(lastTap).inMilliseconds / 1000.0)
            .toStringAsFixed(1)
        : "--";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: recordTap,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 200),
              shape: const CircleBorder(),
              backgroundColor: Colors.green,
            ),
            child: const Text(
              "Tap\nBubble",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(height: 24),
          Text("Total Taps: ${tapTimes.length}"),
          const SizedBox(height: 8),
          Text("Time Since Last Tap: $timeSinceLast sec"),
          const SizedBox(height: 8),
          Text("Avg Interval: ${avgInterval.toStringAsFixed(2)} sec"),
          const SizedBox(height: 8),
          Text("Bubbles Per Minute: $bubblesPerMin"),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: reset,
            icon: const Icon(Icons.refresh),
            label: const Text("Reset"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}

// ############### Start of Gravity Adjustment Tab ###############


class GravityAdjustTool extends StatefulWidget {
  const GravityAdjustTool({super.key});

  @override
  State<GravityAdjustTool> createState() => _GravityAdjustToolState();
}

class _GravityAdjustToolState extends State<GravityAdjustTool> {
  final _volumeController = TextEditingController();
  final _currentSGController = TextEditingController();
  final _targetSGController = TextEditingController();
  final _abvController = TextEditingController();
  bool userOverrodeAbv = false;
  Timer? abvDebounce;
  Timer? sgDebounce;


  String _result = '';
  String _formulaHelp = '';
  String _selectedSugar = 'Table Sugar (sucrose)';
  bool _useGallons = true;

  String formatGallonsToGalCupOz(double gallons) {
  final int wholeGallons = gallons.floor();
  final double remainingGallons = gallons - wholeGallons;

  final int totalOz = (remainingGallons * 128).round();
  final int cups = totalOz ~/ 8;
  final int flOz = totalOz % 8;

  List<String> parts = [];

  if (wholeGallons > 0) parts.add("$wholeGallons gal");
  if (cups > 0) parts.add("$cups cup${cups > 1 ? 's' : ''}");
  if (flOz > 0) parts.add("$flOz fl oz");

  return parts.isNotEmpty ? parts.join(', ') : "0 fl oz";
}
@override
void initState() {
  super.initState();

  _abvController.addListener(() {
    final val = double.tryParse(_abvController.text);
    final fg = double.tryParse(_currentSGController.text) ?? 1.000;

    if (val != null && val > 0 && val < 25) {
      userOverrodeAbv = true;

      sgDebounce?.cancel();
      sgDebounce = Timer(const Duration(milliseconds: 500), () {
        final requiredOG = (val / 131.25) + fg;
        final formattedOG = double.parse(requiredOG.toStringAsFixed(3));

        _targetSGController.text = formattedOG.toStringAsFixed(3);
        _calculate();
      });
    }
  });
}

void _showSugarInfoDialog(BuildContext context) {
  final sugarMap = SugarGravityData.ppgMap;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Sugar Sources and PPG"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: sugarMap.entries.map((entry) {
            return ListTile(
              dense: true,
              title: Text(entry.key),
              trailing: Text("PPG: ${entry.value.toStringAsFixed(0)}"),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}


  void _calculate() {
    final double? volumeInput = double.tryParse(_volumeController.text);
    final double? currentSG = double.tryParse(_currentSGController.text);
    final double? targetSG = double.tryParse(_targetSGController.text);

    if (volumeInput == null || currentSG == null || targetSG == null) {
      setState(() {
        _result = 'Please enter valid numbers.';
        _formulaHelp = '';
      });
      return;
    }

    final double volumeGallons = _useGallons ? volumeInput : volumeInput / 3.78541;
    final double deltaSG = targetSG - currentSG;
    final double deltaPoints = deltaSG * 1000;
    final double? ppg = SugarGravityData.ppgMap[_selectedSugar];

    if (ppg == null) {
      setState(() {
        _result = 'Unknown sugar type selected.';
        _formulaHelp = '';
      });
      return;
    }

    if (deltaSG == 0) {
      setState(() {
        _result = 'No adjustment needed. Target and current SG are equal.';
        _formulaHelp = '';
      });
      return;
    }

    if (deltaSG > 0) {
      // Sugar addition
      final poundsNeeded = (deltaPoints * volumeGallons) / ppg;
      final gramsNeeded = poundsNeeded * 453.592;
      final newSG = currentSG + deltaSG;

      setState(() {
        _result =
            'Add ~${gramsNeeded.toStringAsFixed(1)}g of $_selectedSugar to reach ${newSG.toStringAsFixed(3)} SG.';
        _formulaHelp =
            'Sugar Addition Formula:\n'
            'Δ points = (${targetSG.toStringAsFixed(3)} - ${currentSG.toStringAsFixed(3)}) × 1000 = ${deltaPoints.toStringAsFixed(1)} pts\n'
            'Pounds = (Δ pts × Volume) / PPG\n'
            'Grams = Pounds × 453.592';
      });
    } else {
      // Dilution
      final dilutionRatio = targetSG / currentSG;
      final totalVolume = volumeGallons / dilutionRatio;
      final waterToAddGallons = totalVolume - volumeGallons;
      final waterToAdd = _useGallons
          ? waterToAddGallons
          : waterToAddGallons * 3.78541;

      setState(() {
        _result = _useGallons
    ? 'Dilute by adding ~${formatGallonsToGalCupOz(waterToAddGallons)} of water.'
    : 'Dilute by adding ~${waterToAdd.toStringAsFixed(1)} liters of water.';

        _formulaHelp =
            'Dilution Formula:\n'
            'Target SG = (Current SG × Volume) / (Volume + Water)\n'
            'Rearranged → Water = Volume × ((Current SG / Target SG) - 1)';
      });
    }
    // Calculate ABV if not overridden
if (!userOverrodeAbv) {
  final og = double.tryParse(_targetSGController.text);
  final fg = double.tryParse(_currentSGController.text);
  if (og != null && fg != null && og > fg) {
    final abv = (og - fg) * 131.25;
    _abvController.text = abv.toStringAsFixed(2);
  }
}

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Gravity Adjustment Tool",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _volumeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Batch Volume',
                    border: OutlineInputBorder(),
                  ),
                                onChanged: (_) => _calculate(),

                ),
                
              ),
              const SizedBox(width: 12),
             DropdownButton<bool>(
  value: _useGallons,
  onChanged: (val) {
    if (val == null) return;
    final currentVolume = double.tryParse(_volumeController.text);
    if (currentVolume != null) {
      final converted = val
          ? currentVolume / 3.78541 // L → gal
          : currentVolume * 3.78541; // gal → L
      _volumeController.text = converted.toStringAsFixed(2);
    }
    setState(() => _useGallons = val);
  },
  items: const [
    DropdownMenuItem(value: true, child: Text("Gallons")),
    DropdownMenuItem(value: false, child: Text("Liters")),
  ],
),
            ]
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _currentSGController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Current SG',
              border: OutlineInputBorder(),
            ),
                          onChanged: (_) => _calculate(),

          ),
          const SizedBox(height: 12),
          TextField(
            controller: _targetSGController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Target SG',
              border: OutlineInputBorder(),
            ),
              onChanged: (_) => _calculate(),

          ),
          const SizedBox(height: 12),
TextField(
  controller: _abvController,
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  decoration: const InputDecoration(
    labelText: 'Desired ABV (%)',
    border: OutlineInputBorder(),
  ),
  onChanged: (_) {
    userOverrodeAbv = true;
    // debounce already handled in initState listener
  },
),

          Row(
  children: [
    Expanded(
      child: DropdownButton<String>(
        value: _selectedSugar,
        isExpanded: true,
        items: SugarGravityData.ppgMap.keys.map((type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedSugar = value;
            });
            _calculate();
          }
        },
      ),
    ),
    IconButton(
      icon: const Icon(Icons.info_outline),
      tooltip: "Sugar PPG Info",
      onPressed: () => _showSugarInfoDialog(context),
    ),
  ],
),

          Text(
            _result,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_formulaHelp.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _formulaHelp,
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}
// ############### End of Gravity Adjustment Tab ###############

// ############### Start of FSU Calculator Tab ###############
class FSUCalculatorTab extends StatefulWidget {
  const FSUCalculatorTab({super.key});

  @override
  State<FSUCalculatorTab> createState() => _FSUCalculatorTabState();
}
Color _getFSUColor(double fsu) {
  if (fsu > 400) return Colors.red.shade400;
  if (fsu > 350) return Colors.orange.shade400;
  if (fsu >= 250) return Colors.green.shade600;
  if (fsu > 50) return Colors.orange.shade300;
  return Colors.blueGrey.shade400;
}

String _getFSUMessage(double fsu) {
  if (fsu > 400) return "⚠️ Faster than typical primary fermentation.";
  if (fsu > 350) return "Slightly fast, monitor fermentation closely.";
  if (fsu >= 250) return "✅ Ideal rate for primary fermentation.";
  if (fsu > 50) return "Secondary fermentation or slow primary.";
  return "Very low activity — likely secondary or stalled.";
}

class _FSUCalculatorTabState extends State<FSUCalculatorTab> {
  DateTime date1 = DateTime.now().subtract(const Duration(days: 1));
  DateTime date2 = DateTime.now();
  final sg1Controller = TextEditingController();
  final sg2Controller = TextEditingController();

  double? fsu;

  Future<void> _pickDate(BuildContext context, bool isFirst) async {
    final initial = isFirst ? date1 : date2;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFirst) {
          date1 = picked;
        } else {
          date2 = picked;
        }
        _calculateFSU();
      });
    }
  }

  void _calculateFSU() {
    final sg1 = double.tryParse(sg1Controller.text);
    final sg2 = double.tryParse(sg2Controller.text);
    final days = date2.difference(date1).inDays;

    if (sg1 == null || sg2 == null || days == 0) {
      setState(() => fsu = null);
      return;
    }

    final result = 100000 * (sg1 - sg2) / days;
    setState(() => fsu = result);
  }

  @override
  void initState() {
    super.initState();
    sg1Controller.addListener(_calculateFSU);
    sg2Controller.addListener(_calculateFSU);
  }

  @override
  void dispose() {
    sg1Controller.dispose();
    sg2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Fermentation Speed (FSU)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        const Text("Measurement 1"),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: sg1Controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "SG 1"),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _pickDate(context, true),
              child: Text("${date1.toLocal()}".split(' ')[0]),
            ),
          ],
        ),

        const SizedBox(height: 16),

        const Text("Measurement 2"),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: sg2Controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "SG 2"),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _pickDate(context, false),
              child: Text("${date2.toLocal()}".split(' ')[0]),
            ),
          ],
        ),
const SizedBox(height: 24),

if (fsu != null)
  Container(
    margin: const EdgeInsets.symmetric(vertical: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _getFSUColor(fsu!), // Dynamic color
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Fermentation Speed (FSU): ${fsu!.toStringAsFixed(1)}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          _getFSUMessage(fsu!),
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    ),
  ),

if (fsu == null)
  const Text(
    "Enter valid SGs and dates at least 1 day apart.",
    style: TextStyle(color: Colors.grey),
  ),

        Card(
  color: Colors.blueGrey[50],
  elevation: 2,
  margin: const EdgeInsets.only(top: 24),
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        children: [
          const TextSpan(
            text: 'Guidelines:\n\n',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const TextSpan(
            text: '• ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: 'Primary/Turbulent Fermentation: ',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '250–350 FSU\n',
          ),
          const TextSpan(
            text: '• ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: 'Secondary Fermentation: ',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(
            text: '50 FSU or less',
          ),
        ],
      ),
    ),
  ),
),


      ],
    );
  }
}
// ############### End of FSU Calculator Tab ###############
