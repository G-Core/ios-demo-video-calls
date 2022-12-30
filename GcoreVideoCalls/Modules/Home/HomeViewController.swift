import UIKit

final class HomeViewController: BaseViewController {
    // MARK: - Private properties
    private lazy var homeView = HomeMainView(delegate: self)
    private lazy var homeCollectionDelegate = HomeCollectionDelegate()
    private lazy var homeCollectionDataSource = HomeCollectionDataSource()

    // MARK: - Life cycle
    override func loadView() {
        view = homeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        homeCollectionDelegate.togglePageOffSetHandler = { [weak self] offSet in
            self?.homeView.setPageOffSet(offSet)
        }

        homeView.configureCollection(delegate: homeCollectionDelegate, source: homeCollectionDataSource)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    // MARK: - Private methods
    private func generateId() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let stringLenght = 15

        var id = "serv1"
        for _ in 1...stringLenght {
            guard let char = letters.randomElement() else { break }
            id.append(char)
        }

        return id
    }
}

// MARK: - HomeMainViewDelegate
extension HomeViewController: HomeMainViewDelegate {
    func createVideoCall() {
        RoomConfigurator.roomId = generateId()
        let vc = CreateRoomViewController()
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }

    func connectToVideoCall() {
        let vc = ConnectWithLinkViewController()
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}
