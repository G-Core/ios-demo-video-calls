import UIKit

extension AlertFabric {
    enum AlertType {
        case leaveRoom
        case requestVideoPermissions
        case requestAudioPermissions
    }
}

struct AlertFabric {
    static func configAlert(type: AlertType, handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let title: String
        let message: String
        let actionTitle: String = type == .leaveRoom ? .leavingRoomActionTitle : .requstPermissionsActionTitle

        switch type {
        case .leaveRoom:
            title = .leavingRoomAlertTitle
            message = .leavingRoomAlertMessage

        case .requestVideoPermissions:
            title = .requestVideoPermissionAlertTitle
            message = .requestVideoPermissionAlertMessage

        case .requestAudioPermissions:
            title = .requestAudioPermissionAlertTitle
            message = .requestAudioPermissionAlertMessage
        }

        let alert = UIAlertController(title: title ,message: message, preferredStyle: .alert)
        let leaveRoomAction = UIAlertAction(title: actionTitle, style: .default, handler: handler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        for action in [cancelAction, leaveRoomAction] {
            alert.addAction(action)
        }
        
        alert.view.layer.cornerRadius = SizeHelper.viewCornerRadius
        alert.view.layer.masksToBounds = true
        
        return alert
    }
}
