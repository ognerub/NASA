import Foundation

final class ImagesListService {
    
    static let SearchResultDidChangeNotification = Notification.Name(rawValue: "SearchResultDidChange")
    
    static let PhotoResultDidChangeNotification = Notification.Name(rawValue: "PhotoResultDidChange")
    
    static let shared = ImagesListService()
    
    private let urlSession: URLSession
    private let builder: URLRequestBuilder
    
    private var currentTask: URLSessionTask?
    private (set) var photos: [Photo] = []
    private (set) var found: [Photo] = []
    
    init (
        urlSession: URLSession = .shared,
        builder: URLRequestBuilder = .shared
    ) {
        self.urlSession = urlSession
        self.builder = builder
    }
    
    func fetchPhotosFrom(date: Date, completion: @escaping (Result<[Photo], Error>) -> Void) {
        if currentTask != nil { return } else { currentTask?.cancel() }
        guard let request = urlRequestUsing(date: date) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<[Photo],Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.currentTask = nil
                switch result {
                case .success(let result):
                    let photos = result
                    self.photos.append(contentsOf: photos.reversed())
                    NotificationCenter.default.post(
                        name: ImagesListService.PhotoResultDidChangeNotification,
                        object: self,
                        userInfo: ["Photos": photos.reversed()]
                    )
                    completion(.success(photos.reversed()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        currentTask?.resume()
    }
}

private extension ImagesListService {    
    func urlRequestUsing(date: Date) -> URLRequest? {
        let path: String = "/planetary/apod?"
        return builder.makeHTTPRequest(
            path: path,
            httpMethod: "GET",
            baseURLString: NetworkConstants.standart.baseURL,
            date: date
        )
    }
}
