import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../controllers/profile_post_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<ProfilePostController>(() => ProfilePostController());
  }
}
