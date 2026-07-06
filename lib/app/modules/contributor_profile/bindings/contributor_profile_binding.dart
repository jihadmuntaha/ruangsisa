import 'package:get/get.dart';

import '../controllers/contributor_profile_controller.dart';

class ContributorProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContributorProfileController>(
      () => ContributorProfileController(),
    );
  }
}
