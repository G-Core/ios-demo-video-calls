import UIKit
import AdvancedPageControl

fileprivate typealias HomeCell = HomeScreenCollectionViewCell

protocol HomeMainViewDelegate: AnyObject {
    func createVideoCall()
    func connectToVideoCall()
}

final class HomeMainView: UIView {
    // MARK: - Public properties
    weak var delegate: HomeMainViewDelegate?

    // MARK: - Private properties
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo")
        return imageView
    }()

    private let descriptionLabel = UILabel(
        text: .homeScreenDescriptionText,
        font: .edgeCenterRegularFont(withSize: SizeHelper.screenHeight * 0.018),
        color: .lightGrey
    )

    private let typeOfCallsCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.isPagingEnabled = true
        collection.isScrollEnabled = true
        collection.showsHorizontalScrollIndicator = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()

    private let pageControl: AdvancedPageControlView = {
        let pageControl = AdvancedPageControlView()

        pageControl.drawer = ExtendedDotDrawer(
            numberOfPages: UIImage.homeScreenImages.count,
            height: SizeHelper.screenHeight * 0.009,
            width: SizeHelper.screenWidth * 0.021,
            space: SizeHelper.screenWidth * 0.021,
            indicatorColor: .purple,
            dotsColor: .purple
        )

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.drawer.currentItem = 0
        return pageControl
    }()

    private let createVideoCallButton = GcoreButton(
        font: .edgeCenterMediumlFont(withSize: SizeHelper.screenHeight * 0.019),
        image: .createVideoCallImage,
        text: "Create video call"
    )

    private let connectWithLinkButton = GcoreButton(
        font: .edgeCenterMediumlFont(withSize: SizeHelper.screenHeight * 0.019),
        image: .linkImage,
        text: "Join by link",
        bgColor: .clear
    )

    // MARK: - Init
    init(delegate: HomeMainViewDelegate) {
        super.init(frame: .zero)
        self.delegate = delegate
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Public methods
    func configureCollection(delegate: UICollectionViewDelegate, source: UICollectionViewDataSource) {
        typeOfCallsCollection.delegate = delegate
        typeOfCallsCollection.dataSource = source
        typeOfCallsCollection.reloadData()
    }

    func setPageOffSet(_ offSet: CGFloat) {
        pageControl.setPageOffset(offSet)
    }
}

// MARK: - Private implementation
private extension HomeMainView {
    func setupView() {
        descriptionLabel.numberOfLines = 3
        setupHierarchy()

        initConstraintsFor(
            logo: logoImageView,
            collection: typeOfCallsCollection,
            description: descriptionLabel,
            pageControl: pageControl,
            createButton: createVideoCallButton,
            connectButton: connectWithLinkButton
        )

        configureButtons()
        configureCollection()
    }

    func configureCollection() {
        typeOfCallsCollection.register(HomeCell.self, forCellWithReuseIdentifier: HomeCell.cellId)
        typeOfCallsCollection.backgroundColor = .clear
        typeOfCallsCollection.reloadData()
    }

    func configureButtons() {
        connectWithLinkButton.addTarget(nil, action: #selector(connectionButtonTapped(_:)), for: .touchUpInside)
        createVideoCallButton.addTarget(nil, action: #selector(createVideoCallButtonTapped(_:)), for: .touchUpInside)
    }

    func setupHierarchy() {
        addSubview(descriptionLabel)
        addSubview(logoImageView)
        addSubview(createVideoCallButton)
        addSubview(connectWithLinkButton)
        addSubview(typeOfCallsCollection)
        addSubview(pageControl)
    }

    @objc
    func connectionButtonTapped(_ sender: UIButton) {
        delegate?.connectToVideoCall()
    }

    @objc
    func createVideoCallButtonTapped(_ sender: UIButton) {
        delegate?.createVideoCall()
    }
}
