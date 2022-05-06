//
//  Extensions.swift
//  GCoreVideoCalls
//
//  Created by Evgenij Polubin on 24.03.2022.
//

import UIKit

//MARK: - UIImage

extension UIImage {
    static var icModerator: UIImage? {
        UIImage(named: "ic_moderator")
    }
    static var icCheck: UIImage? {
        UIImage(named: "ic_check")
    }
    
    static var cameraMute: UIImage? {
        UIImage(named: "ic_camera-mute")
    }
    
    static var camera: UIImage? {
        UIImage(named: "ic_camera")
    }
    
    static var microphoneMute: UIImage? {
        UIImage(named: "ic_microphone-mute")
    }
    
    static var microphone: UIImage? {
        UIImage(named: "ic_microphone")
    }
    
    static var meetTitle: UIImage? {
        UIImage(named: "MeetTitle")
    }
    
    static var gcoreTitle: UIImage? {
        UIImage(named: "G-CoreTitle")
    }
    
    static var copyIcon: UIImage? {
        UIImage(named: "copyIcon")
    }
    
    static var gcBody: UIImage? {
        UIImage(named: "body")
    }
    
    static var switchPositionCamera: UIImage? {
        UIImage(named: "switchPositionCamera")
    }
    
    static var phoneIcon: UIImage? {
        UIImage(named: "phone")
    }
    
    static var peerImage: UIImage? {
        UIImage(named: "peerImage")
    }
    
    static var twitterImage: UIImage? {
        UIImage(named: "twitter")
    }
    
    static var facebookImage: UIImage? {
        UIImage(named: "facebook")
    }
    
    static var linkedInImage: UIImage? {
        UIImage(named: "linkedin")
    }
    
    static var shareIconImage: UIImage? {
        UIImage(named: "ic_share")
    }
}

//MARK: - UIColor

extension UIColor {
    static var moderatorAcceptButtonColor: UIColor? {
        UIColor(red: 78/255, green: 154/255, blue: 241/255, alpha: 1)
    }
    
    static var moderatorRejectButtonColor: UIColor? {
        UIColor(red: 241/255, green: 78/255, blue: 78/255, alpha: 1)
    }
    
    static var blueMagentaVeryDark: UIColor? {
        UIColor(red: 19/255, green: 17/255, blue: 32/255, alpha: 1)
    }
    
    static var blueMagentaDark: UIColor? {
        UIColor(red: 25/255, green: 21/255, blue: 46/255, alpha: 1)
    }
    
    static var cyanBlueMediumLight: UIColor? {
        UIColor(red: 82/255, green: 151/255, blue: 248/255, alpha: 1)
    }
    
    static var verySoftRed: UIColor? {
        UIColor(red: 254/255, green: 191/255, blue: 203/255, alpha: 1)
    }
    
    static var darkWashedOrange: UIColor? {
        UIColor(red: 227/255, green: 99/255, blue: 46/255, alpha: 1)
    }
    
    static var redOrange: UIColor? {
        UIColor(red: 250/255, green: 81/255, blue: 36/255, alpha: 1)
    }
    
    static var greenCyan: UIColor? {
        UIColor(red: 53/255, green: 219/255, blue: 168/255, alpha: 1)
    }
    
    static var blueMagenta: UIColor? {
        UIColor(red: 46/255, green: 38/255, blue: 74/255, alpha: 1)
    }
    
    static var gcGreen: UIColor? {
        UIColor(red: 105/255, green: 186/255, blue: 60/255, alpha: 1)
    }
    
    static var peerColor: UIColor? {
        UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1)
    }
    
    static var activePeerColor: UIColor? {
        UIColor(red: 114/255, green: 77/255, blue: 243/255, alpha: 1)
    }
}

//MARK: - UIFont

extension UIFont {
    static func montserratMedium(size: CGFloat) -> UIFont? {
        .init(name: "Montserrat-Medium", size: size)
    }
    
    static func montserratRegular(size: CGFloat) -> UIFont? {
        .init(name: "Montserrat-Regular", size: size)
    }
}

//MARK: - UIImageView

extension UIImageView {
    var contentClippingRect: CGRect {
        guard let image = image,
              contentMode == .scaleAspectFit,
              image.size.width > 0 && image.size.height > 0
        else { return bounds }
        
        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }
        
        let size = CGSize(width: image.size.width * scale,
                          height: image.size.height * scale)
        
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
