import GCoreVideoCallsSDK

final class UserCollectionViewCell: UICollectionViewCell {
    //MARK: - Static properties
    static let cellId = "UserCollectionViewCellId"

    //MARK: - Private properties
    private let gcMeet = GCoreMeet.shared
    private let letterImageView = LetterImageView(size: SizeHelper.letterImageRectangularCellSize)

    private let nameLabel = UILabel(
        font: .gcoreMediumlFont(withSize: SizeHelper.screenHeight * 0.018)
    )

    private let microphoneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = .microphoneImage
        return imageView
    }()

    //MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .veryDarkBlue
        layer.cornerRadius = SizeHelper.viewCornerRadius
        nameLabel.textAlignment = .left
        setupHierarchy()
        initConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods & Actions

    func configure(with model: RemoteUser) {
        let isLocalUser = model.name == gcMeet.localUser?.id
        nameLabel.text = isLocalUser ? (model.name + " (you)") : model.name
        letterImageView.image = LetterImageGenerator.imageWith(name: model.name)
        letterImageView.backgroundColor = model.bgColor
        microphoneImageView.image = model.isMicroEnable ? .microphoneImage : .disableMicro
    }

    // MARK: - Private methods & Actions
    private func setupHierarchy() {
        addSubview(letterImageView)
        addSubview(nameLabel)
        addSubview(microphoneImageView)
    }

    private func initConstraints() {
        let screenSideInstets = SizeHelper.screenWidth * 0.021
        let letterImageVIewRightInset = -(SizeHelper.screenWidth * 0.032)
        let labelRightInset = -(SizeHelper.screenWidth * 0.04)

        NSLayoutConstraint.activate([
            letterImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            letterImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: screenSideInstets),
            letterImageView.widthAnchor.constraint(equalToConstant: SizeHelper.letterImageRectangularCellSize),
            letterImageView.heightAnchor.constraint(equalToConstant: SizeHelper.letterImageRectangularCellSize),
            letterImageView.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: letterImageVIewRightInset),

            nameLabel.centerYAnchor.constraint(equalTo: letterImageView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: microphoneImageView.leadingAnchor, constant: labelRightInset),

            microphoneImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            microphoneImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(screenSideInstets))
        ])
    }
}
