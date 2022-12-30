import UIKit
import AVFoundation

final class GcoreVideoPreviewView: UIView {
    private let previewLayer = AVCaptureVideoPreviewLayer()

    init(session: AVCaptureSession) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .veryDarkBlue
        layer.cornerRadius = SizeHelper.viewCornerRadius

        setupPreviewLayer(session: session)
    }

    override func layoutSubviews() {
        previewLayer.frame = bounds
        previewLayer.cornerRadius = layer.cornerRadius
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPreviewLayer(session: AVCaptureSession) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.previewLayer.videoGravity = .resizeAspectFill
            self.previewLayer.session = session

            self.layer.addSublayer(self.previewLayer)

            DispatchQueue.global(qos: .userInteractive).async {
                session.startRunning()
            }
        }
    }
}
