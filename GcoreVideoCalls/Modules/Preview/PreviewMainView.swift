import UIKit
import AVFoundation

protocol PreviewMainViewDelegate: AnyObject {
    func setupUser()
    func switchCamera()
    func connect()
    func toggleMicro()
    func toggleVideo()
}

final class PreviewMainView: UIView {
    // MARK: - Public methods
    var name: String? {
        nameTextField.text
    }

    weak var delegate: PreviewMainViewDelegate?

    // MARK: - Private methods
    private let previewView: GcoreVideoPreviewView

    private let switchCameraButton = GcoreVideoCallButton(mediaType: .toggle)
    private let microphoneButton = GcoreVideoCallButton(mediaType: .audio)
    private let videoButton = GcoreVideoCallButton(mediaType: .video)
    private let letterImageView = LetterImageView()
    private let nameTextField = GcoreTextField(placeholder: "Name")

    private let warningLabel = UILabel(
        text:  .nameWarning,
        font: .gcoreRegularFont(withSize: SizeHelper.screenHeight * 0.015),
        color: .customRed
    )

    private let connectButton = GcoreButton(
        font: .gcoreSemiBoldFont(withSize: SizeHelper.screenHeight * 0.02),
        image: nil,
        text: "Connect"
    )

    // MARK: - Init
    init(session: AVCaptureSession, delegate: PreviewMainViewDelegate) {
        previewView = GcoreVideoPreviewView(session:  session)
        super.init(frame: .zero)
        self.delegate = delegate
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public properties
    func updateImageLetter() {
        letterImageView.image = LetterImageGenerator.imageWith(name: nameTextField.text)
    }

    func togglePreview() {
        UIView.animate(withDuration: 0.2, delay: 0.2) { [self] in
            switchCameraButton.isHidden.toggle()
            letterImageView.isHidden.toggle()
//            previewView.isHidden.toggle()
            layoutIfNeeded()
        }
    }
}

// MARK: - UITextFieldDelegate
extension PreviewMainView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.setupUser()
        return textField.resignFirstResponder()
    }
}

// MARK: - Private implementation
private extension PreviewMainView {
    func setupView() {
        setupHierarchy()
        initConstraints()

        configureButtons()

        letterImageView.image = LetterImageGenerator.imageWith(name: nameTextField.placeholder)
        letterImageView.backgroundColor = .colorForLetterImage.randomElement()
        letterImageView.isHidden = true

        nameTextField.delegate = self

        warningLabel.isHidden = true
    }

    func setupHierarchy() {
        addSubview(previewView)
        addSubview(nameTextField)
        addSubview(connectButton)
        addSubview(warningLabel)
        previewView.addSubview(letterImageView)
    }

    func configureButtons() {
        switchCameraButton.addTarget(nil, action: #selector(switchCameraButtonTapped(_:)), for: .touchUpInside)
        microphoneButton.addTarget(nil, action: #selector(microphoneCameraButtonTapped(_:)), for: .touchUpInside)
        videoButton.addTarget(nil, action: #selector(videoButtonTapped(_:)), for: .touchUpInside)
        connectButton.addTarget(nil, action: #selector(connectButtonTapped(_:)), for: .touchUpInside)
    }

    func initConstraints() {
        let buttonSideInset = Int(SizeHelper.screenWidth * 0.053)

        let buttonStackView = UIStackView(
            views: [switchCameraButton, videoButton, microphoneButton],
            axis: .horizontal,
            spacing: buttonSideInset,
            alignment: .center,
            distribution: .equalSpacing
        )

        addSubview(buttonStackView)

        setupConstraintsFor(
            preview: previewView,
            buttonsStack: buttonStackView,
            nameTextField: nameTextField,
            warningLabel: warningLabel,
            connectButton: connectButton,
            letterImage: letterImageView
        )
    }

    // MARK: - Buttons handler

    @objc
    func switchCameraButtonTapped(_ sender: UIButton) {
        delegate?.switchCamera()
    }

    @objc
    func connectButtonTapped(_ sender: UIButton) {
        guard let name else { return }
        if name.isEmpty {
            nameTextField.layer.borderColor = UIColor.customRed.cgColor
            warningLabel.isHidden = false
        } else {
            delegate?.connect()
        }
    }

    @objc
    func microphoneCameraButtonTapped(_ sender: UIButton) {
        delegate?.toggleMicro()
    }

    @objc
    func videoButtonTapped(_ sender: UIButton) {
        delegate?.toggleVideo()
    }
}
