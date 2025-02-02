import 'package:get/get.dart';
import 'package:tencent_conference_uikit/common/index.dart';
import 'package:tencent_conference_uikit/manager/rtc_engine_manager.dart';
import 'package:tencent_conference_uikit/pages/conference_main/index.dart';
import 'package:rtc_room_engine/api/common/tui_common_define.dart';
import 'package:rtc_room_engine/api/room/tui_room_define.dart';

import '../widgets.dart';

class ExitController extends GetxController {
  ExitController();

  final RoomEngineManager _engineManager = RoomEngineManager();
  final conferenceMainController = Get.find<ConferenceMainController>();

  void exitRoomAction() async {
    if (!isRoomOwner()) {
      _exitRoom();
      return;
    }

    if(RoomStore.to.userInfoList.length > 2){
      showConferenceBottomSheet(const TransferHostWidget());
      return;
    }

   if (RoomStore.to.userInfoList.length == 2) {
      var nextOwnerId = RoomStore.to.userInfoList
          .firstWhere((element) =>
              element.userId.value != RoomStore.to.currentUser.userId.value)
          .userId
          .value;
      var result =
          await _engineManager.changeUserRole(nextOwnerId, TUIRole.roomOwner);
      if (result.code == TUIError.success) {
        _exitRoom();
        return;
      }
    }
    _exitRoom();
  }

  void destroyRoomAction() {
    conferenceMainController.conferenceObserver?.onConferenceFinished
        ?.call(RoomStore.to.roomInfo.roomId);
    _engineManager.destroyRoom();
    Get.back();
  }

  void _exitRoom() {
    conferenceMainController.conferenceObserver?.onConferenceExited
        ?.call(RoomStore.to.roomInfo.roomId);
    _engineManager.exitRoom();
    Get.back();
  }

  bool isRoomOwner() {
    return RoomStore.to.currentUser.userRole.value == TUIRole.roomOwner;
  }
}
