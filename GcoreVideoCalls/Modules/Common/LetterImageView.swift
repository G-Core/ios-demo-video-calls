import UIKit

final class LetterImageView: UIImageView {
    init(size: CGFloat = 78) {
        super.init(frame: .zero)

        layer.cornerRadius = size / 2
        translatesAutoresizingMaskIntoConstraints = false

        heightAnchor.constraint(equalToConstant: size).isActive = true
        widthAnchor.constraint(equalToConstant: size).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
