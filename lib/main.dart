import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/auth_repository_impl.dart';
import 'repositories/chat_repository.dart';
import 'repositories/chat_repository_impl.dart';
import 'services/api_client.dart';
import 'services/secure_token_storage.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final prefs = await SharedPreferences.getInstance();
  final tokenStorage = SecureTokenStorage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier(prefs)),
        Provider<SecureTokenStorage>.value(value: tokenStorage),
        Provider<ApiClient>(
          create: (_) => ApiClient(tokenStorage: tokenStorage),
          dispose: (_, client) => client.close(),
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            apiClient: context.read<ApiClient>(),
            tokenStorage: context.read<SecureTokenStorage>(),
          ),
        ),
        Provider<ChatRepository>(
          create: (context) => ChatRepositoryImpl(
            apiClient: ApiClient(
              tokenStorage: context.read<SecureTokenStorage>(),
              baseUri: Uri.parse(kAiApiBaseUrl),
            ),
          ),
          dispose: (_, repository) => repository.close(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              AuthNotifier(context.read<AuthRepository>())..restoreSession(),
        ),
      ],
      child: const FinTrackApp(),
    ),
  );
}
