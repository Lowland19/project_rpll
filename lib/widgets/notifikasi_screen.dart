import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool isLoading = true;
  List<dynamic> notifikasiList = [];

  @override
  void initState() {
    super.initState();
    fetchNotifikasi();
  }

  Future<void> fetchNotifikasi() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final response = await supabase
          .from("notifikasi")
          .select()
          .eq("user_id", user.id)
          .order("created_at", ascending: false);

      setState(() {
        notifikasiList = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("⚠ Error fetch notifikasi: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> tandaiSudahDibaca(String id) async {
    final supabase = Supabase.instance.client;

    await supabase
        .from("notifikasi")
        .update({"is_read": true})
        .eq("id", id);

    fetchNotifikasi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B0E0E),
        title: const Text("Notifikasi"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifikasiList.isEmpty
          ? const Center(
        child: Text(
          "Tidak ada notifikasi",
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifikasiList.length,
        itemBuilder: (context, index) {
          final item = notifikasiList[index];
          final bool isRead = item['is_read'] ?? false;

          return Card(
            color: isRead
                ? Colors.white
                : const Color(0xFFFFECEC), // merah muda untuk belum terbaca
            elevation: 2,
            child: ListTile(
              leading: Icon(
                Icons.notifications,
                color: isRead ? Colors.grey : Colors.red,
                size: 32,
              ),
              title: Text(
                item['judul'] ?? '',
                style: TextStyle(
                  fontWeight:
                  isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(item['isi'] ?? ''),
              trailing: isRead
                  ? null
                  : TextButton(
                onPressed: () =>
                    tandaiSudahDibaca(item['id']),
                child: const Text("Tandai dibaca"),
              ),
            ),
          );
        },
      ),
    );
  }
}
