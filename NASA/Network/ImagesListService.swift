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
    
    func fetchPhotosUsing(searchText: String?, completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard let searchText = searchText else { return }
        if currentTask != nil { return } else { currentTask?.cancel() }
        guard let request = urlRequestUsing(searchText: searchText) else {
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
                        var photo = Photo(title: "", date: "", url: "")
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
                    self.found = photos
                    NotificationCenter.default.post(
                        name: ImagesListService.SearchResultDidChangeNotification,
                        object: self,
                        userInfo: ["Search": photos]
                    )
                    completion(.success(photos))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        currentTask?.resume()
    }
    
    private func postNotification(about photos: [Photo]) {
        
    }
}

private extension ImagesListService {
    func urlRequestUsing(searchText: String?) -> URLRequest? {
        guard let searchText = searchText else { return nil}
        let path: String = "/search?"
        return builder.makeSearchHTTPRequest(
            path: path,
            httpMethod: "GET",
            baseURLString: NetworkConstants.standart.imagesURL,
            searchText: "\(searchText)"
        )
    }
    
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
