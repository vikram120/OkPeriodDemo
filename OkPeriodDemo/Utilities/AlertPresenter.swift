//
//  AlertPresenter.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import UIKit

enum AlertPresenter {
    static func show(
        on viewController: UIViewController,
        title: String = "Something went wrong",
        message: String,
        buttonTitle: String = "OK"
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default))
        viewController.present(alert, animated: true)
    }

    static func showConfirmation(
        on viewController: UIViewController,
        title: String,
        message: String,
        confirmTitle: String = "Yes",
        cancelTitle: String = "No",
        onConfirm: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: confirmTitle, style: .destructive) { _ in
            onConfirm()
        })
        viewController.present(alert, animated: true)
    }
}
