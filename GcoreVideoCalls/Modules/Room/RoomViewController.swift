import GCoreVideoCallsSDK

enum RoomState {
    case fullScreen, tile
}

protocol ActivityPresenterProtocol: AnyObject {
    func presentActivityVC()
}

final class RoomViewController: BaseViewController {
    // MARK: - Public properties
    var userPermissions: MediaPermissions! {
        didSet {
            mainView.configButtons(audio: userPermissions.audio, video: userPermissions.video)
            mainView.switchCameraButton.isHidden = !userPermissions.video
        }
    }

    var roomPermissions = MediaPermissions(audio: true, video: true){
        didSet {
            mainView.updatePermissons(permissoins: roomPermissions)
        }
    }

    var isFrontCameraPosition: Bool!

    // MARK: - Private properties
    private var state: RoomState = .tile {
        didSet {
            collectionDelegate.state = state
            collectionDataSource.state = state
            mainView.configureCollectionViewLayout(state: state)
            mainView.updateLayout(state: state, permissons: roomPermissions)
        }
    }

    private var pinnedUserId: String = "" {
        didSet {
            collectionDataSource.currentUserdId = pinnedUserId
            configPinnedView()
        }
    }

    private var roomSession: VideoCallWrapperProtocol = VideoCallWrapper()
    private var remoteUsers = [RemoteUser]()
    private var videoUsers = [RemoteUser]()
    private var noVideoUsers = [RemoteUser]()
    private var localUserId: String?
    

    private lazy var mainView = RoomMainView(delegate: self)
    private let gcMeet = GCoreMeet.shared

    private let collectionDelegate = RoomCollectionDelegate()
    private let collectionDataSource = RoomCollectionDataSource()

    //MARK: - Life cycle

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        mainView.configureCollection(delegate: collectionDelegate, source: collectionDataSource)
        configureRoomSession()
        UIApplication.shared.isIdleTimerDisabled = true
    }

    // MARK: - Private methods & Actions
    private func configureRoomSession() {
        roomSession.delegate = self
        videoUsers = roomSession.remoteUsers.filter { $0.isVideoEnable }
        noVideoUsers = roomSession.remoteUsers.filter { !($0.isVideoEnable)  }
        localUserId = roomSession.gcMeet.localUser?.id
    }

    private func updateCollection() {
        DispatchQueue.main.async { [self] in
            remoteUsers = sortActiveMicrophoneUsers(users: roomSession.remoteUsers)

            let unsrotedVideoUsers = remoteUsers.filter { $0.isVideoEnable }
            let sortedVideoUsers = sortActiveMicrophoneUsers(users: unsrotedVideoUsers)

            videoUsers = sortActiveMicrophoneUsers(users: sortedVideoUsers)

            let unsortedNoVideoUsers = remoteUsers.filter { !($0.isVideoEnable) }
            let sortedNoVideoUsers = sortActiveMicrophoneUsers(users: unsortedNoVideoUsers)

            noVideoUsers = sortActiveMicrophoneUsers(users: sortedNoVideoUsers)

            mainView.collectionView.reloadData()

            if state == .fullScreen {
                configPinnedView()
            }
        }
    }

    private func configPinnedView() {
        if let user = roomSession.remoteUsers.first(where: { $0.id == pinnedUserId }) {
            mainView.pinnedUserView.configureView(with: user)
        }
    }

    private func sortActiveMicrophoneUsers(users: [RemoteUser]) -> [RemoteUser] {
        var sortedUsers = users
        var localUser: RemoteUser?

        if let localUserIndex = sortedUsers.firstIndex(where: { $0.id == localUserId }) {
            localUser = sortedUsers[localUserIndex]
            sortedUsers.remove(at: localUserIndex)
        }

        sortedUsers = sortedUsers.sorted {
            let firstSpeaker = $0.isMicroEnable ? 1 : 0
            let secondSpeaker = $1.isMicroEnable ? 1 : 0
            return firstSpeaker > secondSpeaker
        }

        if let localUser {
            sortedUsers.insert(localUser, at: 0)
        }

        return sortedUsers
    }

    deinit {
        print("RoomViewController deinited")
    }
}

extension RoomViewController: VideoCallWrapperDelegate {
    func updateData() {
        updateCollection()
    }
    
    func updateLocalUser() {
        let currentLocalUserId = roomSession.gcMeet.localUser?.id
        localUserId = currentLocalUserId
        updateCollection()
    }
    
    func updateRoomPermissions() {
        let audio = roomSession.roomPermissions.audio
        let video = roomSession.roomPermissions.video

        let videoEnabled = video && userPermissions.video
        let audioEnabled = video && userPermissions.audio

        GCoreMeet.shared.localUser?.toggleCam(isOn: videoEnabled)
        GCoreMeet.shared.localUser?.toggleMic(isOn: audioEnabled)

        roomPermissions.audio = audio
        roomPermissions.video = video

        if let index = remoteUsers.firstIndex(where: { $0.id == localUserId }) {
            roomSession.remoteUsers[index].isVideoEnable = videoEnabled
            roomSession.remoteUsers[index].isMicroEnable = audioEnabled
        }

        updateCollection()
    }
    
    func updateUserPermissions() {
        let video = userPermissions.video
        let audio = userPermissions.audio

        GCoreMeet.shared.localUser?.toggleCam(isOn: video)
        GCoreMeet.shared.localUser?.toggleMic(isOn: audio)

        if !isFrontCameraPosition {
            GCoreMeet.shared.localUser?.flipCam { error in
                if let error = error as? NSError {
                    Logger.log("flip cam error \(error.description)")
                }
            }
        }

        let name = gcMeet.localUser?.displayName ?? ""
        let id = gcMeet.localUser?.id ?? "no id"
        var user = RemoteUser(name: name, id: id)

        user.isVideoEnable = video
        user.isMicroEnable = audio

        roomSession.remoteUsers.insert(user, at: 0)

        collectionDelegate.noVideoUsersData = { [weak self] in
            self?.noVideoUsers ?? []
        }

        collectionDelegate.remoteUsersData = { [weak self] in
            self?.remoteUsers ?? []
        }

        collectionDelegate.videoUsersData = { [weak self] in
            self?.videoUsers ?? []
        }

        collectionDataSource.noVideoUsersData = { [weak self] in
            self?.noVideoUsers ?? []
        }

        collectionDataSource.remoteUsersData = { [weak self] in
            self?.remoteUsers ?? []
        }

        collectionDataSource.videoUsersData = { [weak self] in
            self?.videoUsers ?? []
        }

        collectionDataSource.activityVCHandler = { [weak self] in
            let activityVC = ActivityViewController.shared.vc
            self?.present(activityVC, animated: true)
        }

        collectionDelegate.didSelectItem = { [weak self] user in
            guard let self else { return }
            switch self.state {
            case .tile: 
                self.pinnedUserId = user.id
                self.state = .fullScreen
                self.mainView.isPinned = true
            case .fullScreen:
                self.pinnedUserId = user.id
                self.mainView.collectionView.reloadData()
            }
        }

        updateCollection()
    }
    
    func updatePinnedUser() {
        if let speaker = roomSession.remoteUsers.first(where: { $0.isSpeaking }) {
            pinnedUserId = speaker.id
        }
    }
}

extension RoomViewController: RoomMainViewDelegate {
    func toggleVideo() {
        if SessionCaptureWrapper.checkVideoPermissions() {
            guard let localUserId,
                  let index = roomSession.remoteUsers.firstIndex(where: { $0.id == localUserId })
            else {
                return
            }
            roomSession.remoteUsers[index].isVideoEnable.toggle()
            let isEnable = roomSession.remoteUsers[index].isVideoEnable
            gcMeet.localUser?.toggleCam(isOn: isEnable)
            mainView.toggleVideo(isEnable: isEnable)
            updateCollection()
        } else {
            let alert = AlertFabric.configAlert(type: .requestVideoPermissions) { _ in
                if let settingsAppURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsAppURL)
                }
            }
            present(alert, animated: true)
        }
    }

    func switchCameraPosition() {
        gcMeet.localUser?.flipCam {
            if let nsError = $0 as? NSError {
                print(nsError.localizedDescription)
            }
        }
    }

    func toggleMicro() {
        if SessionCaptureWrapper.checkAudioPermissions() {
            guard let localUserId else { return }
            if let index = roomSession.remoteUsers.firstIndex(where: { $0.id == localUserId }) {
                roomSession.remoteUsers[index].isMicroEnable.toggle()
                let isEnable = roomSession.remoteUsers[index].isMicroEnable
                mainView.toggleMicrophone(isEnable: isEnable)
                gcMeet.localUser?.toggleMic(isOn: isEnable)
            }
            updateCollection()
        } else {
            let alert = AlertFabric.configAlert(type: .requestVideoPermissions) { _ in
                if let settingsAppURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsAppURL)
                }
            }
            present(alert, animated: true)
        }
    }

    func toggleDeviceAudio(from view: UIView) {
        AudioDeviceHandler.shared.presentAudioOutput(self, view)
    }

    func endCall() {
        let alert = AlertFabric.configAlert(type: .leaveRoom) { [weak self] _ in
            self?.gcMeet.localUser?.toggleCam(isOn: false)
            self?.gcMeet.localUser?.toggleMic(isOn: false)
            self?.roomSession.isExeting = true
            self?.gcMeet.close()

            self?.navigationController?.popToRootViewController(animated: true)
        }

        present(alert, animated: true)
    }

    func backTapped() {
        state = .tile
    }

    func invite() {
        let activityVC = ActivityViewController.shared.vc
        present(activityVC, animated: true)
    }

    func pinTapped() {
        updateCollection()
    }
}
