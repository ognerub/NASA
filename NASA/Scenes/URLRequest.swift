import Foundation

final class URLRequestBuilder {
    static let shared = URLRequestBuilder()
    
    private let storage: OAuth2TokenStorage
    
    init(storage: OAuth2TokenStorage = .shared) {
        self.storage = storage
    }
    
    private func makeBaseRequestAndURL(
        path: String,
        httpMethod: String,
        baseURLString: String
    ) -> (URLRequest, URL) {
        let emptyURL = URL(fileURLWithPath: "")
        guard
            baseURLString.isValidURL,
            let url = URL(string: baseURLString),
            let baseURL = URL(string: path, relativeTo: url)
        else {
            assertionFailure("Impossible to create URLRequest of URL")
            return (URLRequest(url: emptyURL), emptyURL)
        }
        
        var request = URLRequest(url: baseURL)
        request.httpMethod = httpMethod
        request.timeoutInterval = 15
        return (request, baseURL)
    }
    
    func makeSearchHTTPRequest (
        path: String,
        httpMethod: String,
        baseURLString: String, searchText: String?) -> URLRequest? {
            let simpleRequest = makeBaseRequestAndURL(
                path: path,
                httpMethod: httpMethod,
                baseURLString: baseURLString)
            var request: URLRequest = simpleRequest.0
            let baseURL: URL = simpleRequest.1
            
            guard let searchText = searchText else { return nil }
            let search = "\(searchText)"
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
            components?.queryItems = [
                URLQueryItem(name: "q", value: "\(search)")
            ]
            guard let comurl = components?.url else {
                print("error to create url")
                return nil
            }
            request.url = comurl
            return request
        }
    
    func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURLString: String,
        date: Date
    ) -> URLRequest?  {
        let simpleRequest = makeBaseRequestAndURL(
            path: path,
            httpMethod: httpMethod,
            baseURLString: baseURLString)
        var request: URLRequest = simpleRequest.0
        let baseURL: URL = simpleRequest.1
        if let token = storage.token {
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let formattedDate = dateFormatter.string(from: date)
            var previousDate: Date = Date()
            if let substractedDate = Calendar.current.date(byAdding: .day, value: -20, to: date) {
                previousDate = substractedDate
            }
            let previousFormattedDate = dateFormatter.string(from: previousDate)
            components?.queryItems = [
                URLQueryItem(name: "api_key", value: "\(token)"),
                URLQueryItem(name: "start_date", value: "\(previousFormattedDate)"),
                URLQueryItem(name: "end_date", value: "\(formattedDate)")
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
