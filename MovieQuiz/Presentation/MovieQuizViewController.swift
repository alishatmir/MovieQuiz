import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet var noButton: UIButton!
    @IBOutlet var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        alertPresenter = AlertPresenter()
        presenter = MovieQuizPresenter(viewController: self)
        
        view.backgroundColor = .ypBackground
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = .clear
        textLabel.text = ""
        questionLabel.font = YSDisplay.medium.font(with: 20)
        counterLabel.font = YSDisplay.medium.font(with: 20)
        textLabel.font = YSDisplay.bold.font(with: 23)
        noButton.titleLabel?.font = YSDisplay.medium.font(with: 20)
        yesButton.titleLabel?.font = YSDisplay.medium.font(with: 20)
    }
    
    func showAlert(with model: AlertModel) {
        alertPresenter?.showAlert(using: model, from: self)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self else { return }
            
            self.presenter.restartGame()
        }
        
        alertPresenter?.showAlert(using: model, from: self)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderColor = nil
        imageView.layer.borderWidth = 0
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.borderWidth = 8
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
}
