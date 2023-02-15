import UIKit

final class ConnectWithLinkViewController: BaseViewController {
    // MARK: - Private properties
    private let urlTextField = GcoreTextField(placeholder: "URL")

    private let mainLabel = UILabel(
        text: .connectionScreenHeader,
        font: .gcoreSemiBoldFont(withSize: SizeHelper.screenHeight * 0.024)
    )

    private let descriptionLabel = UILabel(
        text: .connectionScreenDescription,
        font: .gcoreRegularFont(withSize: SizeHelper.screenHeight * 0.018)
    )

    private let nextButton = GcoreButton(
        font: .gcoreSemiBoldFont(withSize: SizeHelper.screenHeight * 0.02),
        image: nil,
        text: "Next"
    )

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        initConstraints()

        nextButton.addTarget(nil, action: #selector(nextButtonTapped(_:)), for: .touchUpInside)
        urlTextField.delegate = self

        descriptionLabel.textAlignment = .left
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }

    // MARK: - Private methods
    @objc
    private func nextButtonTapped(_ sender: UIButton) {
        guard let text = urlTextField.text else { return }

        if RoomConfigurator.checkRoomId(from: text) {
            let vc = PreviewViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate
extension ConnectWithLinkViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}

// MARK: - Private implementation
private extension ConnectWithLinkViewController {
    func setupHierarchy() {
        view.addSubview(urlTextField)
        view.addSubview(nextButton)
    }

    func initConstraints() {
        let stackTopInset = SizeHelper.screenHeight * 0.051
        let stackSideInsets = SizeHelper.screenWidth * 0.042
        let bottomInsets = SizeHelper.screenHeight * 0.029
        let stackSpacing = Int(CGFloat(SizeHelper.screenHeight * 0.014))

        let labelStackView = UIStackView(
            views: [mainLabel, descriptionLabel],
            axis: .vertical,
            spacing: stackSpacing,
            alignment: .leading,
            distribution: .equalCentering
        )

        view.addSubview(labelStackView)

        NSLayoutConstraint.activate([
            labelStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: stackSideInsets),
            labelStackView.bottomAnchor.constraint(equalTo: urlTextField.topAnchor, constant: -bottomInsets),
            labelStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -stackSideInsets),
            labelStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: stackTopInset),

            urlTextField.leadingAnchor.constraint(equalTo: labelStackView.leadingAnchor),
            urlTextField.trailingAnchor.constraint(equalTo: labelStackView.trailingAnchor),
            urlTextField.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -bottomInsets),

            nextButton.leadingAnchor.constraint(equalTo: labelStackView.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: labelStackView.trailingAnchor),
        ])
    }
}
