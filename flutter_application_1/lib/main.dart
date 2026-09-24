import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'map_screen.dart';

const mapboxToken = String.fromEnvironment('ACCESS_TOKEN');
 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://mdapxbnexmlcsthnhwld.supabase.co',
    anonKey: 'sb_publishable_KfPOR81pHX-Jlzmtg24JfA_Ey6M54hw',
  );
  debugPrint('Mapbox token length: ${mapboxToken.length}');
  MapboxOptions.setAccessToken(mapboxToken); 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const NeshtoPage(),
    );
  }
}

class NeshtoPage extends StatefulWidget {
  const NeshtoPage({super.key});

  @override
  State<NeshtoPage> createState() => _NeshtoPageState();
}

class _NeshtoPageState extends State<NeshtoPage> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getData() async {
    final data = await supabase
        .from('neshto')
        .select('*');

    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neshto'),
        actions:[
          IconButton(
            icon: const Icon(Icons.map),
            onPressed:(){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen())
              );  
            },
          ),
        ],  
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final rows = snapshot.data ?? [];

          if (rows.isEmpty) {
            return const Center(
              child: Text('No data found'),
            );
          }

          return ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final row = rows[index];

              return ListTile(
                title: Text('ID: ${row['id']}'),
                subtitle: Text('Clicks: ${row['click']}'),
              );
            },
          );
        },
      ),
    );
  }
}