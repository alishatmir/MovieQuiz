import UIKit

final class MovieQuizPresenter {
    
    private let statisticService: StatisticServiceProtocol
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var isLock = false

    
    init(viewController: MovieQuizViewController) {
        self.statisticService = StatisticService()
        self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.viewController = viewController
        
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }
}

private extension MovieQuizPresenter {
    
    func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            let currentResult = GameResult(
                correct: correctAnswers,
                total: questionsAmount,
                date: Date()
            )
            
            statisticService.storeIfNeeded(result: currentResult)
            
            let firstRow = "Ваш результат: \(correctAnswers)/\(questionsAmount)\n"
            let secondRow = "Количество сыгранных квизов: \(statisticService.gamesCount)\n"
            let bestGameDate = statisticService .bestGame.date.dateTimeString
            let thirdRow = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(bestGameDate))\n"
            let fourthRow = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            let text = firstRow + secondRow + thirdRow + fourthRow
            
            viewController?.showAlert(
                with: .init(
                    title: "Этот раунд окончен!",
                    message: text,
                    buttonText: "Сыграть еще раз",
                    completion: { [weak self] in
                        self?.restartGame()
                    }
                )
            )
        } else {
            currentQuestionIndex += 1
            
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion, !isLock else { return }
        isLock = true
        
        let isCorrect = currentQuestion.correctAnswer == isYes
        
        if isCorrect {
            correctAnswers += 1
        }
        
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
}

extension MovieQuizPresenter: QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {return}
        
        let viewModel = convert(model: question)
        
        currentQuestion = question
        
        DispatchQueue.main.async { [weak self] in
            self?.isLock = false
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
}
