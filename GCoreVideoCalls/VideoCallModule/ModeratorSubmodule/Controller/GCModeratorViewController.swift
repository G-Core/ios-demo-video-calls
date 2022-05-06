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
    private let buttonsData = [ "Turn off all microphones", "Turn off all cameras" ]
    
    private let turnOffButtonsStack: UIStackView = {
        let button: () -> GCoreButton = {
            let font = UIFont.montserratMedium(size: 14)
            let button = GCoreButton(font: font, image: nil)
            button.addTarget(self, action: #selector(tapOffButton(_:)), for: .touchUpInside)
            return button
        }
        
        let stack = UIStackView(arrangedSubviews:  [button(), button()] )
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
                buttons[i].setTitle(buttonsData[i], for: .normal)
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
    
    @objc private func tapOffButton(_ button: GCoreButton) {
        let text = button.titleLabel?.text
        let trackKind: Kind = (text == buttonsData[0]) ? .audio : .video
        
        for item in model.remoteVideoItems {
            roomClient?.disableTrackProducerByModerator(peerId: item.userData.id, kind: trackKind.rawValue)
        }
    }
}

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


extension GCModeratorViewController: RoomModerator {
    func userJoinInWaitingRoom(_ user: User) {
        model.moderatorRoom.waitingUsers += [user]
        moderatorTableView.reloadSections(.init(integer: 0), with: .automatic)
    }
    
    func requestToModerator(_ mediaKind: MediaTrackKind, from user: User) {
        model.moderatorRoom.requestsUsers += [ (user, mediaKind) ]
        moderatorTableView.reloadSections(.init(integer: 1), with: .automatic)
    }
}
