import UIKit

extension UILabel {
    convenience init(text: String? = nil, font: UIFont?, alignment: NSTextAlignment = .center, color: UIColor = .white) {
        self.init(frame: .zero)

        self.text = text
        self.font = font
        self.textAlignment = alignment
        self.textColor = color

        self.translatesAutoresizingMaskIntoConstraints = false

        self.numberOfLines = 0
    }
}
