import 'package:flutter/material.dart';
import 'ta_acid_calculator_tab.dart';
import 'ph_acid_calculator_tab.dart';
import 'strip_reader_tab.dart'; 

class AcidToolsPage extends StatelessWidget {
  const AcidToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Acid Tools"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.science), text: "pH"),
              Tab(icon: Icon(Icons.tune), text: "TA"),
              Tab(icon: Icon(Icons.photo_camera), text: "Strip Reader"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PhAcidCalculatorTab(),
            TaAcidCalculatorTab(),
            StripReaderTab(),
          ],
        ),
      ),
    );
  }
}
