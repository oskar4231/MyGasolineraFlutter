import 'package:flutter_dotenv/flutter_dotenv.dart';

final int switchBackend =
    int.tryParse(dotenv.env['SWITCH_BACKEND'] ?? '0') ?? 0;
// 0 = Localhost(backend local)
// 1 = Ngrok(backend a distancia)
