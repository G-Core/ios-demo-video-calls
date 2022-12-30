import GCoreVideoCallsSDK

class PreviewViewController: BaseViewController {
    // MARK: - Public proteries

    //MARK: - Private properties
    private var sessionWrapper = SessionCaptureWrapper()
    private let gcMeet = GCoreMeet.shared

    private lazy var mainView = PreviewMainView(session: sessionWrapper.captureSession, delegate: self)

    private var userMediaPermissions = MediaPermissions(audio: true, video: true)
    private var isFrontCamPosition = true

    //MARK: - Life cycle
    override func loadView() {
        view = mainView
    }

    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            self.sessionWrapper.captureSession.stopRunning()
        }
    }

    @objc
    override func hideKeyboard() {
        super.hideKeyboard()
        setupUser()
    }
}

// MARK: - PreviewMainViewDelegate
extension PreviewViewController: PreviewMainViewDelegate {
    func setupUser() {
        mainView.updateImageLetter()
        RoomConfigurator.userName = mainView.name?.capitalized
    }

    func switchCamera() {
        sessionWrapper.switchCameraPosition()
        isFrontCamPosition.toggle()
    }

    func connect() {
        let vc = RoomViewController()
        vc.userPermissions = userMediaPermissions
        vc.isFrontCameraPosition = isFrontCamPosition
        navigationController?.pushViewController(vc, animated: true)  
    }

    func toggleMicro() {
        if SessionCaptureWrapper.checkAudioPermissions() {
            userMediaPermissions.audio.toggle()
            sessionWrapper.toggleMicrophone()
        } else {
            let alert = AlertFabric.configAlert(type: .requestAudioPermissions) { _ in
                if let settingsAppURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsAppURL)
                }
            }
            present(alert, animated: true)
        }
    }

    func toggleVideo() {
        if SessionCaptureWrapper.checkVideoPermissions() {
            mainView.togglePreview()
            userMediaPermissions.video.toggle()
            sessionWrapper.toggleCamera()
        } else {
            let alert = AlertFabric.configAlert(type: .requestVideoPermissions) { _ in
                if let settingsAppURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsAppURL)
                }
            }
            present(alert, animated: true)
        }
    }
}
