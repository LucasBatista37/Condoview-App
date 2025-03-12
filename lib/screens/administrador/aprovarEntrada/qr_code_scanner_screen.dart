import 'package:condoview/screens/administrador/aprovarEntrada/aprovar_entrada_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScannerScreen extends StatefulWidget {
  const QRCodeScannerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _QRCodeScannerScreenState createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 78, 20, 166),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Escanear QR Code',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              final String qrData = barcode.rawValue!;
              verificarQRCode(context, qrData);
            } else {
            }
          }
        },
      ),
    );
  }

  void verificarQRCode(BuildContext context, String qrData) {
    try {
      final Map<String, dynamic> dados = jsonDecode(qrData);

      final String data = dados['data'];
      final String hora = dados['hora'];


      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultadoQRCodeScreen(data: data, hora: hora),
        ),
      );
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao decodificar QR Code: $e")),
      );
    }
  }
}
