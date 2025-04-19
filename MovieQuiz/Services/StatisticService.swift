import Foundation

final class StatisticService {
    private let storage: UserDefaults = .standard
    private let questionsAmount = 10
    
    private var totalCorrect: Int {
        get {
            storage.integer(forKey: Keys.correct.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    private var totalQuestions: Int {
        gamesCount * questionsAmount
    }
    
    private enum Keys: String {
        case correct
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
    }
}

extension StatisticService: StatisticServiceProtocol {
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            GameResult(
                correct: storage.integer(forKey: Keys.bestGameCorrect.rawValue),
                total: storage.integer(forKey: Keys.bestGameTotal.rawValue),
                date: storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            )
        }
        set(newValue) {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        gamesCount != 0 ? Double(totalCorrect) / Double(totalQuestions) * 100 : 0
    }
    
    func storeIfNeeded(result: GameResult) {
        gamesCount += 1
        totalCorrect += result.correct
        if result.isBetterThan(bestGame) {
            bestGame = result
        }
    }
}
