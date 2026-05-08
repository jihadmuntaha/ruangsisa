import 'package:get/get.dart';
import '../../home/controllers/navigation_controller.dart';

class MainWrapperBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NavigationController(), permanent: true);
  }
}