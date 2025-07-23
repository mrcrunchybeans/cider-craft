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
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Cider Tools"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.local_drink), text: "ABV"),
              Tab(icon: Icon(Icons.thermostat), text: "SG Correction"),
              Tab(icon: Icon(Icons.science), text: "SO₂ Calculator"),
              Tab(icon: Icon(Icons.square), text: "Unit Converter"),
              Tab(icon: Icon(Icons.bubble_chart), text: "Bubble Counter"),
              Tab(icon: Icon(Icons.circle), text: "Gravity Adjuster"),
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
  bool displayGrams = true;

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
    final actualPPM = useRecommendedPPM ? recommendedPPM : customPPM.toDouble();

    final liters = useGallons ? volume * 3.78541 : volume;
    final grams = (actualPPM * liters) / 1000;
    final tablets = grams / 0.44;

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
        SwitchListTile(
          title: const Text("Display result in grams"),
          value: displayGrams,
          onChanged: (val) => setState(() => displayGrams = val),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                displayGrams
                    ? "Use: ${grams.toStringAsFixed(2)} grams of K-Meta"
                    : "Use: ${tablets.toStringAsFixed(1)} Campden tablets",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: "Copy to clipboard",
              onPressed: () {
                final text = displayGrams
                    ? "${grams.toStringAsFixed(2)} grams of K-Meta"
                    : "${tablets.toStringAsFixed(1)} Campden tablets";
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Copied: $text")),
                );
              },
            ),
          ],
        ),
                        const Divider(thickness: 5),

        if (warning != null) ...[
          const SizedBox(height: 12),
          Text(warning, style: const TextStyle(color: Colors.red)),
        ],

        const SizedBox(height: 24),
        const Text(
          "Recommended Free SO₂ (ppm) vs pH",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              minX: 3.0,
              maxX: 3.9,
              minY: 0,
              maxY: 240,
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
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.teal.withAlpha(255),
                      Colors.teal.withAlpha(180),
                      Colors.teal.withAlpha(120),
                      Colors.teal.withAlpha(60),
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
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
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      labelResolver: (line) =>       "pH ${pH.toStringAsFixed(2)}\n${CiderUtils.recommendedFreeSO2ppm(pH).round()} ppm",
                    ),
                  ),
                ],
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 40,
                  ),
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
}


// ############### Start of Unit Converter Tab ###############

class UnitConverterTab extends StatelessWidget {
  const UnitConverterTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: const [
          TabBar(
            tabs: [
              Tab(text: "Volume"),
              Tab(text: "Mass"),
              Tab(text: "Temperature"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                UnitConverterCategoryTab(category: 'Volume'),
                UnitConverterCategoryTab(category: 'Mass'),
                UnitConverterCategoryTab(category: 'Temperature'),
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
    }
  }

  List<String> getUnits() {
    if (widget.category == 'Volume') return volumeUnits.keys.toList();
    if (widget.category == 'Mass') return massUnits.keys.toList();
    return tempUnits;
  }

  double convert() {
    if (widget.category == 'Temperature') {
      return _convertTemp(inputValue, fromUnit, toUnit);
    }
    final units = widget.category == 'Volume' ? volumeUnits : massUnits;
    double baseValue = inputValue * units[fromUnit]!;
    return baseValue / units[toUnit]!;
  }

  double _convertTemp(double val, String from, String to) {
    if (from == to) return val;
    if (from == '°C') return to == '°F' ? val * 9 / 5 + 32 : val + 273.15;
    if (from == '°F') return to == '°C' ? (val - 32) * 5 / 9 : (val - 32) * 5 / 9 + 273.15;
    if (from == 'K') return to == '°C' ? val - 273.15 : (val - 273.15) * 9 / 5 + 32;
    return val;
  }

String getFormulaHint() {
  if (widget.category == 'Temperature') {
    return "Uses standard temperature conversion formulas.";
  }

  final Map<String, double> unitMap =
      widget.category == 'Mass' ? massUnits : volumeUnits;

  final fromFactor = unitMap[fromUnit]!;
  final toFactor = unitMap[toUnit]!;

  final multiplier = fromFactor / toFactor;
  return "1 $fromUnit = ${multiplier.toStringAsFixed(3)} $toUnit";
}

String formatNumber(double value) {
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
