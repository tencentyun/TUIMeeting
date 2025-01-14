//
//  UserReducer.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/5.
//

import RTCRoomEngine
import TUICore

let userReducer = Reducer<UserState>(
    ReduceOn(UserActions.getSelfInfo, reduce: { state, action in
        var selfInfo = UserInfo()
        selfInfo.userId = TUILogin.getUserID() ?? ""
        selfInfo.userName = TUILogin.getNickName() ?? ""
        selfInfo.avatarUrl = TUILogin.getFaceUrl() ?? ""
        state.selfInfo = selfInfo
    }),
    ReduceOn(UserActions.updateSelfInfo, reduce: { state, action in
        state.selfInfo = action.payload
    }),
    ReduceOn(UserActions.updateAllUsers, reduce: { state, action in
        state.allUsers = action.payload
    }),
    ReduceOn(UserActions.updateHasScreenStreamUsers, reduce: { state, action in
        state.hasScreenStreamUsers = action.payload
    }),
    ReduceOn(UserActions.updateDisableMessageUsers, reduce: { state, action in
        state.disableMessageUsers = action.payload
    })
)
