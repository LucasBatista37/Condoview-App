import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:condoview/providers/assembleia_provider.dart';
import 'package:condoview/providers/chat_provider.dart';
import 'package:condoview/providers/encomenda_provider.dart';
import 'package:condoview/providers/manutencao_provider.dart';
import 'package:condoview/providers/ocorrencia_provider.dart';
import 'package:condoview/providers/aviso_provider.dart';
import 'package:condoview/providers/reserva_provider.dart';
import 'package:condoview/providers/usuario_provider.dart';
import 'package:condoview/providers/condominium_provider.dart';
import 'package:condoview/services/secure_storege_service.dart';
import 'package:condoview/screens/administrador/avisos/adicionar_avisos_screen.dart';
import 'package:condoview/screens/morador/chat/chat_geral_screen.dart';
import 'package:condoview/screens/morador/condominio/condominio_screen.dart';
import 'package:condoview/screens/morador/home/home_screen.dart';
import 'package:condoview/screens/morador/search/search_screen.dart';
import 'package:condoview/screens/morador/signup/signup_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UsuarioProvider()),
        ChangeNotifierProvider(create: (context) => AvisoProvider()),
        ChangeNotifierProvider(create: (context) => ReservaProvider()),
        ChangeNotifierProvider(create: (context) => ManutencaoProvider()),
        ChangeNotifierProvider(create: (context) => OcorrenciaProvider()),
        ChangeNotifierProvider(create: (context) => EncomendasProvider()),
        ChangeNotifierProvider(create: (context) => AssembleiaProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => CondoProvider()),
        Provider(create: (context) => SecureStorageService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    setupFCM();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsuarioProvider>(
      builder: (context, usuarioProvider, child) {
        final isAuthenticated = usuarioProvider.usuario != null;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CondoView',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
          ),
          initialRoute: isAuthenticated ? '/home' : '/signup',
          routes: {
            '/home': (context) => const HomeScreen(),
            '/search': (context) => const SearchScreen(),
            '/adicionar': (context) => const AdicionarAvisoScreen(),
            '/signup': (context) => const SignupScreen(),
            '/condominio': (context) => const CondominioScreen(),
            '/chat_geral': (context) => const ChatGeralScreen(),
          },
        );
      },
    );
  }

  void setupFCM() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    messaging.getToken().then((token) {
      print("FCM Token Atual: $token");
      Provider.of<UsuarioProvider>(context, listen: false)
          .saveFcmTokenToBackend();
    });

    messaging.onTokenRefresh.listen((newToken) {
      print("FCM Token Atualizado: $newToken");
      Provider.of<UsuarioProvider>(context, listen: false)
          .saveFcmTokenToBackend();
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Mensagem Recebida: ${message.notification?.title}");
    });
  }
}
