
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const RobotApp());

class RobotApp extends StatelessWidget {
  const RobotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robot Kumanda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F6F8B),
          brightness: Brightness.dark,
        ),
      ),
      home: const KumandaSayfasi(),
    );
  }
}

class KumandaSayfasi extends StatefulWidget {
  const KumandaSayfasi({super.key});

  @override
  State<KumandaSayfasi> createState() => _KumandaSayfasiState();
}

class _KumandaSayfasiState extends State<KumandaSayfasi> {
  // ESP32'nin IP adresi. Seri monitörde görünen adresi buraya yaz.
  final TextEditingController _ipController =
      TextEditingController(text: '192.168.1.50');
  String _durum = 'Hazır';
  bool _hata = false;

  Future<void> _gonder(String komut) async {
    final ip = _ipController.text.trim();
    final url = Uri.parse('http://$ip/cmd?c=$komut');
    try {
      final cevap = await http.get(url).timeout(const Duration(seconds: 2));
      setState(() {
        _hata = cevap.statusCode != 200;
        _durum = _hata ? 'Hata: ${cevap.statusCode}' : 'Gönderildi: $komut';
      });
    } on TimeoutException {
      setState(() {
        _hata = true;
        _durum = 'ESP32 cevap vermedi. IP ve Wi-Fi bağlantısını kontrol et.';
      });
    } catch (e) {
      setState(() {
