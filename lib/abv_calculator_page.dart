import 'package:flutter/material.dart';
import '../utils/utils.dart';

class ABVCalculatorPage extends StatefulWidget {
  const ABVCalculatorPage({super.key});

  @override
  State<ABVCalculatorPage> createState() => _ABVCalculatorPageState();
}

class _ABVCalculatorPageState extends State<ABVCalculatorPage> {
  double fg = 1.000;
  double og = 1.050;
  bool useBetterFormula = true;

  @override
  Widget build(BuildContext context) {
    final abv = useBetterFormula
        ? CiderUtils.calculateABVBetter(og, fg)
        : CiderUtils.calculateABV(og, fg);

    return Scaffold(
      appBar: AppBar(
        title: const Text("ABV Calculator"),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Which ABV Formula Should I Use?"),
                content: const SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("There are two formulas you can use to calculate Alcohol by Volume (ABV):"),
                      SizedBox(height: 12),
                      Text(
                        "🔹 Simple Formula:\n  (OG - FG) × 131.25",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Use this if you're doing a quick check. It's great for hobby use and gets you in the ballpark.",
                      ),
                      SizedBox(height: 8),
                      Text(
                        "🔹 Better Formula:\n  [(76.08 × (OG - FG)) / (1.775 - OG)] × (FG / 0.794)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Use this if you want a more precise value — especially helpful for high-alcohol batches or commercial use. It accounts for real-world fermentation changes and gives slightly higher accuracy.",
                      ),
                      SizedBox(height: 12),
                      Text(
                        "💡 Tip:\nFor most cider and wine makers, the simple formula is close enough. But if you're labeling bottles, comparing batches, or just curious — try the better one!",
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text("Got it!"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SliderTile(
              label: "Original Gravity (OG)",
              value: og,
              onChanged: (val) => setState(() => og = val),
            ),
            SliderTile(
              label: "Final Gravity (FG)",
              value: fg,
              onChanged: (val) => setState(() => fg = val),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text("Use Better Formula (More Accurate)"),
              value: useBetterFormula,
              onChanged: (val) => setState(() => useBetterFormula = val),
            ),
            const SizedBox(height: 20),
            Text(
              "Estimated ABV: ${abv.toStringAsFixed(2)}%",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class SliderTile extends StatelessWidget {
  const SliderTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final void Function(double) onChanged;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          min: 0.990,
          max: 1.150,
          value: value,
          divisions: 160,
          label: value.toStringAsFixed(3),
          onChanged: onChanged,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(value.toStringAsFixed(3)),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
