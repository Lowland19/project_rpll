import 'package:flutter/material.dart';
import 'package:project_rpll/providers/auth_provider.dart';
import 'package:project_rpll/screens/laporan_screen.dart';
import 'package:provider/provider.dart';

class HomeScreenWidget extends StatelessWidget {
  const HomeScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final userName = user?.userMetadata?['name'] ?? 'Pengguna';

    return Padding(
      padding: EdgeInsetsGeometry.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Selamat Datang,",style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),),
          SizedBox(height: 16,),
          Text('$userName', style: TextStyle(fontSize: 32,fontWeight: FontWeight.w400),),
          SizedBox(height: 32,),
          Expanded(
            child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              children: [
                Card(
                  elevation: 3,
                  child: InkWell(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LaporanScreen()),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book),
                        SizedBox(height: 24,),
                        Text('Laporan')
                      ],
                    ),
                  )
                ),
                Card(
                    elevation: 3,
                    child: InkWell(
                      onTap: (){},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping),
                          SizedBox(height: 24,),
                          Text('Pengiriman')
                        ],
                      ),
                    )
                ),
                Card(
                    elevation: 3,
                    child: InkWell(
                      onTap: (){},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search),
                          SizedBox(height: 24,),
                          Text('Pemeriksaan')
                        ],
                      ),
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
