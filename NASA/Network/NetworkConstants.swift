import Foundation

let token = "B11a2DqpI8ncaTVRnhOgrvEs0ALEVw11ou1EbSk1"
let imagesURL = "https://images-api.nasa.gov"

struct NetworkConstants {
    
    let baseURL: String
    let personalToken: String

    init(
        baseURL: String,
        personalToken: String
    ) {
        self.baseURL = baseURL
        self.personalToken = personalToken
    }
    
    static var standart: NetworkConstants {
        return NetworkConstants(
            baseURL: imagesURL,
            personalToken: token
        )
    }
    
}


