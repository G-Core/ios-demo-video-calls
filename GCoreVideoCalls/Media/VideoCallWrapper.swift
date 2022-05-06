//
//  VideoCallModule.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 22.03.2022.
//

import WebRTC
import GCoreVideoCallsSDK
import UIKit

enum MediaTrackKind: String {
    case video, share, audio
}

struct RemoteVideoItem {
    let userData: User
    let videoView = RTCEAGLVideoView()
    
    var trackId: String?
    var hasMicrophone: Bool = false
    var hasCamera: Bool = false
    var isSpeak: Bool = false
    
    init(userData: User) {
        self.userData = userData
    }
}

protocol RoomModerator: AnyObject {
    func userJoinInWaitingRoom(_ user: User)
    func requestToModerator(_ mediaKind: MediaTrackKind, from user: User)
}

protocol VideoCallWrapperDelegate: AnyObject {
    var presetCallSettings: (isAudioOn: Bool, isVideoOn: Bool) { get }
    
    // peers
    func didCreateRemoteItems(_ items: [RemoteVideoItem])
    func handlePeer(_ item: RemoteVideoItem)
    func peerClosed(_ peerId: String)
    func talkingUsers(_ peers: [String])
    
    // connection
    func connectionProccess(state: VideoCallConnectionState)
    
    // by moderator
    func togglePermissions(track: MediaTrackKind, isEnabled: Bool)
    func requestByModerator(_ mediaKind: MediaTrackKind)
    func removeTrackByModerator(_ media: MediaTrackKind)
    
    // media
    func changeLocalVideo(_ videoTrack: RTCVideoTrack?, isClose: Bool)
    func changeLocalAudio(_ audioTrack: RTCAudioTrack?, isClose: Bool)
    func didAddVideoTrack(_ videoObject: VideoObject)
    func videoChangeFor(_ peerId: String, isClose: Bool)
    func audioChangeFor(_ peerId: String, isClose: Bool)
    
    
    // other
    func initialPermissions(tracks: [MediaTrackKind: Bool])
    func didReceiveUserInfo(_ info: UpdateMeInfoObject)
}

enum VideoCallConnectionState {
    case start, successConnectToServices, connected, reconnecting, reconnectingFailed
    case disconnecting, removedByModerator, waitingForModeratorJoinAccept, moderatorRejectedJoinRequest
}

final class VideoCallWrapper: RoomListener {
    private(set) var client: GCoreRoomClient?
    weak var delegate: VideoCallWrapperDelegate?
    weak var moderator: RoomModerator?
    var isDisconnected = false
    
    init(roomID: String,
         displayName: String,
         cameraPosition: AVCaptureDevice.Position,
         peerId: String? = nil,
         clientHostName: String? = nil,
         isModerator: Bool = false) {
        
        GCoreRoomLogger.activateLogger()
        
        let options = RoomOptions(cameraPosition: cameraPosition)
        
        let parameters = MeetRoomParametrs(
            roomId: roomID,
            displayName: displayName,
            peerId: peerId,
            clientHostName: clientHostName,
            isModerator: isModerator
        )
        
        client = GCoreRoomClient(roomOptions: options, requestParameters: parameters, roomListener: self)
        client?.audioSessionActivate()
    }
}

//MARK: - RoomListener Peers
extension VideoCallWrapper {
    func roomClient(roomClient: GCoreRoomClient, joinWithPeersInRoom peers: [PeerObject]) {
        var remoteItems: [RemoteVideoItem] = []
        
        peers.forEach { peer in
            let user = User(id: peer.id, name: peer.displayName ?? "")
            let remoteItem = RemoteVideoItem(userData: user)
            remoteItems.append(remoteItem)
        }
        
        delegate?.didCreateRemoteItems(remoteItems)
    }
    
    func roomClient(roomClient: GCoreRoomClient, handlePeer: PeerObject) {
        let user = User(id: handlePeer.id, name: handlePeer.displayName ?? "")
        let remoteItem = RemoteVideoItem(userData: user)
        delegate?.handlePeer(remoteItem)
    }
    
    func roomClient(roomClient: GCoreRoomClient, peerClosed: String) {
        delegate?.peerClosed(peerClosed)
    }
    
    func roomClient(roomClient: GCoreRoomClient, activeSpeakerPeers peers: [String]) {
        delegate?.talkingUsers(peers)
    }
}

//MARK: - RoomListener Connection
extension VideoCallWrapper {
    func roomClientStartToConnectWithServices() {
        delegate?.connectionProccess(state: .start)
    }
    
    func roomClientSuccessfullyConnectWithServices() {
        delegate?.connectionProccess(state: .successConnectToServices)
    }
    
    func roomClientDidConnected() {
        delegate?.connectionProccess(state: .connected)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self,
                  let delegate = self.delegate
            else { return }
            
            self.client?.toggleVideo(isOn: delegate.presetCallSettings.isVideoOn)
            self.client?.toggleAudio(isOn: delegate.presetCallSettings.isAudioOn)
        }
    }
    
    func roomClientReconnecting() {
        delegate?.connectionProccess(state: .reconnecting)
    }
    
    func roomClientReconnectingFailed() {
        delegate?.connectionProccess(state: .reconnectingFailed)
    }
    
    func roomClientSocketDidDisconnected(roomClient: GCoreRoomClient) {
        delegate?.connectionProccess(state: .disconnecting)
        isDisconnected = true
    }
    
    func roomClientRemovedByModerator() {
        delegate?.connectionProccess(state: .removedByModerator)
    }
    
    func roomClientWaitingForModeratorJoinAccept() {
        delegate?.connectionProccess(state: .waitingForModeratorJoinAccept)
    }
    
    func roomClientModeratorRejectedJoinRequest() {
        delegate?.connectionProccess(state: .moderatorRejectedJoinRequest)
    }
}

//MARK: - RoomListener moderator
extension VideoCallWrapper {
    func roomClient(roomClient: GCoreRoomClient, toggleByModerator kind: String, status: Bool) {
        guard let media = MediaTrackKind.init(rawValue: kind) else { return }
        delegate?.togglePermissions(track: media, isEnabled: status)
    }
    
    func roomClient(roomClient: GCoreRoomClient, acceptedPermissionFromModerator fromModerator: Bool, peer: PeerObject, requestType: String) {
        guard let kind = MediaTrackKind.init(rawValue: requestType) else { return }
        delegate?.requestByModerator(kind)
    }
    
    func roomClient(roomClient: GCoreRoomClient, disableProducerByModerator peerClosed: String) {
        guard let media = MediaTrackKind.init(rawValue: peerClosed) else { return }
        delegate?.removeTrackByModerator(media)
    }
    
    func roomClient(roomClient: GCoreRoomClient, requestToModerator: RequestToModerator) {
        guard let media = MediaTrackKind.init(rawValue:  requestToModerator.requestType) else { return }
        let user = User(id: requestToModerator.peerId, name: requestToModerator.userName)
        moderator?.requestToModerator(media, from: user)
    }
    
    func roomClient(roomClient: GCoreRoomClient, moderatorIsAskedToJoin: ModeratorIsAskedToJoin) {
        let user = User(id: moderatorIsAskedToJoin.peerId, name: moderatorIsAskedToJoin.userName)
        moderator?.userJoinInWaitingRoom(user)
    }
}

//MARK: - RoomListener media
extension VideoCallWrapper {
    func roomClient(roomClient: GCoreRoomClient, produceLocalVideoTrack videoTrack: RTCVideoTrack) {
        delegate?.changeLocalVideo(videoTrack, isClose: false)
    }
    
    func roomClient(roomClient: GCoreRoomClient, produceLocalAudioTrack audioTrack: RTCAudioTrack) {
        delegate?.changeLocalAudio(audioTrack, isClose: false)
    }
    
    func roomClient(roomClient: GCoreRoomClient, didCloseLocalVideoTrack videoTrack: RTCVideoTrack?) {
        delegate?.changeLocalVideo(videoTrack, isClose: true)
    }
    
    func roomClient(roomClient: GCoreRoomClient, didCloseLocalAudioTrack audioTrack: RTCAudioTrack?) {
        delegate?.changeLocalAudio(audioTrack, isClose: true)
    }
    
    func roomClient(roomClient: GCoreRoomClient, handledRemoteVideo videoObject: VideoObject) {
        self.delegate?.didAddVideoTrack(videoObject)
        self.delegate?.videoChangeFor(videoObject.peerId, isClose: false)
    }
    
    func roomClient(roomClient: GCoreRoomClient, produceRemoteAudio audioObject: AudioObject) {
        delegate?.audioChangeFor(audioObject.peerId, isClose: false)
    }
    
    func roomClient(roomClient: GCoreRoomClient, didCloseRemoteVideoByModerator byModerator: Bool, videoObject: VideoObject) {
        delegate?.videoChangeFor(videoObject.peerId, isClose: true)
    }
    
    func roomClient(roomClient: GCoreRoomClient, didCloseRemoteAudioByModerator byModerator: Bool, audioObject: AudioObject) {
        delegate?.audioChangeFor(audioObject.peerId, isClose: true)
    }
}

//MARK: - RoomListener Other
extension VideoCallWrapper {
    func roomClient(roomClient: GCoreRoomClient, joinPermissions: JoinPermissionsObject) {
        let permissions: [MediaTrackKind: Bool] = [
            .audio : joinPermissions.audio,
            .video : joinPermissions.video,
            .share : joinPermissions.share
        ]
        
        delegate?.initialPermissions(tracks: permissions)
    }
    
    func roomClient(roomClient: GCoreRoomClient, updateMeInfo: UpdateMeInfoObject) {
        delegate?.didReceiveUserInfo(updateMeInfo)
    }
    
    func roomClient(roomClient: GCoreRoomClient, captureSession: AVCaptureSession, captureDevice: AVCaptureDevice) {
        
    }
    
    func roomClientHandle(error: RoomError) {
        NSLog(error.localizedDescription)
    }
}
