import AVFoundation

struct SessionCaptureWrapper {

    // MARK: - Public properties
    var captureSession = AVCaptureSession()
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var currentCaptureDevice: AVCaptureDevice?
    var currentVideoInput: AVCaptureDeviceInput?

    var usingFrontCamera = true

    let microphoneInput: AVCaptureDeviceInput? = {
        if let micro = AVCaptureDevice.default(for: .audio) {
            return try? AVCaptureDeviceInput(device: micro)
        }
        return nil
    }()

    // MARK: - Init
    init() {
        loadCamera()
    }

    // MARK: - Static methods & Actions
    static func checkVideoPermissions() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == AVAuthorizationStatus.authorized
    }

    static func checkAudioPermissions() ->  Bool {
        AVCaptureDevice.authorizationStatus(for: .audio) == AVAuthorizationStatus.authorized
    }

    // MARK: - Public methods & Actions
    func getBackCamera() -> AVCaptureDevice? {
        AVCaptureDevice.default(for: .video)
    }

    mutating func toggleMicrophone() {
        guard let microphoneInput else { return }

        if captureSession.canAddInput(microphoneInput) {
            captureSession.addInput(microphoneInput)
        } else {
            captureSession.removeInput(microphoneInput)
        }
    }

    mutating func toggleCamera() {
        guard let currentVideoInput else { return }

        if captureSession.inputs.count == 1 {
            captureSession.removeInput(currentVideoInput)
        } else if captureSession.canAddInput(currentVideoInput) {
            captureSession.addInput(currentVideoInput)
        }
    }

    mutating func switchCameraPosition() {
        usingFrontCamera = !usingFrontCamera
        captureSession.beginConfiguration()
        captureSession.removeInput(currentVideoInput!)

        if !usingFrontCamera {
            do {
                guard let backCameraDevice = getBackCamera() else { return }
                currentVideoInput = try AVCaptureDeviceInput(device: backCameraDevice)
                captureSession.addInput(currentVideoInput!)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            do {
                guard let frontCameraDevice = getFrontCamera() else { return }
                currentVideoInput = try AVCaptureDeviceInput(device: frontCameraDevice)
                captureSession.addInput(currentVideoInput!)
            } catch {
                print(error.localizedDescription)
            }
        }

        captureSession.commitConfiguration()
    }

    // MARK: - Private methods & Actions

    private func getFrontCamera() -> AVCaptureDevice? {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == .front {
                return device
            }
        }
        return nil
    }

    private mutating func loadCamera() {
        currentCaptureDevice = usingFrontCamera ? getFrontCamera() : getBackCamera()

        guard let currentCaptureDevice  else { return }
        do {
            currentVideoInput = try AVCaptureDeviceInput(device: currentCaptureDevice)
        } catch {
            currentVideoInput = nil
            print(error.localizedDescription)
        }

        for currentInput in captureSession.inputs {
            captureSession.removeInput(currentInput)
        }

        guard let currentVideoInput else { return }

        if captureSession.canAddInput(currentVideoInput) {
            captureSession.addInput(currentVideoInput)

            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.connection?.videoOrientation = .portrait
            videoPreviewLayer?.cornerRadius = SizeHelper.viewCornerRadius
        }
    }
}
