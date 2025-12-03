import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:project_rpll/screens/pengaduan/pengaduan_screen.dart';

class KameraPengaduanScreen extends StatefulWidget {
  const KameraPengaduanScreen({super.key});

  @override
  State<KameraPengaduanScreen> createState() => _KameraPengaduanScreenState();
}

class _KameraPengaduanScreenState extends State<KameraPengaduanScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription> cameras = [];

  Future<void> initCamera() async {
    cameras = await availableCameras();
    if (cameras.isEmpty) return;
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bukti Gambar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF3B0E0E),
      ),
      body: FutureBuilder<void>(future: _initializeControllerFuture, builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          return CameraPreview(_controller!);
        } else {
          return const Center(child: CircularProgressIndicator(),);
        }
      }),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        await _initializeControllerFuture;
        final image = await _controller!.takePicture();
        if(!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (context)=>PengaduanScreen(imagePath: image.path)));
      },),
    );
  }
}
