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
        font: .edgeCenterMediumlFont(withSize: SizeHelper.screenHeight * 0.018)
    )

    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        nameLabel.textAlignment = .left

        layer.cornerRadius = SizeHelper.viewCornerRadius
        layer.borderWidth = 1
        backgroundColor = .veryDarkBlue
        contentMode = .scaleAspectFit
        clipsToBounds = true

        addSubview(letterImageView)
        letterImageView.isHidden = true
        letterImageView.layer.cornerRadius = 16

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
        let isLocalUser = model.id == gcMeet.localUser?.id
        nameLabel.text = isLocalUser ? (model.name + " (you)") : model.name
       
        configStackView(state: state)
        configureMicroImage(model: model)
        configureBorder(model: model, state: state)
        configureVideoView(model: model, state: state, isPinned: isPinned)
        configureLetterImage(model: model, state: state, isPinned: isPinned)
    }

    func configureScreenSharing(with model: RemoteUser) {
        nameLabel.text = model.name + " (screen)"
        configStackView(state: .tile)
        configureMicroImage(model: model)
        configureBorder(model: model, state: .tile)
        addVideoView(model.sharingView)
    }

    // MARK: - Private methods & Actions
    private func configureVideoView(model: RemoteUser, state: RoomState, isPinned: Bool) {
        switch state {
        case .fullScreen where isPinned:
            guard model.isScreenSharing && model.isVideoEnable else { return } 
        case .fullScreen, .tile:
            guard model.isScreenSharing || model.isVideoEnable else { return }
        }

        let userView = {
            if state == .tile {
                return model.view
            }

            if isPinned {
                return model.view
            } else {
                return model.isScreenSharing ? model.sharingView : model.view
            }
        }()

        addVideoView(userView)
    }

    private func addVideoView(_ view: RTCMTLVideoView) {
        view.videoContentMode = .scaleAspectFill
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(view, at: 0)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        layoutIfNeeded()
    }

    private func configStackView(state: RoomState) {
        stackView.isHidden = false

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

// MARK: - Private implementation
private extension VideoUserCollectionViewCell {
    func configureMicroImage(model: RemoteUser) {
        if model.isMicroEnable {
            microphoneImageView.image = model.isSpeaking ? .activeMicrophoneImage : .microphoneImage
        } else {
            microphoneImageView.image = .disableMicro
        }
    }

    func configureLetterImage(model: RemoteUser, state: RoomState, isPinned: Bool) {
        switch state {
        case .fullScreen where isPinned:
            guard !(model.isVideoEnable && model.isScreenSharing) else { return }
        case .fullScreen, .tile:
            guard !(model.isVideoEnable || model.isScreenSharing) else { return }
        }

        addLetterImage(with: model, and: state)
    }

    func addLetterImage(with model: RemoteUser, and state: RoomState) {
        let bottomPadding = -(SizeHelper.screenHeight * 0.014)
        letterImageView.backgroundColor = model.bgColor
        letterImageView.image = LetterImageGenerator.imageWith(name: model.name)
        letterImageView.isHidden = false

        let constraints: [NSLayoutConstraint]
        if state == .fullScreen {
            constraints = [
                letterImageView.heightAnchor.constraint(equalToConstant: 32),
                letterImageView.widthAnchor.constraint(equalToConstant: 32),
                letterImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                letterImageView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: bottomPadding)
            ]
        } else {
            constraints = [
                letterImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                letterImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ]
        }

        NSLayoutConstraint.activate(constraints)
    }

    func configureBorder(model: RemoteUser, state: RoomState) {
        guard model.isMicroEnable else { return }

        if model.isSpeaking {
            layer.borderColor = UIColor.green.cgColor
            return
        }

        if state == .fullScreen {
            layer.borderColor = UIColor.customRed.cgColor
        }
    }
}
