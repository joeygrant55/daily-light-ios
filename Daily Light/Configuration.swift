import Foundation

enum ConfigurationError: Error {
    case missingKey(String)
    case invalidValue
}

struct Configuration {
    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw ConfigurationError.missingKey(key)
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw ConfigurationError.invalidValue
        }
    }
    
    static func string(for key: String) throws -> String {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
             throw ConfigurationError.missingKey(key)
        }
        guard let value = object as? String else { 
            throw ConfigurationError.invalidValue
        }
        return value
    }
} 