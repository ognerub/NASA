import Foundation

/// for search
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

