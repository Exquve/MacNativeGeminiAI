import Foundation

// MARK: - Request

struct GeminiRequest: Encodable {
    let contents: [Content]

    struct Content: Codable {
        let role: String
        let parts: [Part]
    }

    struct Part: Codable {
        let text: String
    }
}

// MARK: - Streaming Response

struct GeminiStreamResponse: Decodable {
    let candidates: [Candidate]?
    let usageMetadata: UsageMetadata?
    let error: APIError?

    struct Candidate: Decodable {
        let content: Content?
        let finishReason: String?
    }

    struct Content: Decodable {
        let parts: [Part]?
        let role: String?
    }

    struct Part: Decodable {
        let text: String?
    }

    struct UsageMetadata: Decodable {
        let promptTokenCount: Int?
        let candidatesTokenCount: Int?
        let totalTokenCount: Int?
    }

    struct APIError: Decodable {
        let code: Int?
        let message: String?
        let status: String?
    }
}
