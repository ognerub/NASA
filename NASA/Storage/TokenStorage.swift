import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private let keychainWrapper = KeychainWrapper.standard
    
    var token: String? {
        get { keychainWrapper.string(forKey: NetworkConstants.standart.personalToken) }
        set { guard let newValue = newValue else { return }
            keychainWrapper.set(newValue, forKey: NetworkConstants.standart.personalToken) }
    }
}
