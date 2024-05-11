import Foundation

protocol ImagesListServiceProtocol: AnyObject {
    var photos: [Photo] { get set }
    func fetchPhotosFrom(date: Date, completion: @escaping (Result<[Photo], Error>) -> Void)
}

final class ImagesListService: ImagesListServiceProtocol {
    
    private let urlSession: URLSession
    private let builder: URLRequestBuilderProtocol
    
    private var currentTask: URLSessionTask?
    var photos: [Photo] = []
    
    init (
        urlSession: URLSession = .shared,
        builder: URLRequestBuilderProtocol
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
