import Foundation

let token = "RtQpoDXUCXp96wXAmyOWnHwTXTg9J651RzrLlGx8"
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


