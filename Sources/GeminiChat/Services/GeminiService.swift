import Foundation

final class GeminiService: Sendable {
    static let shared = GeminiService()

    private let session: URLSession
    private let decoder: JSONDecoder

    private static let baseURL = "https://generativelanguage.googleapis.com/v1beta/models"

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }

    func streamGenerate(
        model: GeminiModel,
        contents: [GeminiRequest.Content],
        apiKey: String
    ) -> AsyncThrowingStream<String, Error> {
        let session = self.session
        let decoder = self.decoder

        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let url = URL(string: "\(Self.baseURL)/\(model.rawValue):streamGenerateContent?alt=sse")!

                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                    let body = GeminiRequest(contents: contents)
                    request.httpBody = try JSONEncoder().encode(body)

                    let (bytes, response) = try await session.bytes(for: request)

                    if let httpResponse = response as? HTTPURLResponse,
                       httpResponse.statusCode != 200 {
                        throw GeminiError.httpError(httpResponse.statusCode)
                    }

                    for try await line in bytes.lines {
                        guard !Task.isCancelled else { break }
                        guard line.hasPrefix("data: ") else { continue }

                        let jsonString = String(line.dropFirst(6))
                        guard let data = jsonString.data(using: .utf8) else { continue }

                        let decoded = try decoder.decode(GeminiStreamResponse.self, from: data)

                        if let error = decoded.error {
                            throw GeminiError.apiError(
                                code: error.code ?? -1,
                                message: error.message ?? "Unknown error"
                            )
                        }

                        if let text = decoded.candidates?.first?.content?.parts?.first?.text {
                            continuation.yield(text)
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

enum GeminiError: LocalizedError {
    case httpError(Int)
    case apiError(code: Int, message: String)
    case noAPIKey

    var errorDescription: String? {
        switch self {
        case .httpError(let code):
            "HTTP error \(code)"
        case .apiError(_, let message):
            message
        case .noAPIKey:
            "No API key configured. Open Settings to add one."
        }
    }
}
