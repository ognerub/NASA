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
    
    func fetchPhotos(searchText: String?, completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard let searchText = searchText else { return }
        if currentTask != nil { return } else { currentTask?.cancel() }
        guard let request = urlRequestToken(searchText: searchText) else {
            print("Invalide request in fetchPhoto")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<NASAData,Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.currentTask = nil
                switch result {
                case .success(let result):
                    var photos: [Photo] = []
                    let madiaItems = result.collection.items
                    for mediaItem in madiaItems {
                        var photo = Photo(title: "", url: "")
                        let mediaItem = MediaItem(
                            data: mediaItem.data,
                            links: mediaItem.links
                        )
                        for mediaData in mediaItem.data {
                            let title = mediaData.title
                            photo.title = title
                        }
                        if let links = mediaItem.links {
                            for mediaLink in links {
                                let link = mediaLink.href
                                if link.hasSuffix("jpg") {
                                    photo.url = link
                                }
                            }
                        }
                        if photo.url != "" {
                            photos.append(photo)
                        }
                    }
                    self.photos = photos
                    NotificationCenter.default.post(
                        name: ImagesListService.DidChangeNotification,
                        object: self,
                        userInfo: ["Photos": photos]
                    )
                    completion(.success(photos))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        currentTask?.resume()
    }
}

private extension ImagesListService {
    func urlRequestToken(searchText: String?) -> URLRequest? {
        guard let searchText = searchText else { return nil}
        let path: String = "/search?"
        return builder.makeHTTPRequest(
            path: path,
            httpMethod: "GET",
            baseURLString: NetworkConstants.standart.baseURL,
            searchText: "\(searchText)"
        )
    }
}
