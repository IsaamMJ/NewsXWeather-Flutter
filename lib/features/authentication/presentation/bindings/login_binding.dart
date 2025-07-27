import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controller/login_controller.dart';
import '../../data/datasource/auth_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecase/login_usecase.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Inject the AuthDataSource
    Get.lazyPut<AuthDataSource>(() => AuthDataSource(FirebaseAuth.instance));

    // Inject the AuthRepository with the AuthDataSource
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(Get.find<AuthDataSource>()));

    // Inject the LoginUseCase
    Get.lazyPut(() => LoginUseCase(Get.find<AuthRepository>()));

    // Inject the LoginController
    Get.lazyPut(() => LoginController(Get.find<LoginUseCase>()));
  }
}
