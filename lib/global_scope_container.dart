import 'package:firebase_auth/firebase_auth.dart';
import 'package:injector/injector.dart';
import 'package:todointernship/data/flickr_api_service.dart';
import 'package:todointernship/data/image_manager.dart';
import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/data/theme_list_data.dart';
import 'package:todointernship/platform_channel/notifiaction_channel.dart';

class GlobalScopeContaier {

  final _injector = Injector.appInstance;

  void init() {
    _injector.registerSingleton<FlickrApiService>((injector) => FlickrApiService.shared);
    _injector.registerSingleton<FirebaseAuth>((injector) => FirebaseAuth.instance);
    _injector.registerSingleton<TaskRepository>((injector) => TaskDatabaseRepository.shared);
    _injector.registerSingleton<ThemeListData>((injector) => ThemeListData.all);
    _injector.registerSingleton<ImageManager>((injector) => ImageManager.shared);
    _injector.registerDependency<SharedPrefManager>((injector) => SharedPrefManager());
    _injector.registerDependency<PlatformNotificationChannel>((injector) => PlatformNotificationChannel());
  }
}