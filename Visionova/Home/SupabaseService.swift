import Foundation
import UIKit

/// Supabase service singleton to handle authentication, storage, and scans data.
/// 
/// Note: Define your models separately as needed. This file focuses on service logic.
/// Ensure you add your Supabase URL and anon key in the `SupabaseConfig`.
///
/// Dependencies: None outside Foundation and URLSession, JSONDecoder/Encoder.
/// You can extend this with your models and networking layers as required.

public final class SupabaseService {
    
    // MARK: - Configuration
    
    private struct SupabaseConfig {
        static let url = URL(string: "https://ejotcehtmakiljulhtzw.supabase.co")! // Replace with your Supabase URL
        static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVqb3RjZWh0bWFraWxqdWxodHp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2MjI3MzcsImV4cCI6MjA3OTE5ODczN30.sji9ENOfAh249kmic6FhZnqevx42_DT4alkEaEzJAh8" // Replace with your anon/public API key
        static let bucketName = "Retinal Pictures" // Replace with your storage bucket name
        static let scansTable = "scans"
    }
    
    // MARK: - Types
    
    public struct Scan: Codable, Identifiable {
        public let id: UUID
        public let user_id: String
        public let image_url: String
        public let prediction: String
        public let confidence: Double
        public let explanation: String
        public let created_at: String // ISO8601 date string
    }
    
    public struct InsertScan: Codable {
        public let user_id: String
        public let image_url: String
        public let prediction: String
        public let confidence: Double
        public let explanation: String
    }
    
    public enum SupabaseError: Error, LocalizedError {
        case urlError
        case requestFailed(String)
        case decodingFailed
        case encodingFailed
        case noData
        case invalidResponse
        case notAuthenticated
        case uploadFailed(String)
        case unknown
        
        public var errorDescription: String? {
            switch self {
            case .urlError: return "Invalid URL."
            case .requestFailed(let message): return "Request failed: \(message)"
            case .decodingFailed: return "Failed to decode response."
            case .encodingFailed: return "Failed to encode request data."
            case .noData: return "No data received."
            case .invalidResponse: return "Invalid response from server."
            case .notAuthenticated: return "User not authenticated."
            case .uploadFailed(let message): return "Upload failed: \(message)"
            case .unknown: return "An unknown error occurred."
            }
        }
    }
    
    // MARK: - Singleton
    
    public static let shared = SupabaseService()
    
    private init() {
        // Private to enforce singleton
    }
    
    // MARK: - Properties
    
    private var accessToken: String? {
        // Check if you want to store and manage session tokens here
        UserDefaults.standard.string(forKey: "supabase_access_token")
    }
    private var refreshToken: String? {
        UserDefaults.standard.string(forKey: "supabase_refresh_token")
    }
    
    // MARK: - Auth
    
    /// Sign up a new user with email and password
    /// - Parameters:
    ///   - email: User email
    ///   - password: User password
    /// - Returns: User ID string on success
    public func signUp(email: String, password: String) async throws -> String {
        guard let url = URL(string: "/auth/v1/signup", relativeTo: SupabaseConfig.url) else {
            throw SupabaseError.urlError
        }
        
        let body = [
            "email": email,
            "password": password
        ]
        
        let data = try JSONSerialization.data(withJSONObject: body, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        request.addValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "apikey")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
            let message = String(data: responseData, encoding: .utf8) ?? "Unknown error"
            throw SupabaseError.requestFailed(message)
        }
        
        // Parse user id from response
        struct SignUpResponse: Codable {
            struct User: Codable {
                let id: String
                let email: String
            }
            let user: User?
            let access_token: String?
            let refresh_token: String?
        }
        
        let decoder = JSONDecoder()
        guard let signUpResponse = try? decoder.decode(SignUpResponse.self, from: responseData),
              let userId = signUpResponse.user?.id,
              let accessToken = signUpResponse.access_token,
              let refreshToken = signUpResponse.refresh_token
        else {
            throw SupabaseError.decodingFailed
        }
        
        // Store tokens for session
        UserDefaults.standard.setValue(accessToken, forKey: "supabase_access_token")
        UserDefaults.standard.setValue(refreshToken, forKey: "supabase_refresh_token")
        
        return userId
    }
    
    /// Sign in existing user with email and password
    /// - Parameters:
    ///   - email: User email
    ///   - password: User password
    /// - Returns: User ID string on success
    public func signIn(email: String, password: String) async throws -> String {
        guard let url = URL(string: "/auth/v1/token?grant_type=password", relativeTo: SupabaseConfig.url) else {
            throw SupabaseError.urlError
        }
        
        let body = [
            "email": email,
            "password": password
        ]
        
        let data = try JSONSerialization.data(withJSONObject: body, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        request.addValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "apikey")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            let message = String(data: responseData, encoding: .utf8) ?? "Unknown error"
            throw SupabaseError.requestFailed(message)
        }
        
        struct SignInResponse: Codable {
            struct User: Codable {
                let id: String
                let email: String
            }
            let access_token: String?
            let refresh_token: String?
            let user: User?
        }
        
        let decoder = JSONDecoder()
        guard let signInResponse = try? decoder.decode(SignInResponse.self, from: responseData),
              let userId = signInResponse.user?.id,
              let accessToken = signInResponse.access_token,
              let refreshToken = signInResponse.refresh_token
        else {
            throw SupabaseError.decodingFailed
        }
        
        UserDefaults.standard.setValue(accessToken, forKey: "supabase_access_token")
        UserDefaults.standard.setValue(refreshToken, forKey: "supabase_refresh_token")
        
        return userId
    }
    
    /// Get current authenticated user ID (requires valid token)
    public func getCurrentUserId() async throws -> String {
        guard let token = accessToken else {
            throw SupabaseError.notAuthenticated
        }
        
        guard let url = URL(string: "/auth/v1/user", relativeTo: SupabaseConfig.url) else {
            throw SupabaseError.urlError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SupabaseError.notAuthenticated
        }
        
        struct UserResponse: Codable {
            let id: String
            let email: String?
        }
        
        let decoder = JSONDecoder()
        guard let user = try? decoder.decode(UserResponse.self, from: data) else {
            throw SupabaseError.decodingFailed
        }
        
        return user.id
    }
    
    // MARK: - Storage Upload
    
    /// Upload image data to storage bucket at a given path
    /// - Parameters:
    ///   - path: path inside bucket, e.g. "user-uploads/image.png"
    ///   - data: binary image data
    ///   - contentType: MIME type of data, e.g. "image/png"
    /// - Returns: Public URL string of uploaded image
    public func uploadImage(path: String, data: Data, contentType: String) async throws -> String {
        guard let token = accessToken else {
            throw SupabaseError.notAuthenticated
        }
        
        guard let url = URL(string: "/storage/v1/object/\(SupabaseConfig.bucketName)/\(path)", relativeTo: SupabaseConfig.url) else {
            throw SupabaseError.urlError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = data
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SupabaseError.uploadFailed("Failed to upload image to storage.")
        }
        
        // Construct public URL (assuming bucket is public).
        // WARNING: If your bucket is private, this URL won't be accessible without signed URLs.
        let publicUrl = SupabaseConfig.url.appendingPathComponent("storage/v1/object/public/\(SupabaseConfig.bucketName)/\(path)").absoluteString
        
        return publicUrl
    }
    
    /// Convenience: Upload UIImage for a specific user under users/<uid>/<uuid>.jpg
    public func uploadImage(userId: String, image: UIImage, quality: CGFloat = 0.9) async throws -> String {
        guard let data = image.jpegData(compressionQuality: quality) else {
            throw SupabaseError.uploadFailed("Failed to encode image")
        }
        let fileName = "\(UUID().uuidString).jpg"
        let path = "users/\(userId)/\(fileName)"
        return try await uploadImage(path: path, data: data, contentType: "image/jpeg")
    }
    
    // MARK: - Signed URL (Optional)
    
    /// Generate a signed URL for private storage object, valid for some seconds
    /// - Parameters:
    ///   - path: Path to the object inside bucket
    ///   - expiresIn: Seconds before expiry (max usually 3600)
    /// - Returns: Signed URL string
    public func createSignedURL(path: String, expiresIn: Int = 3600) async throws -> String {
        guard let token = accessToken else {
            throw SupabaseError.notAuthenticated
        }
        
        guard let url = URL(string: "/storage/v1/object/sign/\(SupabaseConfig.bucketName)/\(path)", relativeTo: SupabaseConfig.url) else {
            throw SupabaseError.urlError
        }
        
        let query = URLQueryItem(name: "expiresIn", value: String(expiresIn))
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [query]
        
        guard let finalUrl = components?.url else {
            throw SupabaseError.urlError
        }
        
        var request = URLRequest(url: finalUrl)
        request.httpMethod = "POST"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SupabaseError.requestFailed("Failed to create signed URL.")
        }
        
        struct SignedURLResponse: Codable {
            let signedURL: String?
            
            enum CodingKeys: String, CodingKey {
                case signedURL = "signedURL"
            }
        }
        
        let decoder = JSONDecoder()
        guard let signedResponse = try? decoder.decode(SignedURLResponse.self, from: data),
              let signedURL = signedResponse.signedURL else {
            // Sometimes the key is "signedURL", sometimes "signedUrl" depending on API version
            throw SupabaseError.decodingFailed
        }
        
        return signedURL
    }
    
    // MARK: - Scans CRUD
    
    /// Insert a new scan record into the scans table
    /// - Parameter scan: InsertScan object with data to insert
    /// - Returns: Created Scan object with full data including id and created_at
    public func insertScan(scan: InsertScan) async throws -> Scan {
        guard let token = accessToken else {
            throw SupabaseError.notAuthenticated
        }
        
        guard let url = URL(string: "/rest/v1/\(SupabaseConfig.scansTable)", relativeTo: SupabaseConfig.url) else {
            throw SupabaseError.urlError
        }
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let bodyData = try? encoder.encode(scan) else {
            throw SupabaseError.encodingFailed
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.addValue("return=representation", forHTTPHeaderField: "Prefer")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SupabaseError.requestFailed(message)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let insertedScans = try? decoder.decode([Scan].self, from: data),
              let scan = insertedScans.first else {
            throw SupabaseError.decodingFailed
        }
        
        return scan
    }
    
    /// Fetch scans for the current authenticated user
    /// - Returns: Array of Scan objects
    public func fetchScans() async throws -> [Scan] {
        guard let token = accessToken else {
            throw SupabaseError.notAuthenticated
        }
        
        let userId = try await getCurrentUserId()
        
        guard var components = URLComponents(url: SupabaseConfig.url.appendingPathComponent("/rest/v1/\(SupabaseConfig.scansTable)"), resolvingAgainstBaseURL: true) else {
            throw SupabaseError.urlError
        }
        
        // Filter scans by user_id eq userId, order by created_at desc
        components.queryItems = [
            URLQueryItem(name: "user_id", value: "eq.\(userId)"),
            URLQueryItem(name: "order", value: "created_at.desc")
        ]
        
        guard let url = components.url else {
            throw SupabaseError.urlError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SupabaseError.requestFailed(message)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let scans = try? decoder.decode([Scan].self, from: data) else {
            throw SupabaseError.decodingFailed
        }
        
        return scans
    }
    
    /// Delete a scan by its id
    /// - Parameter id: Scan record id (UUID)
    /// - Returns: Bool indicating success
    public func deleteScan(id: UUID) async throws -> Bool {
        guard let token = accessToken else {
            throw SupabaseError.notAuthenticated
        }
        
        guard var components = URLComponents(url: SupabaseConfig.url.appendingPathComponent("/rest/v1/\(SupabaseConfig.scansTable)"), resolvingAgainstBaseURL: true) else {
            throw SupabaseError.urlError
        }
        
        components.queryItems = [
            URLQueryItem(name: "id", value: "eq.\(id.uuidString)")
        ]
        
        guard let url = components.url else {
            throw SupabaseError.urlError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }
        
        return (200...299).contains(httpResponse.statusCode)
    }
    
    // MARK: - Sign Out
    
    /// Clear stored tokens and sign out user locally
    public func signOut() {
        UserDefaults.standard.removeObject(forKey: "supabase_access_token")
        UserDefaults.standard.removeObject(forKey: "supabase_refresh_token")
    }
}

