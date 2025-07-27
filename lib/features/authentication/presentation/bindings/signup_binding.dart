import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controller/sign_up_controller.dart';
import '../../data/datasource/auth_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecase/login_usecase.dart';
import '../../domain/usecase/signup_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy put for AuthDataSource, injected with FirebaseAuth instance
    Get.lazyPut<AuthDataSource>(() => AuthDataSource(FirebaseAuth.instance)); // Pass FirebaseAuth to AuthDataSource

    // Lazy put for AuthRepository, injected with AuthDataSource
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(Get.find<AuthDataSource>()));

    // Lazy put for SignUpUseCase, using the AuthRepository
    Get.lazyPut(() => SignUpUseCase(Get.find<AuthRepository>()));

    // Lazy put for LoginUseCase (in case it's needed, such as login after sign-up)
    Get.lazyPut(() => LoginUseCase(Get.find<AuthRepository>()));

    // Lazy put for SignUpController, injecting SignUpUseCase and LoginUseCase
    Get.lazyPut(() => SignUpController(Get.find<SignUpUseCase>(), Get.find<LoginUseCase>()));
  }
}
