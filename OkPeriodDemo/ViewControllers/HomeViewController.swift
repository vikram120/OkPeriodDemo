//
//  HomeViewController.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import UIKit

final class HomeViewController: BaseViewController {
    weak var coordinator: AppCoordinator?
    private let viewModel = HomeViewModel()

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 48
        imageView.clipsToBounds = true
        imageView.backgroundColor = AppColors.primary.withAlphaComponent(0.15)
        imageView.tintColor = AppColors.primary
        imageView.accessibilityLabel = "Profile picture"
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = AppColors.textPrimary
        label.textAlignment = .center
        label.accessibilityTraits = .header
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var logoutButton: PrimaryButton = {
        let button = PrimaryButton(title: "Log Out", style: .outlined)
        button.accessibilityLabel = "Log out"
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return button
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.surface
        view.layer.cornerRadius = AppMetrics.cornerRadius
        view.layer.borderWidth = 1
        view.layer.borderColor = AppColors.border.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        viewModel.delegate = self
        configureUser()
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardView.fadeIn()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        cardView.layer.borderColor = AppColors.border.cgColor
    }

    private func configureUser() {
        guard let user = viewModel.user else { return }
        nameLabel.text = user.resolvedDisplayName
        emailLabel.text = user.email ?? "No email available"

        if user.provider == .google, let url = user.photoURL {
            profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
            loadProfileImage(from: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.crop.circle.fill")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 64, weight: .regular))
            profileImageView.tintColor = AppColors.primary
        }
    }

    private func loadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }.resume()
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [profileImageView, nameLabel, emailLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = AppMetrics.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(stack)
        view.addSubview(cardView)
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 96),
            profileImageView.heightAnchor.constraint(equalToConstant: 96),
            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: AppMetrics.spacingLarge),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: AppMetrics.spacingLarge),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -AppMetrics.spacingLarge),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -AppMetrics.spacingLarge),
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: AppMetrics.spacingLarge),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppMetrics.spacingLarge),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppMetrics.spacingLarge),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppMetrics.spacingLarge),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppMetrics.spacingLarge),
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -AppMetrics.spacing)
        ])
    }

    @objc private func logoutTapped() {
        AlertPresenter.showConfirmation(
            on: self,
            title: "Log Out",
            message: "Do you want to logout?",
            confirmTitle: "Yes",
            cancelTitle: "No"
        ) { [weak self] in
            self?.viewModel.signOut()
        }
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func homeViewModelDidSignOut(_ viewModel: HomeViewModel) {
        coordinator?.showAuth()
    }

    func homeViewModel(_ viewModel: HomeViewModel, didFail error: AuthError) {
        showError(error)
    }
}
