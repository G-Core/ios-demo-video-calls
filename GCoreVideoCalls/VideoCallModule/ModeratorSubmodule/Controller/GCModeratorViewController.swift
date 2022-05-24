//
//  GCModeratorViewController.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 20.04.2022.
//

import UIKit
import GCoreVideoCallsSDK

final class GCModeratorViewController: GCBaseViewController {
    private enum RequestType {
        case join, permission
    }
    
    private let model = GCModel.shared
    private let cellId = "Cell"
    
    private let buttonsData: [[String]] = [
        ["Waiting Room is activated", "Waiting Room is deactivated"],
        ["Webcams are allowed", "Webcams are disallowed"],
        ["Mics are allowed", "Mics are disallowed"],
        ["Sharing is allowed", "Sharing is disallowed"],
        ["Turn off all microphones"],
        ["Turn off all cameras"],
    ]

    private let turnOffButtonsStack: UIStackView = {
        let button: (GCModeratorButton.ButtonType) -> GCModeratorButton = { type in
            let button = GCModeratorButton(type: type)
            button.addTarget(self, action: #selector(tapModeratorsButton(_:)), for: .touchUpInside)
            return button
        }
        
        let buttons = [
            button(.toggleWaitingRoom),
            button(.toggleCamsPermission),
            button(.toggleMicsPermission),
            button(.toggleSharingPermission),
            button(.turnOffAllMics),
            button(.turnOffAllCams)
        ]
        
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .vertical
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    lazy var moderatorTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.register(GCTableViewCell.self, forCellReuseIdentifier: cellId)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.layer.borderColor = UIColor.black.cgColor
        table.layer.borderWidth = 1.5
    
        return table
    }()
    
    weak var roomClient: GCoreRoomClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blueMagenta
        moderatorTableView.backgroundColor = .blueMagenta
        initConstraints()
        
        if let buttons = turnOffButtonsStack.arrangedSubviews as? [GCoreButton] {
            for i in buttons.indices {
                buttons[i].setTitle(buttonsData[i][0], for: .normal)
            }
        }
    }
    
    private func responseToRequest(tableIndex: Int, type: RequestType, isAccept: Bool) {
        guard let client = roomClient else { return }
        
        switch type {
        case .join:
            let user = model.moderatorRoom.waitingUsers.remove(at: tableIndex)
            
            if isAccept {
                client.acceptJoinRequestByModerator(peerId: user.id)
            } else {
                client.rejectJoinRequestByModerator(peerId: user.id)
            }
            
            moderatorTableView.reloadSections(.init(integer: 0), with: .automatic)
            
        case .permission:
            let tuple = model.moderatorRoom.requestsUsers.remove(at: tableIndex)
            let user = tuple.user
            let media = tuple.media.rawValue
            //
            if isAccept {
                client.acceptedPermissionByModerator(peerId: user.id, kind: media)
            } else {
                client.rejectPermissionByModerator(peerId: user.id, kind: media)
            }
            
            moderatorTableView.reloadSections(.init(integer: 1), with: .automatic)
        }
    }
    
    @objc private func tapModeratorsButton(_ button: GCModeratorButton) {
        switch button.type {
        case .toggleWaitingRoom:
            button.tag == 0 ? (button.tag = 1) : (button.tag = 0)
            button.setTitle(buttonsData[button.type.rawValue][button.tag], for: .normal)
            roomClient?.toggleWaitingRoom(currentWaitingRoomStatus: model.roomSettings.waitingRoomIsEnable)
            
        case .toggleCamsPermission :
            button.tag == 0 ? (button.tag = 1) : (button.tag = 0)
            button.setTitle(buttonsData[button.type.rawValue][button.tag], for: .normal)
            model.roomSettings.videoIsEnable = !model.roomSettings.videoIsEnable
            roomClient?.togglePermission(kind: MediaTrackKind.video.rawValue, isActive: model.roomSettings.videoIsEnable)
            
        case .toggleMicsPermission :
            button.tag == 0 ? (button.tag = 1) : (button.tag = 0)
            button.setTitle(buttonsData[button.type.rawValue][button.tag], for: .normal)
            model.roomSettings.audioIsEnable = !model.roomSettings.audioIsEnable
            roomClient?.togglePermission(kind: MediaTrackKind.audio.rawValue, isActive: model.roomSettings.audioIsEnable)
            
        case .toggleSharingPermission :
            button.tag == 0 ? (button.tag = 1) : (button.tag = 0)
            button.setTitle(buttonsData[button.type.rawValue][button.tag], for: .normal)
            model.roomSettings.shareIsEnable = !model.roomSettings.shareIsEnable
            roomClient?.togglePermission(kind: MediaTrackKind.share.rawValue, isActive: model.roomSettings.shareIsEnable)
            
        case .turnOffAllCams : roomClient?.disableAllMedia(kind: MediaTrackKind.video.rawValue)
        case .turnOffAllMics : roomClient?.disableAllMedia(kind: MediaTrackKind.audio.rawValue)
        }
    }
    
    func updateState() {
        waitingRoom(isActive: model.roomSettings.waitingRoomIsEnable)
        
        for button in turnOffButtonsStack.arrangedSubviews {
            guard let button = button as? GCModeratorButton else { continue }
            let tag: Int
            
            switch button.type {
            case .toggleCamsPermission: model.roomSettings.videoIsEnable ? (tag = 0) : (tag = 1)
            case .toggleMicsPermission: model.roomSettings.audioIsEnable ? (tag = 0) : (tag = 1)
            case .toggleSharingPermission: model.roomSettings.shareIsEnable ? (tag = 0) : (tag = 1)
            default: continue
        }
            
            button.tag = tag
            button.setTitle(buttonsData[button.type.rawValue][button.tag], for: .normal)
        }
    }
}

//MARK: - Layout
extension GCModeratorViewController {
    private func initConstraints() {
        view.addSubview(turnOffButtonsStack)
        view.addSubview(moderatorTableView)
        
        NSLayoutConstraint.activate([
            turnOffButtonsStack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            turnOffButtonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            turnOffButtonsStack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2),
            
            moderatorTableView.topAnchor.constraint(equalTo: turnOffButtonsStack.bottomAnchor, constant: 20),
            moderatorTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            moderatorTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            moderatorTableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension GCModeratorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = .white
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Waiting room" : "Users request"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? model.moderatorRoom.waitingUsers.count : model.moderatorRoom.requestsUsers.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! GCTableViewCell
        
        if indexPath.section == 0 {
            cell.setText(model.moderatorRoom.waitingUsers[indexPath.row].name)
        } else {
            let tuple = model.moderatorRoom.requestsUsers[indexPath.row]
            cell.setText(tuple.user.name + " - " + tuple.media.rawValue)
        }
        
        cell.layer.borderColor = moderatorTableView.backgroundColor?.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let acceptAction = UIContextualAction(style: .normal, title: "Accept") { [weak self] (action, view, completionHandler) in
            let type: RequestType = indexPath.section == 0 ? .join : .permission
            self?.responseToRequest(tableIndex: indexPath.row, type: type, isAccept: true)
            completionHandler(true)
        }
        
        let rejectAction = UIContextualAction(style: .normal, title: "Reject") { [weak self] (action, view, completionHandler) in
            let type: RequestType = indexPath.section == 0 ? .join : .permission
            self?.responseToRequest(tableIndex: indexPath.row, type: type, isAccept: false)
            completionHandler(true)
        }
        
        acceptAction.backgroundColor = .moderatorAcceptButtonColor
        rejectAction.backgroundColor = .moderatorRejectButtonColor
        
        let config = UISwipeActionsConfiguration(actions: [rejectAction, acceptAction])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        false
    }
}

//MARK: - GCModeratorControlViewDelegate
extension GCModeratorViewController: GCModeratorControlViewDelegate {
    private typealias Kind = MediaTrackKind
    
    func didSelectCommand(_ method: ModeratorMethods, for peerId: String) {
        switch method {
        case .remove: roomClient?.removeUserByModerator(peerId: peerId)
            
        case .turnOffCamera: roomClient?.disableTrackProducerByModerator(peerId: peerId, kind: Kind.video.rawValue)
        case .turnOffShare: roomClient?.disableTrackProducerByModerator(peerId: peerId, kind: Kind.share.rawValue)
        case .turnOffMicrophone: roomClient?.disableTrackProducerByModerator(peerId: peerId, kind: Kind.audio.rawValue)
            
        case .enableCamera: roomClient?.acceptedPermissionByModerator(peerId: peerId, kind: Kind.video.rawValue)
        case .enableShare: roomClient?.acceptedPermissionByModerator(peerId: peerId, kind: Kind.share.rawValue)
        case .enableMicrophone: roomClient?.acceptedPermissionByModerator(peerId: peerId, kind: Kind.audio.rawValue)
        }
        
        parent?.becomeFirstResponder()
    }
}

//MARK: - RoomModerator
extension GCModeratorViewController: RoomModerator {
    func otherModeratorRejectPermission(media: MediaTrackKind, peerId: String) {
        model.moderatorRoom.requestsUsers.removeAll(where: { $0.media == media && $0.user.id == peerId })
        moderatorTableView.reloadSections(.init(integer: 1), with: .automatic)
    }
    
    func otherModeratorRejectJoin(peerId: String) {
        model.moderatorRoom.waitingUsers.removeAll(where: { $0.id == peerId })
        moderatorTableView.reloadSections(.init(integer: 0), with: .automatic)
    }
    
    func waitingRoom(isActive: Bool) {
        model.roomSettings.waitingRoomIsEnable = isActive
        let typeRawValue = GCModeratorButton.ButtonType.toggleWaitingRoom.rawValue
        let button = turnOffButtonsStack.arrangedSubviews[typeRawValue] as! GCModeratorButton
        isActive ? (button.tag = 0) : (button.tag = 1)
        button.setTitle(buttonsData[typeRawValue][button.tag], for: .normal)
    }
    
    func userJoinInWaitingRoom(_ user: User) {
        model.moderatorRoom.waitingUsers += [user]
        moderatorTableView.reloadSections(.init(integer: 0), with: .automatic)
    }
    
    func requestToModerator(_ mediaKind: MediaTrackKind, from user: User) {
        model.moderatorRoom.requestsUsers += [ (user, mediaKind) ]
        moderatorTableView.reloadSections(.init(integer: 1), with: .automatic)
    }
}
