import XCTest
@testable import Damp

final class OnboardingAnswersTests: XCTestCase {
    func testDefaultIsAverageUser() {
        let a = OnboardingAnswers()
        XCTAssertEqual(a.drinksPerWeek, 10)
        XCTAssertEqual(a.yearlySpend, 4_160)
        XCTAssertEqual(a.yearlyCalories, 78_000)
        XCTAssertEqual(a.yearlyDaysOfFood, 39)
        XCTAssertEqual(a.savedPerDryNight, 11.428, accuracy: 0.01)
        XCTAssertEqual(a.yearlySavingsAtGoal, 2_377)
        XCTAssertEqual(a.weeklySavingsAtGoal, 46)
    }

    func testHeavyDrinkerAtBarPrices() {
        var a = OnboardingAnswers()
        a.drinksPerWeek = 20
        a.pricePerDrink = 14
        a.dryNightsGoal = 5
        XCTAssertEqual(a.yearlySpend, 14_560)
        XCTAssertEqual(a.yearlyDaysOfFood, 78)
        XCTAssertEqual(a.yearlySavingsAtGoal, 10_400)
    }

    func testLightDrinker() {
        var a = OnboardingAnswers()
        a.drinksPerWeek = 3
        a.pricePerDrink = 3
        a.dryNightsGoal = 7
        XCTAssertEqual(a.yearlySpend, 468)
        XCTAssertEqual(a.yearlySavingsAtGoal, 468)
    }

    func testRoundTripsThroughJSON() throws {
        var a = OnboardingAnswers()
        a.drinksPerWeek = 12
        a.pricePerDrink = 9.5
        a.reasons = [.sleep, .money]
        a.dryNightsGoal = 5
        let data = try JSONEncoder().encode(a)
        let decoded = try JSONDecoder().decode(OnboardingAnswers.self, from: data)
        XCTAssertEqual(decoded, a)
    }
}
