import UIKit

extension GcoreVideoCallButton {
    enum MediaButtonType {
        case audio, video, toggle, endCall
    }
}

final class GcoreVideoCallButton: UIButton {
    private var mediaType: MediaButtonType

    private var normalImage: UIImage?
    private var disabledImage: UIImage?

    override var isEnabled: Bool {
        didSet { changeColor() }
    }

    init(bgColor: UIColor = .purple, mediaType: MediaButtonType) {
        self.mediaType = mediaType
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        initConstraints()

        backgroundColor = bgColor
        layer.cornerRadius = SizeHelper.circleButtonCornerRadius

        config(type: mediaType)
        setImage(disabledImage, for: .disabled)

        addTarget(nil, action: #selector(changeImage(_:)), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = 0.5
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        alpha = 1
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        alpha = 1
    }

    @objc
    private func changeImage(_ sender: UIButton) {
        var isAvailableAudio = mediaType == .audio && SessionCaptureWrapper.checkAudioPermissions()
        var isAvailableVideo = mediaType == .video && SessionCaptureWrapper.checkVideoPermissions()

        guard isAvailableAudio || isAvailableVideo else { return }

        if tag == 0 {
            tag = 1
            setImage(disabledImage, for: .normal)
            backgroundColor = .veryDarkBlue
        } else {
            tag = 0
            setImage(normalImage, for: .normal)
            backgroundColor = .purple
        }
    }

    private func changeColor() {
        let color: UIColor = isEnabled ? .purple : .veryDarkBlue

        if mediaType == .video && SessionCaptureWrapper.checkVideoPermissions() {
            backgroundColor = color
        } else if mediaType == .audio, SessionCaptureWrapper.checkAudioPermissions() {
            backgroundColor = color
        }
    }

   private func config(type: MediaButtonType) {
        switch type {
        case .endCall:
            normalImage = .endCallImage

        case .video:
            normalImage = .videoCallImage
            disabledImage = .disableVideoImage

        case .audio:
            normalImage = .microphoneImage
            disabledImage = .disableMicro

        case .toggle:
            normalImage = .switchCameraImage
        }

       setImage(normalImage, for: .normal)
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: SizeHelper.circleButtonSize),
            widthAnchor.constraint(equalToConstant: SizeHelper.circleButtonSize)
        ])
    }
}
