import UIKit

protocol AlertPresenterProtocol {
    func showAlert(using model: AlertModel, from viewController: UIViewController)
}

class AlertPresenter: AlertPresenterProtocol {
    
    func showAlert(using model: AlertModel, from viewController: UIViewController) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default,
            handler: { _ in
                model.completion()
            }
        )
        
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
