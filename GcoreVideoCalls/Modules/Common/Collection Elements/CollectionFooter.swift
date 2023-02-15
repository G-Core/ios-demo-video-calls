import UIKit

final class CollectionFooter: UICollectionReusableView {
    static let identifier = "CollectionFooterId"

    weak var delegate: ActivityPresenterProtocol!

    private let inviteButton = GcoreButton(
        font: .edgeCenterSemiBoldFont(withSize: 16),
        image: .personImage,
        text: "Invite participants",
        bgColor: .clear
    )

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .corbeau

        inviteButton.layer.borderWidth = 1
        inviteButton.layer.borderColor = UIColor.veryDarkBlue.cgColor
        inviteButton.addTarget(nil, action: #selector(inviteTapped(_:)), for: .touchUpInside)

        addSubview(inviteButton)
        initConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

   private func initConstraints() {
        let sidePadding = SizeHelper.collectionSidePadding
        NSLayoutConstraint.activate([
            inviteButton.topAnchor.constraint(equalTo: topAnchor),
            inviteButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: sidePadding),
            inviteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -sidePadding),
            inviteButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc
    private func inviteTapped(_ sender: UIButton) {
        delegate.presentActivityVC()
    }
}
