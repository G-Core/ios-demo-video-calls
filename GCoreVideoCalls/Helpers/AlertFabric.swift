//
//  AlertFabric.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 28.04.2022.
//

import UIKit

struct AlertFabric {
    enum AlertType {
        case badConnection, invalidRoomLink, emptyUserName, kickByModerator, moderatorRejectedJoinRequest
        case requestByModerator(MediaTrackKind), disableByModerator(MediaTrackKind), askToModeratorToTurn(MediaTrackKind)
    }
    
    static func newAlert(type: AlertType, handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        var action: UIAlertAction?
        var actionCancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        switch type {
        case .badConnection:
            alert.title = "Bad internet connection!"
            
        case .invalidRoomLink:
            alert.title = "Invalid room link"
            
        case .emptyUserName:
            alert.title = "Name is empty"
            alert.message = "Continue connecting?"
            action = UIAlertAction(title: "Yes", style: .default, handler: handler)
            
        case .kickByModerator:
            alert.message = "You were kicked by a moderator"
            actionCancel = UIAlertAction(title: "Cancel", style: .destructive, handler: handler)
            
        case .requestByModerator(let callTrackKind):
            alert.message = "Moderator asked to turn on the \(callTrackKind.rawValue)"
            action = UIAlertAction(title: "Turn on", style: .default, handler: handler)
            
        case .disableByModerator(let callTrackKind):
            alert.message = "Moderator disabled the \(callTrackKind.rawValue)"
            
        case .askToModeratorToTurn(let callTrackKind):
            alert.message = "Request to turn on the \(callTrackKind.rawValue)?"
            action = UIAlertAction(title: "Yes", style: .default, handler: handler)
            
        case .moderatorRejectedJoinRequest:
            alert.message = "Moderator rejected the request"
            actionCancel = UIAlertAction(title: "Cancel", style: .destructive, handler: handler)
        }
        
        if let action = action {
            alert.addAction(action)
        }
        
        alert.addAction(actionCancel)
        alert.backgroundColor = .blueMagenta
        alert.setTitleAttr(font: nil, color: .white)
        alert.setMessageAttr(font: nil, color: .white)
        
        action?.textColor = .white
        
        return alert
    }
}

private extension UIAlertController {
    var backgroundColor: UIColor? {
        get { view.subviews.first?.subviews.first?.subviews.first?.backgroundColor }
        set { view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = newValue }
    }
    
    func setTitleAttr(font: UIFont?, color: UIColor?) {
        guard let title = title else { return }
        
        let attributeString = NSMutableAttributedString(string: title)
        
        if let titleFont = font {
            attributeString.addAttributes([.font : titleFont],
                                          range: NSMakeRange(0, title.utf8.count))
        }
        
        if let titleColor = color {
            attributeString.addAttributes([.foregroundColor: titleColor],
                                          range: NSMakeRange(0, title.utf8.count))
        }
        
        setValue(attributeString, forKey: "attributedTitle")
    }
    
    func setMessageAttr(font: UIFont?, color: UIColor?) {
        guard let message = message else { return }
        
        let attributeString = NSMutableAttributedString(string: message)
        
        if let messageFont = font {
            attributeString.addAttributes([.font: messageFont],
                                          range: NSMakeRange(0, message.utf8.count))
        }
        
        if let messageColor = color {
            attributeString.addAttributes([.foregroundColor: messageColor],
                                          range: NSMakeRange(0, message.utf8.count))
        }
        
        setValue(attributeString, forKey: "attributedMessage")
    }
    
    var tintColor: UIColor? {
        get { view.tintColor }
        set { view.tintColor = newValue }
    }
}

private extension UIAlertAction {
    var textColor: UIColor? {
        get { value(forKey: "titleTextColor") as? UIColor }
        set { setValue(newValue, forKey: "titleTextColor") }
    }
}
