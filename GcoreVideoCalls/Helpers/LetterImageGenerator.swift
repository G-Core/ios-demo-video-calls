import UIKit

final class LetterImageGenerator: NSObject {
    class func imageWith(name: String?) -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: 78, height: 78)
        
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white
        nameLabel.font = .edgeCenterRegularFont(withSize: 28)
        
        var initials = ""
        
        if let initialsArray = name?.components(separatedBy: " ") {
            if let firstWord = initialsArray.first {
                if let firstCharachter = firstWord.first {
                    initials += String(firstCharachter).capitalized
                }
            }
            
            if initialsArray.count > 1, let lastWord = initialsArray.last {
                if let lastCharachter = lastWord.first {
                    initials += String(lastCharachter).capitalized
                }
            }
        } else {
            return nil
        }
        
        nameLabel.text = initials
        
        UIGraphicsBeginImageContext(frame.size)
        
        if let currentContext =  UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            return nameImage
        }
        return nil
    }
}
