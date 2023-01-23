import Foundation
import WebRTC

struct RemoteUser {
    let view = RTCMTLVideoView()

    var id: String = ""
    var name: String = ""

    let bgColor: UIColor? = .colorForLetterImage.randomElement()

    var isSpeaking: Bool = false
    var isMicroEnable: Bool = false
    var isVideoEnable: Bool = false

    init(name: String = "", id: String = "") {
        self.name = name
        self.id = id
    }
}
