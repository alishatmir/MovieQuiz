import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!

    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var isLock = false
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory

        alertPresenter = AlertPresenter()
        statisticService = StatisticService()
        
        view.backgroundColor = .ypBackground
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        initialSetup()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {return}
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func initialSetup() {
        questionFactory?.requestNextQuestion()
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderColor = nil
        imageView.layer.borderWidth = 0
        
        isLock = false
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let currentResult = GameResult(
                correct: correctAnswers,
                total: questionsAmount,
                date: Date()
            )
            
            statisticService?.storeIfNeeded(result: currentResult)
            
            let firstRow = "Ваш результат: \(correctAnswers)/\(questionsAmount)\n"
            let secondRow = "Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)\n"
            let bestGameDate = statisticService?.bestGame.date.dateTimeString ?? ""
            let thirdRow = "Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(statisticService?.bestGame.total ?? questionsAmount) (\(bestGameDate))\n"
            let fourthRow = "Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%"
            let text = firstRow + secondRow + thirdRow + fourthRow
            
            alertPresenter?.showAlert(
                using: .init(
                    title: "Этот раунд окончен!",
                    message: text,
                    buttonText: "Сыграть еще раз",
                    completion: { [weak self] in
                        self?.currentQuestionIndex = 0
                        self?.correctAnswers = 0
                        self?.initialSetup()
                    }
                ),
                from: self
            )
        } else {
            currentQuestionIndex += 1
            
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.borderWidth = 8
        
        if isCorrect {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion, !isLock else { return }
        isLock = true
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion, !isLock else { return }
        isLock = true
        
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
}
