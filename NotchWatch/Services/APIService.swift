import Foundation

enum APIServiceError: LocalizedError {
    case httpStatus(Int)

    var errorDescription: String? {
        let lang = LanguageManager.shared.language
        switch self {
        case .httpStatus(401), .httpStatus(403):
            return Strings.tokenInvalidOrExpired(lang)
        case .httpStatus(429):
            return Strings.rateLimited(lang)
        case .httpStatus(let code):
            return Strings.serverErrorCode(code, lang)
        }
    }
}

class APIService {
    private let baseURL = URL(string: "https://api.anthropic.com")!
    private let session = URLSession.shared
    
    func fetchUsage(token: String) async throws -> ClaudeUsage {
        let url = baseURL.appendingPathComponent("api/oauth/usage")
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.addValue("claude-code/0.2.29", forHTTPHeaderField: "User-Agent")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard httpResponse.statusCode == 200 else {
            throw APIServiceError.httpStatus(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(ClaudeUsage.self, from: data)
    }
}