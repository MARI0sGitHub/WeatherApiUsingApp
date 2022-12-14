

import Foundation

extension Bundle {
    var apiKey : String {
        guard let file = self.path(forResource: "PrivateKey", ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else {
            return ""
        }
        guard let key = resource["ApiKey"] as? String else {
            fatalError("please set ApiKey")
        }
        return key
    }
}
