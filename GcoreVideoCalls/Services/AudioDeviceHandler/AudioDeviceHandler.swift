import AVFoundation
import UIKit

@objc
final class AudioDeviceHandler: NSObject {

    @objc
    static let shared = AudioDeviceHandler()

    @objc
    func presentAudioOutput(_ presenterViewController : UIViewController, _ sourceView: UIView) {
        let speakerTitle = "Speaker"
        let headphoneTitle = "Headphones"
        let deviceTitle = (UIDevice.current.userInterfaceIdiom == .pad) ? "iPad" : "iPhone"
        let cancelTitle = "Cancel"

        var deviceAction = UIAlertAction()
        var headphonesExist = false
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        guard let availableInputs = AVAudioSession.sharedInstance().availableInputs else {
            print("No inputs available ")
            return
        }

        for audioPort in availableInputs {
            switch audioPort.portType {
            case .bluetoothA2DP, .bluetoothHFP, .bluetoothLE :
                let bluetoothAction = UIAlertAction(title: audioPort.portName, style: .default) { _ in
                    self.setPreferredInput(port: audioPort)
                }

                if isCurrentOutput(portType: audioPort.portType) {
                    bluetoothAction.setValue(true, forKey: "checked")
                }

                optionMenu.addAction(bluetoothAction)

            case .builtInMic, .builtInReceiver:

                deviceAction = UIAlertAction(title: deviceTitle, style: .default, handler: { _ in
                    self.setToDevice(port: audioPort)
                })

            case .headphones, .headsetMic:
                headphonesExist = true

                let headphoneAction = UIAlertAction(title: headphoneTitle, style: .default) { _ in
                    self.setPreferredInput(port: audioPort)
                }

                if isCurrentOutput(portType: .headphones) || isCurrentOutput(portType: .headsetMic) {
                    headphoneAction.setValue(true, forKey: "checked")
                }

                optionMenu.addAction(headphoneAction)

            case .carAudio:
                let carAction = UIAlertAction(title: audioPort.portName, style: .default) { _ in
                    self.setPreferredInput(port: audioPort)
                }

                if isCurrentOutput(portType: audioPort.portType) {
                    carAction.setValue(true, forKey: "checked")
                }
                optionMenu.addAction(carAction)

            default:
                break
            }
        }

        if !headphonesExist {
            if (isCurrentOutput(portType: .builtInReceiver) ||
                isCurrentOutput(portType: .builtInMic)) {
                deviceAction.setValue(true, forKey: "checked")
            }
            optionMenu.addAction(deviceAction)
        }

        let speakerAction = UIAlertAction(title: speakerTitle, style: .default) { _ in
            self.setOutputToSpeaker()
        }
        
        if isCurrentOutput(portType: .builtInSpeaker) {
            speakerAction.setValue(true, forKey: "checked")
        }
        optionMenu.addAction(speakerAction)

        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel)
        optionMenu.addAction(cancelAction)

        optionMenu.modalPresentationStyle = .popover
        if let presenter = optionMenu.popoverPresentationController {
            presenter.sourceView = sourceView
            presenter.sourceRect = sourceView.bounds
        }

        presenterViewController.present(optionMenu, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            optionMenu.dismiss(animated: true, completion: nil)
        }
    }

    @objc
    func setOutputToSpeaker() {
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch let error as NSError {
            print("audioSession error turning on speaker: \(error.localizedDescription)")
        }
    }

    fileprivate func setPreferredInput(port: AVAudioSessionPortDescription) {
        do {
            try AVAudioSession.sharedInstance().setPreferredInput(port)
        } catch let error as NSError {
            print("audioSession error change to input: \(port.portName) with error: \(error.localizedDescription)")
        }
    }

    fileprivate func setToDevice(port: AVAudioSessionPortDescription) {
        do {
            // remove speaker if needed
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            // set new input
            try AVAudioSession.sharedInstance().setPreferredInput(port)
        } catch let error as NSError {
            print("audioSession error change to input: \(AVAudioSession.PortOverride.none.rawValue) with error: \(error.localizedDescription)")
        }
    }

    @objc
    func isCurrentOutput(portType: AVAudioSession.Port) -> Bool {
        AVAudioSession.sharedInstance().currentRoute.outputs.contains(where: { $0.portType == portType })
    }
}
