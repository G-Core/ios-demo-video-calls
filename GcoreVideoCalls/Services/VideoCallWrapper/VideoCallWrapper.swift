import GCoreVideoCallsSDK

final class VideoCallWrapper: VideoCallWrapperProtocol {
    // MARK: - Public properties
    weak var delegate: VideoCallWrapperDelegate?

    var gcMeet = GCoreMeet.shared
    var roomPermissions = (audio: false, video: false)
    var isExeting = false

    var remoteUsers: [RemoteUser] = [] {
        didSet { delegate?.updateData() }
    }

    //MARK: - Private properties
    private var userVideoState = true

    // MARK: - Init
    init() {
        setupMeet()
        subscribeNotification()
    }

    // MARK: - Private methods
    private func setupMeet() {
        GCoreRoomLogger.activateLogger()
        gcMeet.audioSessionActivate()

        guard let id = RoomConfigurator.roomId else { return }

        let userParams = GCoreLocalUserParams(name: RoomConfigurator.userName ?? "No name", role: .common)
        let roomParams = GCoreRoomParams(id: id, host: RoomConfigurator.host)

        gcMeet.connectionParams = (userParams, roomParams)
        gcMeet.roomListener = self

        try? gcMeet.startConnection()
    }

    private func findIndexFor(userId: String?) -> Int? {
        guard let userId else { return 0 }
        return remoteUsers.firstIndex {  $0.id == userId  }
    }

    private func subscribeNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActiveNotification(_:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc
    private func willResignActiveNotification(_ notification: NSNotification) {
        if let index = findIndexFor(userId: gcMeet.localUser?.id) {
            userVideoState = remoteUsers[index].isVideoEnable
            remoteUsers[index].isVideoEnable = false
            gcMeet.localUser?.toggleCam(isOn: false)
        }
    }

    @objc
    private func didBecomeActiveNotification(_ notification: NSNotification) {
        if let index = findIndexFor(userId: gcMeet.localUser?.id) {
            remoteUsers[index].isVideoEnable = userVideoState
            remoteUsers[index].isVideoEnable = userVideoState

            gcMeet.localUser?.toggleCam(isOn: userVideoState)
            delegate?.updateData()
        }
    }
}

//MARK: - RoomListener methods
extension VideoCallWrapper: GCoreRoomListener {
    func roomClientHandle(error: GCoreVideoCallsSDK.GCoreRoomError) {
        let nsError = error as NSError
        switch error {
        case .cameraPermissionNotGranted:
            Logger.log("Camera granted error - \(nsError.description)")

        case .invalidSocketURL:
            Logger.log("Invalid URL - \(nsError.description)")

        case .invalidUserId:
            Logger.log("Invalid user ID - \(nsError.description)")

        case .microPermissionNotGranted:
            Logger.log("Micro granted error - \(nsError.description)")

        case .missingConnectionParams:
            Logger.log("Connection error - \(nsError.description)")

        case .fatalError(let error):
            switch error {
            case HTTPUpgradeError.notAnUpgrade(502):
                Logger.log("HTTPUpgradeError.notAnUpgrade(502)")
                try? gcMeet.startConnection()
            case HTTPUpgradeError.notAnUpgrade(500):
                Logger.log("HTTPUpgradeError.notAnUpgrade(500)")
                try? gcMeet.startConnection()
            default:
                Logger.log("Fatal error - \((error as NSError).description)")
            }

        @unknown default:
            Logger.log("Unknown error - \((error as NSError).description)")
        }
    }

    func roomClientHandle(_ client: GCoreVideoCallsSDK.GCoreRoomClient, forAllRoles joinData: GCoreVideoCallsSDK.GCoreJoinData) {
        switch joinData {
        case .othersInRoom(remoteUsers: let otherUsers):
            for user in otherUsers {
                if !remoteUsers.contains(where: { $0.id == user.id }) {
                    remoteUsers.append(RemoteUser(name: user.name, id: user.id))
                }
            }

        case .permissions(mediaStreams: let permissions):
            let audio = permissions.audio
            let video = permissions.video

            roomPermissions.video = video
            roomPermissions.audio = audio

            for index in remoteUsers.indices {
                remoteUsers[index].isVideoEnable = video
                remoteUsers[index].isMicroEnable = audio
            }

            delegate?.updateRoomPermissions()

        default:
            return
        }
    }

    func roomClientHandle(_ client: GCoreVideoCallsSDK.GCoreRoomClient, remoteUsersEvent: GCoreVideoCallsSDK.GCoreRemoteUsersEvent) {
        switch remoteUsersEvent {
        case .handleRemote(user: let remoteUser):
            remoteUsers += [RemoteUser(name: remoteUser.name, id: remoteUser.id)]

        case .changeName(userId: let id, new: let newName, old: _):
            if let index = findIndexFor(userId: id) {
                remoteUsers[index].name = newName
            }

        case .activeSpeaker(remoteUserIds: let speakerIds):
            for index in remoteUsers.indices {
                remoteUsers[index].isSpeaking = speakerIds.contains(remoteUsers[index].id)
            }

            remoteUsers = remoteUsers.sorted {
                let firstUser = speakerIds.contains($0.id) ? 1 : 0
                let secondUser = speakerIds.contains($1.id) ? 1 : 0
                return firstUser > secondUser
            }

            delegate?.updatePinnedUser()

        case .closedRemote(userId: let id):
            remoteUsers.removeAll { $0.id == id }

        case .userSleep(id: _, isSleeping: _):
            return

        @unknown default:
            fatalError("Unknown remoteUsersEvent")
        }
    }

    func roomClientHandle(_ client: GCoreVideoCallsSDK.GCoreRoomClient, mediaEvent: GCoreVideoCallsSDK.GCoreMediaEvent) {
        switch mediaEvent {
        case .handledRemoteVideo(videoObject: let videoObject):
            let userId = videoObject.userId

            if let index = self.findIndexFor(userId: userId) {
                self.remoteUsers[index].isVideoEnable = true

                let remoteUser = self.remoteUsers[index]

                videoObject.rtcVideoTrack.add(remoteUser.view)
            }

        case .produceLocalVideo(track: let videoTrack):
            if let index = findIndexFor(userId: gcMeet.localUser?.id) {
                remoteUsers[index].isVideoEnable = true
                let remoteUser = remoteUsers[index]
                videoTrack.add(remoteUser.view)
            }

        case .didCloseLocalVideo(track: let videoTrack):
            if !isExeting {
                if let index = findIndexFor(userId: gcMeet.localUser?.id) {
                    videoTrack?.remove(remoteUsers[index].view)
                }
            }
        case .produceRemoteAudio(audioObject: let audioObject):
            if let index = findIndexFor(userId: audioObject.userId) {
                remoteUsers[index].isSpeaking = true
                remoteUsers[index].isMicroEnable = true
            }

        case .didCloseLocalAudio(track: _):
            if !isExeting {
                if let index = findIndexFor(userId: gcMeet.localUser?.id) {
                    remoteUsers[index].isSpeaking = false
                }
            }

        case .produceLocalAudio(track: _):
            for index in remoteUsers.indices {
                if remoteUsers[index].id == gcMeet.localUser?.id {
                    remoteUsers[index].isMicroEnable = true
                    remoteUsers[index].isSpeaking = true
                }
            }

        case .didCloseRemoteAudio(byModerator: _, audioObject: let audioObject):
            if let index = findIndexFor(userId: audioObject.userId) {
                remoteUsers[index].isSpeaking = false
                remoteUsers[index].isMicroEnable = false
            }

        case .didCloseRemoteVideo(byModerator: _, videoObject: let videoObject):
            if let index = findIndexFor(userId: videoObject.userId) {
                videoObject.rtcVideoTrack.remove(remoteUsers[index].view)

                remoteUsers[index].isVideoEnable = false
            }

        case .disableProducerByModerator(media: let mediaKind):
            switch mediaKind {
            case .video: roomPermissions.video = false
            case .audio: roomPermissions.audio = false
            default: return
            }

            delegate?.updateRoomPermissions()

        case .togglePermissionsByModerator(kind: let mediaKind, status: let status):
            switch mediaKind {
            case .audio: roomPermissions.audio = status
            case .video: roomPermissions.video = status
            default: return
            }

            delegate?.updateRoomPermissions()

        default:
            return
        }

        delegate?.updateData()
    }

    func roomClientHandle(_ client: GCoreVideoCallsSDK.GCoreRoomClient, connectionEvent: GCoreVideoCallsSDK.GCoreRoomConnectionEvent) {
        switch connectionEvent {

        case .startToConnectWithServices:
            print("user with id \(gcMeet.localUser?.id ?? "no user id") start To Connect With Services")

        case .successfullyConnectWithServices:
            print("user with id \(gcMeet.localUser?.id ?? "no user id") successfully Connect With Services")

            delegate?.updateUserPermissions()
            delegate?.updateLocalUser()

        case .didConnected:
            print("user with id \(gcMeet.localUser?.id ?? "no user id") did Connected")

        case .reconnecting:
            print("user with id \(gcMeet.localUser?.id ?? "no user id") reconnecting")
            if !isExeting {
                try? gcMeet.startConnection()
            }

        case .reconnectingFailed:
            print("user with id \(gcMeet.localUser?.id ?? "no user id") reconnecting Failed")
            if !isExeting {
                try? gcMeet.startConnection()
            }

        case .socketDidDisconnected:
            print("user with id \(gcMeet.localUser?.id ?? "no user id") socket Did Disconnected")

        case .waitingForModeratorJoinAccept:
            print("user with id \(gcMeet.localUser?.id ?? "no user id") waiting For Moderator Join Accept")

        case .moderatorRejectedLocalJoinRequest:
            print("user with id \(gcMeet.localUser?.id ?? "no user id") moderator Rejected Local Join Request")

        case .removedByModerator:
            print("user with id \(gcMeet.localUser?.id ?? "no user id") removed By Moderator")

        @unknown default:
            print("@unknown default")
        }
    }

    func roomClient(_ client: GCoreVideoCallsSDK.GCoreRoomClient, waitingRoomIsActive: Bool) {

    }

    func roomClient(_ client: GCoreVideoCallsSDK.GCoreRoomClient, captureSession: AVCaptureSession, captureDevice: AVCaptureDevice) {

    }
}
