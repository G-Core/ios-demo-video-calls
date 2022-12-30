import GCoreVideoCallsSDK

protocol VideoCallWrapperDelegate: AnyObject {
    func updateData()
    func updateLocalUser()
    func updateRoomPermissions()
    func updateUserPermissions()
    func updatePinnedUser()
}

protocol VideoCallWrapperProtocol {
    var gcMeet: GCoreMeet { get set }
    var delegate: VideoCallWrapperDelegate? { get set }
    var remoteUsers: [RemoteUser] { get set }
    var roomPermissions: (audio: Bool, video: Bool) { get set}
    var isExeting: Bool { get set }
}
