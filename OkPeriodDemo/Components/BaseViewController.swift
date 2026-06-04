//
//  BaseViewController.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import UIKit

class BaseViewController: UIViewController {
    private let loadingView = LoadingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        configureLoadingView()
    }

    private func configureLoadingView() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.isHidden = true
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setLoading(_ isLoading: Bool) {
        loadingView.isHidden = !isLoading
        if isLoading {
            loadingView.startAnimating()
        } else {
            loadingView.stopAnimating()
        }
        view.isUserInteractionEnabled = !isLoading
    }

    func showError(_ error: AuthError) {
        AlertPresenter.show(on: self, message: error.errorDescription ?? AuthError.unknown.errorDescription!)
    }

    func showError(message: String) {
        AlertPresenter.show(on: self, message: message)
    }
}
