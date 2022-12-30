import GCoreVideoCallsSDK

final class VideoUserCollectionViewCell: UICollectionViewCell {
    //MARK: - Static properties
    static let cellId = "VideoUserCollectionViewCellId"
    static let nibName = "VideoUserCollectionViewCell"

    //MARK: - Private properties
    private var stackView: UIStackView!
    private var stackViewTrailingConstraint: NSLayoutConstraint?
    private var stackViewHeightConstraint: NSLayoutConstraint?

    private let microphoneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let gcMeet = GCoreMeet.shared
    private let letterImageView = LetterImageView(size: 78)

    private let nameLabel = UILabel(
        text: "Paprika",
        font: .gcoreMediumlFont(withSize: SizeHelper.screenHeight * 0.018)
    )

    //MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = SizeHelper.viewCornerRadius
        layer.borderWidth = 1
        backgroundColor = .veryDarkBlue
        contentMode = .scaleAspectFit
        clipsToBounds = true
        nameLabel.textAlignment = .left

        addSubview(letterImageView)

        letterImageView.isHidden = true

        initConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: Life cycle
    override func prepareForReuse() {
        super.prepareForReuse()

        letterImageView.isHidden = true
        letterImageView.image = nil
        nameLabel.text = nil
        stackView.isHidden = true
        layer.borderColor = UIColor.clear.cgColor

        for view in subviews where view is RTCMTLVideoView {
            view.removeFromSuperview()
        }
    }

    // MARK: - Public methods & Actions
    func configure(with model: RemoteUser, and state: RoomState, isPinned: Bool = false) {
        let isMicroEnable = model.isMicroEnable
        let isVideoEnable = model.isVideoEnable
        let isSpeaking = model.isSpeaking
        let isLocalUser = model.id == gcMeet.localUser?.id

        nameLabel.text = isLocalUser ? (model.name + " (you)") : model.name

        stackView.isHidden = false
        configStackView(state: state)

        if !isMicroEnable {
            microphoneImageView.image = .disableMicro
        } else {
            microphoneImageView.image = isSpeaking ? .activeMicrophoneImage : .microphoneImage
        }

        switch (isVideoEnable, state, isSpeaking, isPinned) {
        case (true, .tile, true, _):
            addVideoView(model: model, state: state)
            layer.borderColor = UIColor.green.cgColor

        case (true, .tile, false, _), (true, .fullScreen, false, false) :
            addVideoView(model: model, state: state)

        case (false, .tile, _, _), (false, .fullScreen, false, false):
            configLetterImage(with: model, and: state)

        case (false, .fullScreen, _, true):
            configLetterImage(with: model, and: state)
            layer.borderColor = UIColor.customRed.cgColor

        case (false, .fullScreen, true, false):
            configLetterImage(with: model, and: state)
            layer.borderColor = UIColor.green.cgColor

        case (true, .fullScreen, true, false):
            addVideoView(model: model, state: state)
            layer.borderColor = UIColor.green.cgColor

        case (true, .fullScreen, _, true):
            configLetterImage(with: model, and: state)
            layer.borderColor = UIColor.customRed.cgColor
        }
    }

    // MARK: - Private methods & Actions
    private func addVideoView(model: RemoteUser, state: RoomState) {
        let userView = model.view
        userView.videoContentMode = .scaleAspectFill
        userView.layer.cornerRadius = 8
        userView.translatesAutoresizingMaskIntoConstraints = false

        insertSubview(userView, at: 0)

        NSLayoutConstraint.activate([
            userView.topAnchor.constraint(equalTo:  topAnchor),
            userView.leadingAnchor.constraint(equalTo:  leadingAnchor),
            userView.trailingAnchor.constraint(equalTo:  trailingAnchor),
            userView.bottomAnchor.constraint(equalTo:  bottomAnchor),
        ])

        layoutIfNeeded()
    }

    private func configLetterImage(with model: RemoteUser, and state: RoomState) {
        let bottomPadding = -(SizeHelper.screenHeight * 0.014)

        letterImageView.backgroundColor = model.bgColor
        letterImageView.image = LetterImageGenerator.imageWith(name: model.name)
        letterImageView.isHidden = false

        if state == .fullScreen {
            letterImageView.layer.cornerRadius = 16
            NSLayoutConstraint.activate([
                letterImageView.heightAnchor.constraint(equalToConstant: 32),
                letterImageView.widthAnchor.constraint(equalToConstant: 32),
                letterImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                letterImageView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: bottomPadding)
            ])
        } else {
            NSLayoutConstraint.activate([
                letterImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                letterImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
    }

    private func configStackView(state: RoomState) {
        switch state {
        case .fullScreen:
            addConstraint(stackViewTrailingConstraint!)
            stackViewHeightConstraint?.constant = SizeHelper.stackViewHeightFullScreen
        case .tile:
            removeConstraint(stackViewTrailingConstraint!)
            stackViewHeightConstraint?.constant = SizeHelper.stackViewHeighTile
        }

        layoutIfNeeded()
    }

    private func initConstraints() {
        let stackViewLeftPadding = SizeHelper.screenWidth * 0.021
        let stackViewBottomPadding = -(SizeHelper.screenHeight * 0.009)
        let microphoneWidth = SizeHelper.screenWidth * 0.042

        stackView = UIStackView(
            views: [microphoneImageView, nameLabel],
            axis: .horizontal,
            spacing: 7,
            alignment: .leading,
            distribution: .equalSpacing
        )

        guard let stackView else { return }
        stackView.isHidden = true

        stackViewTrailingConstraint = NSLayoutConstraint(
            item: stackView,
            attribute: .trailing,
            relatedBy: .lessThanOrEqual,
            toItem: self,
            attribute: .trailing,
            multiplier: 1,
            constant: 0
        )

        stackViewHeightConstraint = NSLayoutConstraint(
            item: stackView,
            attribute: .height,
            relatedBy: .equal,
            toItem: .none,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: SizeHelper.stackViewHeightFullScreen
        )

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addConstraint(stackViewHeightConstraint!)
        stackView.backgroundColor = .black.withAlphaComponent(0.3)
        stackView.layer.cornerRadius = SizeHelper.viewCornerRadius
        addSubview(stackView)

        NSLayoutConstraint.activate([
            microphoneImageView.widthAnchor.constraint(equalToConstant: microphoneWidth),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: stackViewLeftPadding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: stackViewBottomPadding)
        ])
    }
}
