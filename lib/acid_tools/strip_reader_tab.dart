import 'package:flutter/material.dart';

class StripReaderTab extends StatefulWidget {
  const StripReaderTab({super.key});

  @override
  State<StripReaderTab> createState() => _StripReaderTabState();
}

class _StripReaderTabState extends State<StripReaderTab> {
  String? selectedBrand;
  final List<String> knownBrands = [
    'Viva pH 4.0–7.0',
    'Hydrion pH 3.0–5.5',
    'Universal pH 1.0–14.0',
    'Custom / Not Listed',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "pH Strip Reader",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline),
                tooltip: "How this works",
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("How this works"),
                    content: const Text(
                      "This tool uses image analysis and interpolation to estimate pH based on a photographed test strip and reference color key.\n\n"
                      "Start by selecting your pH strip brand. Then upload or capture a photo with the reference key and test strip together. "
                      "You will be prompted to click the reference colors and assign their pH values, then click the test strip color.",
                    ),
                    actions: [
                      TextButton(
                        child: const Text("OK"),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text("1. Select your pH strip brand:"),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedBrand,
            items: knownBrands
                .map((brand) =>
                    DropdownMenuItem(value: brand, child: Text(brand)))
                .toList(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Choose a brand",
            ),
            onChanged: (val) => setState(() => selectedBrand = val),
          ),

          const SizedBox(height: 24),
          const Text("2. Upload or capture photo:"),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.photo_camera),
            label: const Text("Take or Upload Photo"),
            onPressed: () {
              // TODO: Implement photo capture/upload
            },
          ),

          const SizedBox(height: 24),
          const Text("3. Annotate the reference key:"),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.colorize),
            label: const Text("Mark reference colors"),
            onPressed: () {
              // TODO: Launch color picker or annotation
            },
          ),

          const SizedBox(height: 24),
          const Text("4. Select test strip color:"),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.opacity),
            label: const Text("Click test strip color"),
            onPressed: () {
              // TODO: Implement test strip color selection
            },
          ),

          const SizedBox(height: 24),
          const Text("Estimated pH:"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "—",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
