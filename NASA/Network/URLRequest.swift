import Foundation

final class URLRequestBuilder {
    static let shared = URLRequestBuilder()
    
    private let storage: OAuth2TokenStorage
    
    init(storage: OAuth2TokenStorage = .shared) {
        self.storage = storage
    }
    
    func makeHTTPRequest (
        path: String,
        httpMethod: String,
        baseURLString: String) -> URLRequest? {
            guard
                baseURLString.isValidURL,
                let url = URL(string: baseURLString),
                let baseURL = URL(string: path, relativeTo: url)
            else { return nil }
            
            var request = URLRequest(url: baseURL)
            request.httpMethod = httpMethod
            request.timeoutInterval = 15
            
            if let token = storage.token {
                
                var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
                components?.queryItems = [
                    URLQueryItem(name: "api_key", value: "\(token)")
                ]
                
                guard let comurl = components?.url else {
                    print("error to create url")
                    return nil
                }
                
                request.url = comurl
            }
            return request
        }
}
