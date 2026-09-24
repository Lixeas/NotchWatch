import XCTest
@testable import NotchWatch

final class ClaudeModelsTests: XCTestCase {
    func testDecodeAndPercentUsed() throws {
        let json = """
        {
            "extra_usage": {
                "is_enabled": true,
                "monthly_limit": 200000,
                "used_credits": 50000,
                "currency": "USD"
            },
            "five_hour": { "utilization": 0.42, "resets_at": "2026-09-24T12:00:00Z" },
            "seven_day": { "utilization": 0.10, "resets_at": "2026-09-28T00:00:00Z" }
        }
        """.data(using: .utf8)!

        let usage = try JSONDecoder().decode(ClaudeUsage.self, from: json)

        XCTAssertEqual(usage.extraUsage?.usedUSD, 500.0)
        XCTAssertEqual(usage.extraUsage?.limitUSD, 2000.0)
        XCTAssertEqual(usage.extraUsage?.percentUsed, 0.25)
        XCTAssertEqual(usage.fiveHour?.utilization, 0.42)
        XCTAssertEqual(usage.sevenDay?.utilization, 0.10)
    }

    func testPercentUsedGuardsZeroLimit() {
        let extra = ExtraUsage(isEnabled: true, monthlyLimit: 0, usedCredits: 100, currency: "USD")
        XCTAssertEqual(extra.percentUsed, 0)
    }
}
