import Foundation
import WebRTC

struct RemoteUser {
    let view = RTCMTLVideoView()
    let sharingView = RTCMTLVideoView()
    let bgColor: UIColor? = .colorForLetterImage.randomElement()

    var isSpeaking = false
    var isMicroEnable = false
    var isVideoEnable = false
    var isScreenSharing = false

    var id = ""
    var name = ""
    var videoTrackID: String?
    var screenTrackID: String?

    init(name: String = "", id: String = "") {
        self.name = name
        self.id = id
        sharingView.videoContentMode = .scaleAspectFit
        sharingView.isUserInteractionEnabled = false
        view.isUserInteractionEnabled = false
    }
}
