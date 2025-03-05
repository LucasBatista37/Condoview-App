import 'package:condoview/screens/administrador/aprovarEntrada/aprovar_entrada_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScannerScreen extends StatefulWidget {
  @override
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
              print("QR code scanned: $qrData");
              verificarQRCode(context, qrData);
            } else {
              print("QR code is null");
            }
          }
        },
      ),
    );
  }

  void verificarQRCode(BuildContext context, String qrData) {
    print("Verificando QR code data: $qrData");
    try {
      final Map<String, dynamic> dados = jsonDecode(qrData);
      print("QR code data decoded successfully: $dados");

      final String data = dados['data'];
      final String hora = dados['hora'];

      print("Data: $data, Hora: $hora");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultadoQRCodeScreen(data: data, hora: hora),
        ),
      );
    } catch (e, stackTrace) {
      print("Erro ao decodificar QR Code: $e");
      print("Stack trace: $stackTrace");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao decodificar QR Code: $e")),
      );
    }
  }
}
