import UIKit

struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше, чем 6?",
            correctAnswer: false)
    ]
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var isLock = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackground
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        initialSetup()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text, // 3
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
    
    private func initialSetup() {
        if currentQuestionIndex < questions.count {
            let firstQuizStep = convert(model: questions[currentQuestionIndex])
            show(quiz: firstQuizStep)
        }
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
        if currentQuestionIndex == questions.count - 1 {
            showResultAlert(
                with: .init(
                    title: "Этот раунд окончен!",
                    text: "Ваш результат \(correctAnswers)/10",
                    buttonText: "Сыграть еще раз"
                )
            )
        } else {
            currentQuestionIndex += 1
            
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            show(quiz: viewModel)
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.borderWidth = 8
        
        if isCorrect {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showResultAlert(with model: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.text,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default
        ) { [weak self] _ in
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            self?.initialSetup()
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard !isLock else { return }
        isLock = true
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard isLock == false else { return }
        isLock = true
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
}
