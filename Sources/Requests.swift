import Foundation

enum NetworkError: Error {
    case connectionFailed
    case invalidURL
    case unknownError
    case noData
}

let requests: EasyRequests = EasyRequests()

public class EasyRequests {
    // get request with async/await, returns a Codable object
    public static func get<T: Codable>(url: String, headers: [String: String] = ["Accept": "application/json", "Content-Type": "application/json"], queryItems: [URLQueryItem] = []) async throws -> T {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems
        
        guard let finalURL = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if data == nil {
            throw NetworkError.noData
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(T.self, from: data)
    }

    // post request with async/await, returns a Codable object
    public static func post<T: Codable>(url: String, body: Data, headers: [String: String] = ["Accept": "application/json", "Content-Type": "application/json"]) async throws -> T {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if data == nil {
            throw NetworkError.noData
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(T.self, from: data)
    }

    // put request with async/await, returns a Codable object
    public static func put<T: Codable>(url: String, body: Data, headers: [String: String] = ["Accept": "application/json", "Content-Type": "application/json"]) async throws -> T {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = body
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if data == nil {
            throw NetworkError.noData
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(T.self, from: data)
    }

    // delete request with async/await, returns a Codable object
    public static func delete<T: Codable>(url: String, headers: [String: String] = ["Accept": "application/json", "Content-Type": "application/json"]) async throws -> T {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if data == nil {
            throw NetworkError.noData
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(T.self, from: data)
    }
}