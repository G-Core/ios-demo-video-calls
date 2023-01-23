import UIKit

extension UIStackView {
    convenience init(views: [UIView], axis: NSLayoutConstraint.Axis, spacing: Int, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution) {
        self.init(arrangedSubviews: views)
        self.axis = axis
        self.spacing = CGFloat(spacing)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.alignment = alignment
        self.distribution = distribution
    }
}
