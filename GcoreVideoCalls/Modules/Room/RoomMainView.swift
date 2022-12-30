import UIKit

fileprivate typealias VideoCell = VideoUserCollectionViewCell
fileprivate typealias UserCell = UserCollectionViewCell
fileprivate typealias Footer = CollectionFooter

protocol RoomMainViewDelegate: AnyObject {
    func toggleVideo()
    func toggleMicro()
    func toggleDeviceAudio(from view: UIView) 
    func switchCameraPosition()
    func endCall()
    func backTapped()
    func invite()
    func pinTapped()
}

final class RoomMainView: UIView {
    private weak var delegate: RoomMainViewDelegate?

    var pinnedUserViewHeightConstraint: NSLayoutConstraint?
    var pinnedUserViewBottomConstraint: NSLayoutConstraint?
    var collectionBottomConstraint: NSLayoutConstraint?

    var isPinned = false

    private var footerKind: String {
        UICollectionView.elementKindSectionFooter
    }

    lazy var pinnedUserView = PinnedUserView()

    let inviteUserButton: UIButton = {
        let button = UIButton()
        button.setImage(.personImage, for: .normal)
        return button
    }()

    let audioDeviceButton: UIButton = {
        let button = UIButton()
        button.setImage(.volumeImage, for: .normal)
        return button
    }()

    lazy var backButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        return button
    }()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.isScrollEnabled = true
        collection.backgroundColor = .corbeau
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()

    let switchCameraButton = GcoreVideoCallButton(mediaType: .toggle)
    let microphoneButton = GcoreVideoCallButton(mediaType: .audio)
    let videoButton = GcoreVideoCallButton(mediaType: .video)
    let endCallButton = GcoreVideoCallButton(bgColor: .customRed, mediaType: .endCall)

    init(delegate: RoomMainViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)

        setupHierarchy()
        initConstraints()
        setupBackButton()

        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.cellId)
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.cellId)
        collectionView.register(Footer.self, forSupplementaryViewOfKind: footerKind, withReuseIdentifier: Footer.identifier)

        backgroundColor = .corbeau

        videoButton.setImage(.disableVideoImage, for: .disabled)
        microphoneButton.setImage(.disableMicro, for: .disabled)

        configureButtons()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCollection(
        delegate: UICollectionViewDelegate,
        source: UICollectionViewDataSource
    ) {
        collectionView.delegate = delegate
        collectionView.dataSource = source
    }

    func configureCollectionViewLayout(state: RoomState) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        switch state {
        case .tile:
            layout.scrollDirection = .vertical
        case .fullScreen:
            layout.scrollDirection = .horizontal
            backButton.isHidden = false
        }

        collectionView.reloadData()
    }

    func updateLayout(state: RoomState, permissons: MediaPermissions) {
        configureCollectionViewLayout(state: state)

        let fullScreenViewHeight = SizeHelper.screenHeight * 0.64
        let viewHeight = state == .tile ? 0 : fullScreenViewHeight

        let fullScreenCollectionBottomPadding = -(SizeHelper.screenHeight * 0.105)
        let bottomCollectionPadding = state == .tile ? 0 : fullScreenCollectionBottomPadding

        let pinnedUserViewBottomPadding: CGFloat = state == .tile ? -8 : -4

        UIView.animate(withDuration: 0.4, delay: 0.2) { [self] in
            pinnedUserViewHeightConstraint?.constant = viewHeight
            pinnedUserViewBottomConstraint?.constant = pinnedUserViewBottomPadding
            collectionBottomConstraint?.constant = bottomCollectionPadding
            layoutIfNeeded()
        }
    }

    func configButtons(audio: Bool, video: Bool) {
        let videoButtonColor: UIColor? = video ? .purple : .veryDarkBlue
        let audioButtonColor: UIColor? = audio ? .purple : .veryDarkBlue

        let audioButtonImage: UIImage? = audio ? .microphoneImage : .disableMicro
        let videoButtonImage: UIImage? = video ? .videoCallImage : .disableVideoImage

        videoButton.setImage(videoButtonImage, for: .normal)
        videoButton.backgroundColor = videoButtonColor

        microphoneButton.setImage(audioButtonImage, for: .normal)
        microphoneButton.backgroundColor = audioButtonColor
    }

    func updatePermissons(permissoins: MediaPermissions) {
        if !permissoins.video {
            videoButton.isEnabled = permissoins.video
        }

        if !permissoins.audio {
            microphoneButton.isEnabled = permissoins.audio
        }
    }

    func toggleVideo(isEnable: Bool) {
        switchCameraButton.isHidden.toggle()
        videoButton.backgroundColor = isEnable ? .purple : .veryDarkBlue
        let image: UIImage? = isEnable ? .videoCallImage : .disableVideoImage
        videoButton.setImage(image, for: .normal)
    }
}

extension RoomMainView {
    private func setupHierarchy() {
        addSubview(collectionView)
        addSubview(backButton)
        addSubview(pinnedUserView)
        addSubview(switchCameraButton)
        addSubview(videoButton)
        addSubview(microphoneButton)
        addSubview(endCallButton)
    }

    private func setupBackButton() {
        if #available(iOS 15.0, *) {
            configureBackButtonByIOS15()
        } else {
            configureBackButtonByDefault()
        }
    }

    @available(iOS 15.0, *)
    private func configureBackButtonByIOS15() {
        var config = UIButton.Configuration.borderless()
        config.imagePadding = 5
        config.title = "Back to the tile"
        config.image = .leftArrowImage

        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .gcoreRegularFont(withSize: 17)
            outgoing.foregroundColor = .white
            outgoing.strokeColor = .white
            return outgoing
        }

        backButton.configuration = config
    }

    private func configureBackButtonByDefault() {
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        backButton.titleLabel?.font = .gcoreRegularFont(withSize: 17)
        backButton.setTitle("Back to the tile", for: .normal)
        backButton.setImage(.leftArrowImage, for: .normal)
        backButton.setTitleColor(.white, for: .normal)
    }

    private func initConstraints() {
        for button in [inviteUserButton, backButton, audioDeviceButton] {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.contentMode = .scaleAspectFit
        }

        let topButtonsInsets =  Int(SizeHelper.screenWidth * 0.05)
        let callButtonsInsets = Int(SizeHelper.screenWidth * 0.112)

        let topButtonsStackView = UIStackView(
            views: [audioDeviceButton, inviteUserButton],
            axis: .horizontal,
            spacing: topButtonsInsets,
            alignment: .trailing,
            distribution: .fillEqually
        )

        let callButtons = [switchCameraButton, videoButton, microphoneButton, endCallButton]
        let callButtonsStackView = UIStackView(
            views: callButtons,
            axis: .horizontal,
            spacing: callButtonsInsets,
            alignment: .center,
            distribution: .equalSpacing
        )

        addSubview(topButtonsStackView)
        addSubview(callButtonsStackView)

        setupConstraintsFor(
            topButtonsStack: topButtonsStackView,
            callButtonsStack: callButtonsStackView,
            pinnedUserView: pinnedUserView,
            backButton: backButton,
            collection: collectionView
        )
    }

    func configureButtons() {
        endCallButton.addTarget(nil, action: #selector(endCallButtonTapped(_:)), for: .touchUpInside)
        backButton.addTarget(nil, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        audioDeviceButton.addTarget(nil, action: #selector(audioButtonTapped(_:)), for: .touchUpInside)
        inviteUserButton.addTarget(nil, action: #selector(inviteButtonTapped(_:)), for: .touchUpInside)
        microphoneButton.addTarget(nil, action: #selector(microphoneTapped(_:)), for: .touchUpInside)
        switchCameraButton.addTarget(nil, action: #selector(switchTapped(_:)), for: .touchUpInside)
        videoButton.addTarget(nil, action: #selector(videoTapped(_:)), for: .touchUpInside)
        pinnedUserView.pinButton.addTarget(nil, action: #selector(pinTapped(_:)), for: .touchUpInside)
    }

    func toggleMicrophone(isEnable: Bool) {
        microphoneButton.backgroundColor = isEnable ? .purple : .veryDarkBlue
        let image: UIImage? = isEnable ? .microphoneImage : .disableMicro
        microphoneButton.setImage(image, for: .normal)
    }
}

@objc
private extension RoomMainView {
    func pinTapped(_ sender: UIButton) {
        isPinned.toggle()
        let buttonImage: UIImage? = isPinned ? .pinImage : .unpinImage
        sender.setImage(buttonImage, for: .normal)
        pinnedUserView.pinLabel.isHidden.toggle()
        delegate?.pinTapped()
    }

    func videoTapped(_ sender: UIButton) {
        delegate?.toggleVideo()
    }

    func switchTapped(_ sender: UIButton) {
        delegate?.switchCameraPosition()
    }


    func microphoneTapped(_ sender: UIButton) {
        delegate?.toggleMicro()
    }

    func audioButtonTapped(_ sender: UIButton) {
        delegate?.toggleDeviceAudio(from: sender)
    }

    func endCallButtonTapped(_ sender: UIButton) {
        delegate?.endCall()
    }

    func backButtonTapped(_ sender: UIButton) {
        delegate?.backTapped()
        isPinned = false
        sender.isHidden = true
        pinnedUserView.reloadView()
    }

    func inviteButtonTapped(_ sender: UIButton) {
        delegate?.invite()
    }
}
