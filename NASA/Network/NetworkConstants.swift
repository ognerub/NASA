import Foundation

let token = "B11a2DqpI8ncaTVRnhOgrvEs0ALEVw11ou1EbSk1"
let images = "https://images-api.nasa.gov"
let base = "https://api.nasa.gov"

struct NetworkConstants {
    
    let baseURL: String
    let imagesURL: String
    let personalToken: String

    init(
        baseURL: String,
        imagesURL: String,
        personalToken: String
    ) {
        self.baseURL = baseURL
        self.imagesURL = imagesURL
        self.personalToken = personalToken
    }
    
    static var standart: NetworkConstants {
        return NetworkConstants(
            baseURL: base,
            imagesURL: images,
            personalToken: token
        )
    }
    
}


