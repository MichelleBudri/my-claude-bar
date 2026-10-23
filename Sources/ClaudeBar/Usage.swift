import Foundation

struct Usage: Decodable {
    let session: UsageWindow?
    let weekly: UsageWindow?

    enum CodingKeys: String, CodingKey {
        case session = "five_hour"
        case weekly = "seven_day"
    }
}

struct UsageWindow: Decodable {
    let utilization: Double
    let resetsAt: Date?

    var percent: Int { Int(utilization.rounded()) }

    enum CodingKeys: String, CodingKey {
        case utilization
        case resetsAt = "resets_at"
    }
}
