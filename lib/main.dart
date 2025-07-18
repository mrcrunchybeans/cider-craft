import 'package:flutter/material.dart';
import 'batch_log_page.dart';
import 'inventory_page.dart';
import 'recipe_builder_page.dart';
import 'settings_page.dart';
import 'tools_page.dart';


void main() {
  runApp(CiderCraftApp());
}

class CiderCraftApp extends StatelessWidget {
  const CiderCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CiderCraft',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedPage = 'Recipes';

  Widget _getPage() {
    switch (_selectedPage) {
      case 'Batches':
        return BatchLogPage(); // ✅
      case 'Inventory':
       return InventoryPage();
      case 'Tools':
        return ToolsPage();
      case 'Settings':
        return SettingsPage();
      case 'Recipes':
       default:
         return RecipeBuilderPage(); // ✅
  }
}

  void _selectPage(String page) {
    Navigator.pop(context); // close the drawer
    setState(() {
      _selectedPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CiderCraft – $_selectedPage')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: const Color.fromARGB(255, 108, 147, 73)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CiderCraft',
                      style: TextStyle(color: Colors.white, fontSize: 24)),
                  SizedBox(height: 8),
                  Text('Brian Petry – Premium',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Recipes'),
              onTap: () => _selectPage('Recipes'),
            ),
            ListTile(
              leading: Icon(Icons.local_drink),
              title: Text('Batches'),
              onTap: () => _selectPage('Batches'),
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text('Inventory'),
              onTap: () => _selectPage('Inventory'),
            ),
            ListTile(
              leading: Icon(Icons.science),
              title: Text('Tools'),
              onTap: () => _selectPage('Tools'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => _selectPage('Settings'),
            ),
          ],
        ),
      ),
      body: _getPage(),
    );
  }
}
// This is the main entry point of the CiderCraft app.
// It sets up the MaterialApp with a home screen that includes a navigation drawer.