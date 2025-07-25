import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controller/login_controller.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecase/login_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(FirebaseAuth.instance));
    Get.lazyPut(() => LoginUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => LoginController());
  }
}
