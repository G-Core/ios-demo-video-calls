//
//  GCModel.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 31.03.2022.
//

import Foundation
import AVFoundation

final class GCModel {
    var userName = ""
    
    var roomData: (
        url: URL?,
        host: String,
        id: String
    )
    
    var userSettings: (
        audioIsOn: Bool,
        videoIsOn: Bool,
        isModerator: Bool,
        cameraPosition: AVCaptureDevice.Position?
    )
    
    var roomSettings: (
        audioIsEnable: Bool,
        shareIsEnable: Bool,
        videoIsEnable: Bool,
        waitingRoomIsEnable: Bool
    )
    
    var moderatorRoom = ModeratorRoom()
    
    var localVideoItem: RemoteVideoItem!
    var remoteVideoItems: [RemoteVideoItem] = []
    
    let lock = NSLock()
    
    static let shared = GCModel()
    
    private init() {
        roomData = (nil, "", "")
        userSettings = (false, false, false, .front)
        roomSettings = (true, true, true, false)
    }
    
    func deleteUserFromWaitingRoom(id: String) {
        moderatorRoom.waitingUsers.removeAll(where: { $0.id == id })
    }
    
    func deleteUserFromRequestsRoom(id: String, type request: MediaTrackKind) {
        moderatorRoom.requestsUsers.removeAll {
            $0.user.id == id && $0.media == request
        }
    }
    
    func findIndexFor(peerId: String) -> Int? {
        defer { lock.unlock() }
        lock.lock()
        
        return remoteVideoItems.firstIndex {
            $0.userData.id == peerId
        }
    }
}

struct ModeratorRoom {
    var waitingUsers: [User] = []
    var requestsUsers: [(user: User, media: MediaTrackKind)] = []
}

struct User {
    let id: String
    let name: String
}


