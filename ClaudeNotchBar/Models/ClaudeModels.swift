import Foundation

struct ClaudeUsage: Codable {
    let extraUsage: ExtraUsage?
    let fiveHour: UsageWindow?
    let sevenDay: UsageWindow?
    
    enum CodingKeys: String, CodingKey {
        case extraUsage = "extra_usage"
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
    }
}

struct ExtraUsage: Codable {
    let isEnabled: Bool
    let monthlyLimit: Double?
    let usedCredits: Double?
    let currency: String?
    
    enum CodingKeys: String, CodingKey {
        case isEnabled = "is_enabled"
        case monthlyLimit = "monthly_limit"
        case usedCredits = "used_credits"
        case currency
    }
    
    var usedUSD: Double { (usedCredits ?? 0) / 100.0 }
    var limitUSD: Double { (monthlyLimit ?? 2000) / 100.0 }
    var percentUsed: Double { guard limitUSD > 0 else { return 0 }; return usedUSD / limitUSD }
}

struct UsageWindow: Codable {
    let utilization: Double?
    let resetsAt: String?
    
    enum CodingKeys: String, CodingKey {
        case utilization
        case resetsAt = "resets_at"
    }
}