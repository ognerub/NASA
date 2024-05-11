import Foundation
import SwiftKeychainWrapper

protocol OAuth2TokenStorageProtocol {
    var token: String? { get set }
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    
    private let keychainWrapper = KeychainWrapper.standard
    
    var token: String? {
        get { keychainWrapper.string(forKey: NetworkConstants.standart.personalToken) }
        set { guard let newValue = newValue else { return }
            keychainWrapper.set(newValue, forKey: NetworkConstants.standart.personalToken) }
    }
}
