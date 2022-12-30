import UIKit

final class ActivityViewController {
    static let shared = ActivityViewController()

    let vc: UIActivityViewController = {
        let url = RoomConfigurator.inviteURL
        let activityVC = UIActivityViewController(activityItems: [url ?? "no id"], applicationActivities: nil)
        activityVC.view.layer.backgroundColor = UIColor.black.cgColor
        return activityVC
    }()
    
    private init() { }
}
