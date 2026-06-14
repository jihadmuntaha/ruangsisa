import 'package:get/get.dart';

import '../modules/add_post/bindings/add_post_binding.dart';
import '../modules/add_post/views/add_post_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/main_wrapper/bindings/main_wrapper_binding.dart';
import '../modules/main_wrapper/views/main_wrapper_view.dart';
import '../modules/message/bindings/message_binding.dart';
import '../modules/message/views/message_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // Jadikan MainWrapper sebagai halaman pertama yang dibuka
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.MAIN_WRAPPER,
      page: () => const MainWrapperView(),
      binding: MainWrapperBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: _Paths.ADD_POST,
      page: () => const AddPostView(),
      binding: AddPostBinding(),
    ),
    GetPage(
      name: _Paths.MESSAGE,
      page: () => const MessageView(),
      binding: MessageBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
  ];
}
