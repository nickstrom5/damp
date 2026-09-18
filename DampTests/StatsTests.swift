import XCTest
@testable import Damp

final class StatsTests: XCTestCase {
    private let cal = Calendar.current
    private var today: Date { cal.startOfDay(for: Date()) }

    private func day(_ daysAgo: Int) -> Date {
        cal.date(byAdding: .day, value: -daysAgo, to: today)!
    }

    private func log(_ daysAgo: Int, drinks: Int = 0) -> DayLog {
        DayLog(day: day(daysAgo), drinks: drinks)
    }

    private var answers: OnboardingAnswers {
        var a = OnboardingAnswers()
        a.drinksPerWeek = 7      // one a day, so the money math is easy
        a.pricePerDrink = 10
        return a
    }

    func testEmptyLogIsAllZeros() {
        let stats = Stats.compute(logs: [], answers: answers)
        XCTAssertEqual(stats, Stats())
    }

    func testOneDryNightTonightStartsStreak() {
        let stats = Stats.compute(logs: [log(0)], answers: answers)
        XCTAssertEqual(stats.streak, 1)
        XCTAssertEqual(stats.longestStreak, 1)
        XCTAssertEqual(stats.dryNights, 1)
        XCTAssertEqual(stats.moneySaved, 10, accuracy: 0.001)
        XCTAssertEqual(stats.caloriesSkipped, 150)
    }

    func testStreakSurvivesTonightNotLoggedYet() {
        let stats = Stats.compute(logs: [log(3), log(2), log(1)], answers: answers)
        XCTAssertEqual(stats.streak, 3)
    }

    func testStreakIsZeroWhenYesterdayWasMissed() {
        let stats = Stats.compute(logs: [log(3), log(2)], answers: answers)
        XCTAssertEqual(stats.streak, 0)
        XCTAssertEqual(stats.longestStreak, 2)
    }

    func testDrinkingNightBreaksStreakButKeepsLongest() {
        let stats = Stats.compute(logs: [log(4), log(3), log(2), log(1, drinks: 3), log(0)], answers: answers)
        XCTAssertEqual(stats.streak, 1)
        XCTAssertEqual(stats.longestStreak, 3)
        XCTAssertEqual(stats.dryNights, 4)
        XCTAssertEqual(stats.drinksLogged, 3)
    }

    func testMoneySavedIsBaselineMinusLogged() {
        // 5 nights at a baseline of 1/night = 5 expected. Logged 3. Skipped 2 × $10.
        let stats = Stats.compute(logs: [log(4), log(3), log(2, drinks: 2), log(1, drinks: 1), log(0)], answers: answers)
        XCTAssertEqual(stats.drinksSkipped, 2, accuracy: 0.001)
        XCTAssertEqual(stats.moneySaved, 20, accuracy: 0.001)
    }

    func testMoneySavedNeverGoesNegative() {
        let stats = Stats.compute(logs: [log(0, drinks: 12)], answers: answers)
        XCTAssertEqual(stats.drinksSkipped, 0)
        XCTAssertEqual(stats.moneySaved, 0)
    }

    func testDuplicateLogsForOneDayCountOnce() {
        var later = log(0, drinks: 2)
        later.loggedAt = Date().addingTimeInterval(60)
        let stats = Stats.compute(logs: [log(0), later], answers: answers)
        XCTAssertEqual(stats.loggedNights, 1)
        XCTAssertEqual(stats.drinksLogged, 2)
    }

    func testMoneyFormatting() {
        XCTAssertEqual(Stats.money(0), "$0")
        XCTAssertEqual(Stats.money(11.43), "$11")
        XCTAssertEqual(Stats.money(2377.2), "$2,377")
    }
}
