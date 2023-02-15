import WebRTC

final class PinnedUserView: UIView {
    var model: RemoteUser

    let pinButton: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.setImage(.pinImage, for: .normal)
        return button
    }()

    let pinLabel = UILabel(
        text: "Unpin",
        font: .gcoreMediumlFont(withSize: SizeHelper.screenHeight * 0.014)
    )

    private let nameLabel = UILabel(
        text: "Paprika",
        font: .gcoreMediumlFont(withSize: SizeHelper.screenHeight * 0.018)
    )

    private let microphoneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let letterImageView = LetterImageView()
    private var stackView: UIStackView?

    init(model: RemoteUser = RemoteUser()) {
        self.model = model
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = SizeHelper.viewCornerRadius
        backgroundColor = .veryDarkBlue

        setupHierarchy()
        initConstraints()

        letterImageView.isHidden = true
        pinButton.isHidden = true
        pinLabel.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureView(with model: RemoteUser) {
        reloadView()
        self.model = model

        if model.isScreenSharing || model.isVideoEnable {
            letterImageView.isHidden = true
            addVideoView(of: model)
        } else {
            letterImageView.image = LetterImageGenerator.imageWith(name: model.name)
            letterImageView.backgroundColor = model.bgColor
            letterImageView.isHidden = false

            for view in subviews where view is RTCMTLVideoView {
                view.removeFromSuperview()
            }
        }

        microphoneImageView.image = model.isMicroEnable ? .microphoneImage : .disableMicro

        if model.isSpeaking {
            microphoneImageView.image = .activeMicrophoneImage
        }

        nameLabel.text = model.name
        pinButton.isHidden = false
        stackView?.isHidden = false
    }


    func reloadView() {
        nameLabel.text = nil
        letterImageView.image = nil
        letterImageView.isHidden = true
        pinButton.isHidden = true
        stackView?.isHidden = true
        pinLabel.isHidden = true

        for view in subviews where view is RTCMTLVideoView {
            view.removeFromSuperview()
        }
    }

    private func addVideoView(of user: RemoteUser) {
        let userVideoView = user.isScreenSharing ? user.sharingView : user.view
        userVideoView.translatesAutoresizingMaskIntoConstraints = false
        userVideoView.videoContentMode = user.isScreenSharing ? .scaleAspectFit : .scaleAspectFill

        insertSubview(userVideoView, at: 0)
        clipsToBounds = true

        NSLayoutConstraint.activate([
            userVideoView.topAnchor.constraint(equalTo: topAnchor),
            userVideoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userVideoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            userVideoView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        layoutIfNeeded()
    }

    private func setupHierarchy() {
        addSubview(letterImageView)
        addSubview(pinButton)
        addSubview(pinLabel)
    }

    private func initConstraints() {
        let stackViewHeight = SizeHelper.screenHeight * 0.022
        let stackViewLeftPadding = SizeHelper.screenWidth * 0.021
        let stackViewBottomPadding = -(SizeHelper.screenHeight * 0.009)
        let pinImageTopPadding = SizeHelper.screenHeight * 0.012
        let pinImageRightPadding = -(SizeHelper.screenWidth * 0.033)
        let pinImageHeight = SizeHelper.screenHeight * 0.02
        let pinLabelTrailing = -(SizeHelper.screenWidth * 0.016)

        stackView = UIStackView(
            views: [microphoneImageView, nameLabel],
            axis: .horizontal,
            spacing: 7,
            alignment: .center,
            distribution: .equalSpacing
        )

        guard let stackView else { return }
        stackView.isHidden = true
        stackView.backgroundColor = .black.withAlphaComponent(0.3)
        stackView.layer.cornerRadius = SizeHelper.viewCornerRadius
        addSubview(stackView)

        for element in [microphoneImageView, pinButton, stackView] {
            element.translatesAutoresizingMaskIntoConstraints = false
            element.contentMode = .scaleAspectFit
        }

        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalToConstant: stackViewHeight),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: stackViewLeftPadding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: stackViewBottomPadding),

            letterImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            letterImageView.centerXAnchor.constraint(equalTo: centerXAnchor),

            pinButton.heightAnchor.constraint(equalToConstant: pinImageHeight),
            pinButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: pinImageRightPadding),
            pinButton.topAnchor.constraint(equalTo: topAnchor, constant: pinImageTopPadding),

            pinLabel.centerYAnchor.constraint(equalTo: pinButton.centerYAnchor),
            pinLabel.trailingAnchor.constraint(equalTo: pinButton.leadingAnchor, constant: pinLabelTrailing)
        ])
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if pinButton.frame.insetBy(dx: -10, dy: -10).contains(point) {
            return pinButton
        }
        return super.hitTest(point, with: event)
    }
}
