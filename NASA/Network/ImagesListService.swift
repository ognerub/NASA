import Foundation

final class ImagesListService {
    
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceProviderDidChange")
    
    static let shared = ImagesListService()
    
    private let urlSession: URLSession
    private let builder: URLRequestBuilder
    
    private var currentTask: URLSessionTask?
    private (set) var photos: [Photo] = []
    
    init (
        urlSession: URLSession = .shared,
        builder: URLRequestBuilder = .shared
    ) {
        self.urlSession = urlSession
        self.builder = builder
    }    
    
    func fetchPhotos(completion: @escaping (Result<Photo, Error>) -> Void) {
        if currentTask != nil { return } else { currentTask?.cancel() }
        guard let request = urlRequestToken() else {
            print("Invalide request in fetchPhoto")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<Photo,Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.currentTask = nil
                switch result {
                case .success(let result):
                    var photos: [Photo] = []
                    let photo = Photo(
                        title: result.title,
                        url: result.url)
                    photos.append(photo)
                    self.photos.append(contentsOf: photos)
                    NotificationCenter.default.post(
                        name: ImagesListService.DidChangeNotification,
                        object: self,
                        userInfo: ["Photos": photos]
                    )
                    completion(.success(photo))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        currentTask?.resume()
    }
}

private extension ImagesListService {
    func urlRequestToken() -> URLRequest? {
        let path: String = "/planetary/apod?"
        return builder.makeHTTPRequest(
            path: path,
            httpMethod: "GET",
            baseURLString: NetworkConfiguration.standart.baseURL)
    }
}
