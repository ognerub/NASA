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
            
            let currentDate: Date = date
            var endDate: Date = currentDate
            if let substractedEndDate = Calendar.current.date(byAdding: .day, value: -1, to: date) {
                endDate = substractedEndDate
            }
            let formattedEndDate = dateFormatter.string(from: endDate)
            
            var startDate: Date = Date()
            if let substractedStartDate = Calendar.current.date(byAdding: .day, value: -21, to: date) {
                startDate = substractedStartDate
            }
            let formattedStartDate = dateFormatter.string(from: startDate)
            components?.queryItems = [
                URLQueryItem(name: "api_key", value: "\(token)"),
                URLQueryItem(name: "start_date", value: "\(formattedStartDate)"),
                URLQueryItem(name: "end_date", value: "\(formattedEndDate)")
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
