import Foundation

enum UsageError: LocalizedError {
    case notLoggedIn
    case tokenExpired
    case http(Int)

    var errorDescription: String? {
        switch self {
        case .notLoggedIn: "Faça login no Claude Code (`claude`) primeiro."
        case .tokenExpired: "Token expirado - abra o Claude Code para renová-lo."
        case .http(let status): "Erro HTTP \(status)"
        }
    }
}

enum UsageService {
    private static let usageURL = URL(string: "https://api.anthropic.com/api/oauth/usage")!
    private static let keychainService = "Claude Code-credentials"

    static func fetchUsage() async throws -> Usage {
        var request = URLRequest(url: usageURL, timeoutInterval: 20)
        request.setValue("Bearer \(try readAccessToken())", forHTTPHeaderField: "Authorization")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")

        let (data, response) = try await URLSession.shared.data(for: request)
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
        case 200: return try decoder.decode(Usage.self, from: data)
        case 401: throw UsageError.tokenExpired
        case let status: throw UsageError.http(status)
        }
    }

    // Goes through /usr/bin/security instead of the Keychain API: the item belongs to
    // Claude Code and `security` is already trusted by it, so macOS doesn't prompt.
    private static func readAccessToken() throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process.arguments = ["find-generic-password", "-s", keychainService, "-w"]
        let output = Pipe()
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice

        try process.run()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        struct Credentials: Decodable {
            struct OAuth: Decodable { let accessToken: String }
            let claudeAiOauth: OAuth
        }
        guard process.terminationStatus == 0,
              let credentials = try? JSONDecoder().decode(Credentials.self, from: data)
        else { throw UsageError.notLoggedIn }
        return credentials.claudeAiOauth.accessToken
    }

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let text = try decoder.singleValueContainer().decode(String.self)
            guard let date = parseISO8601(text) else {
                throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: text))
            }
            return date
        }
        return decoder
    }()

    private static func parseISO8601(_ text: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: text) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: text)
    }
}
