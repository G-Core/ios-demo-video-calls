import UIKit

final class HomeScreenCollectionViewCell: UICollectionViewCell {
    static let cellId = "HomeScreenCollectionViewCellId"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let fontSize = SizeHelper.screenHeight * 0.029
        let font: UIFont? = .edgeCenterSemiBoldFont(withSize: fontSize)
        return UILabel(font: font)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(descriptionLabel)
        backgroundColor = .clear
        initConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with image: UIImage?, and text: String) {
        let topImagePadding = -(SizeHelper.screenHeight * 0.016)
        let insets = UIEdgeInsets(top: topImagePadding, left: 0, bottom: 0, right: 0)
        let configuredImage = image?.withAlignmentRectInsets(insets)
        imageView.image = configuredImage
        descriptionLabel.text = text
    }

    private func initConstraints() {
        let imageViewTopInset = SizeHelper.screenHeight * 0.006
        let imageViewHeight =  SizeHelper.screenHeight * 0.22
        let imageViewWidth = SizeHelper.screenWidth * 0.53

        let labelTopInset = SizeHelper.screenHeight * 0.039
        let labelSideInsets = SizeHelper.screenWidth * 0.085

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor , constant: imageViewTopInset),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: imageViewHeight),
            imageView.widthAnchor.constraint(equalToConstant: imageViewWidth),

            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: labelTopInset),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,  constant: labelSideInsets),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -labelSideInsets),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
