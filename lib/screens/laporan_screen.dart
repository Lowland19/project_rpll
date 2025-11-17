import 'package:flutter/material.dart';
import 'package:project_rpll/screens/detil_laporan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final _future = Supabase.instance.client.from('laporan').select();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Pelaporan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final laporan = snapshot.data!;

          return ListView.builder(
            itemCount: laporan.length,
            itemBuilder: (context, index) {
              final l = laporan[index];
              return Card(
                child: ListTile(
                  title: Text(l['penerima_manfaat']),
                  subtitle: Text("Kelayakan: ${l['persen_kelayakan'].toString()}"),
                  trailing: Image.network(l['gambar']),
                  onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> DetilLaporan(), settings: RouteSettings(
                      arguments: l['id']
                  )));}
                ),
              );
            },
          );
        },
      ),
    );
  }
}
