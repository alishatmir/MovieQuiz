import UIKit

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }

    func storeIfNeeded(result: GameResult)
}
