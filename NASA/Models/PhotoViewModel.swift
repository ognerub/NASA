import Foundation

struct Photo: Codable {
//    let mediaType: String
//    let serviceVersion: String
    var title: String
    var url: String

    enum CodingKeys: String, CodingKey {
//        case mediaType = "media_type"
//        case serviceVersion = "service_version"
        case title
        case url
    }
}

struct NASAData: Codable {
    let collection: Collection
}

struct Collection: Codable {
    let items: [MediaItem]
}

struct MediaItem: Codable {
    let data: [MediaData]
    let links: [MediaLink]?
}

struct MediaData: Codable {
    let title: String
}

struct MediaLink: Codable {
    let href: String
}
