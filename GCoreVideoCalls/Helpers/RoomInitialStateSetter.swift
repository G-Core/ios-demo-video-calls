//
//  RoomInitialStateSetter.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 03.05.2022.
//

import Foundation
import GCoreVideoCallsSDK

struct RoomInitialStateSetter {
    static func initialPermissions(_ permissions: [MediaTrackKind: Bool],
                                   for model: GCModel,
                                   and controlButtons: GCVideoCallControlButtonsView) {
        
        model.roomSettings.audioIsEnable = permissions[.audio] ?? false
        model.roomSettings.videoIsEnable = permissions[.video] ?? false
        model.roomSettings.shareIsEnable = permissions[.share] ?? false
        
        guard !model.userSettings.isModerator else { return }
        
        if !model.roomSettings.audioIsEnable {
            model.userSettings.audioIsOn = false
            model.localVideoItem.hasMicrophone = false
            controlButtons.changeButtonState(button: .microphone, to: .unavailable)
        }
        
        if !model.roomSettings.videoIsEnable {
            model.userSettings.videoIsOn = false
            model.localVideoItem.hasCamera = false
            controlButtons.changeButtonState(button: .camera, to: .unavailable)
        }
    }
    
    static func initLocalUserInfo(_ info: UpdateMeInfoObject, for model: GCModel) {
        let user = User(id: info.peerId, name: info.displayName)
        let item = RemoteVideoItem(userData: user)
        
        model.localVideoItem = item
        model.userSettings.isModerator = info.role == "moderator"
        model.roomSettings.waitingRoomIsEnable = info.waitingRoom
    }
}
