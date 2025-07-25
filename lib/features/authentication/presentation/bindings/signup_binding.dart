import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controller/sign_up_controller.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecase/signup_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(FirebaseAuth.instance));
    Get.lazyPut(() => SignUpUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => SignUpController());
  }
}
