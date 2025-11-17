import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetilLaporan extends StatelessWidget {
  const DetilLaporan({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as int;

    final _futureDetil = Supabase.instance.client
        .from('laporan')
        .select()
        .eq('id', id).single();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder(
        future: _futureDetil,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final detillaporan = snapshot.data!;

          return Padding(padding: EdgeInsets.all(16), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detillaporan['penerima_manfaat'].toString(),),
              SizedBox(height: 16,),
              Text("Kelayakan: ${detillaporan['persen_kelayakan']}%"),
              SizedBox(height: 16,),
              Text("Tanggal: ${detillaporan['tanggal_pelaporan']}"),
              SizedBox(height: 16,),
              Text("Deskripsi: ${detillaporan['deskripsi']}"),
              SizedBox(height: 16,),
              Image.network(detillaporan['gambar'])
            ],
          ));
        },
      ),
    );
  }
}
