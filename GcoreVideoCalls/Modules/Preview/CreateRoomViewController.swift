import UIKit

final class CreateRoomViewController: PreviewViewController {
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .personImage,
            style: .done,
            target: self,
            action: #selector(inviteButtonTapped(_:))
        )
    }

    // MARK: - Private methods & Actions
    @objc
    private func inviteButtonTapped(_ sender: UIBarButtonItem) {
        present(ActivityViewController.shared.vc, animated: true)
    }
}
