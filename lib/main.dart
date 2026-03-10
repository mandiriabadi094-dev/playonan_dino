import 'package:flame/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'widgets/hud.dart';
import 'game/saga_playonan.dart';
import 'models/settings.dart';
import 'widgets/main_menu.dart';
import 'models/player_data.dart';
import 'widgets/pause_menu.dart';
import 'widgets/settings_menu.dart';
import 'widgets/game_over_menu.dart';

Future<void> main() async {
  // Ensures that all bindings are initialized
  // before was start calling hive and flame code
  // dealing with platform channels.
  WidgetsFlutterBinding.ensureInitialized();

  // Initializes hive and register the adapters.
  await initHive();
  LicenseRegistry.addLicense(() async* {
    final audiowide = await rootBundle.loadString(
      'assets/fonts/Audiowide/OFL.txt',
    );
    final images = await rootBundle.loadString(
      'assets/images/readme.md',
    );
    final audio = await rootBundle.loadString(
      'assets/audio/readme.md',
    );
    yield LicenseEntryWithLineBreaks(
      ['Fonts: Audiowide'],
      audiowide,
    );
    yield LicenseEntryWithLineBreaks(
      ['Game Assets (Images)'],
      images,
    );
    yield LicenseEntryWithLineBreaks(
      ['Game Assets (Audio)'],
      audio,
    );
  });
  runApp(const SagaPlayonanApp());
}

// This function will initilize hive with apps documents directory.
// Additionally it will also register all the hive adapters.
Future<void> initHive() async {
  // For web hive does not need to be initialized.
  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  Hive.registerAdapter<PlayerData>(PlayerDataAdapter());
  Hive.registerAdapter<Settings>(SettingsAdapter());
}

// The main widget for this game.
class SagaPlayonanApp extends StatelessWidget {
  const SagaPlayonanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Saga Playonan',
      theme: ThemeData(
        fontFamily: 'Audiowide',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Settings up some default theme for elevated buttons.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            fixedSize: const Size(200, 60),
          ),
        ),
      ),
      home: Scaffold(
        body: GameWidget<SagaPlayonan>.controlled(
          // This will dislpay a loading bar until [SagaPlayonan] completes
          // its onLoad method.
          loadingBuilder: (conetxt) => const Center(
            child: SizedBox(width: 200, child: LinearProgressIndicator()),
          ),
          // Register all the overlays that will be used by this game.
          overlayBuilderMap: {
            MainMenu.id: (_, game) => MainMenu(game),
            PauseMenu.id: (_, game) => PauseMenu(game),
            Hud.id: (_, game) => Hud(game),
            GameOverMenu.id: (_, game) => GameOverMenu(game),
            SettingsMenu.id: (_, game) => SettingsMenu(game),
          },
          // By default MainMenu overlay will be active.
          initialActiveOverlays: const [MainMenu.id],
          gameFactory: () => SagaPlayonan(
            // Use a fixed resolution camera to avoid manually
            // scaling and handling different screen sizes.
            camera: CameraComponent.withFixedResolution(
              width: 360,
              height: 180,
            ),
          ),
        ),
      ),
    );
  }
}
