//
//  UserDefaultsPropertyWrapper.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.07.2025.
//

import Foundation

protocol UserDefaultsCompatible {  }

extension Bool: UserDefaultsCompatible {  }
extension Int: UserDefaultsCompatible {  }
extension Float: UserDefaultsCompatible {  }
extension Double: UserDefaultsCompatible {  }
extension String: UserDefaultsCompatible {  }
extension URL: UserDefaultsCompatible {  }

@propertyWrapper
struct UserDefault<T: UserDefaultsCompatible> {
    
    private let key: String
    private let defaultValue: T
    
    init(
        key: String,
        defaultValue: T
    ) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            if let savedValue = UserDefaults
                .standard
                .value(forKey: key) as? T {
                return savedValue
            } else {
                UserDefaults.standard.set(defaultValue, forKey: key)
                return defaultValue
            }
        } nonmutating set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct UserDefaultEnum<T: RawRepresentable> where T.RawValue == String {
    
    private let key: String
    private let defaultValue: T
    
    init(
        key: String,
        defaultValue: T
    ) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            if let savedValue = UserDefaults
                .standard
                .string(forKey: key),
               let savedValue = T(rawValue: savedValue) {
                return savedValue
            } else {
                UserDefaults.standard.set(defaultValue.rawValue, forKey: key)
                return defaultValue
            }
        } nonmutating set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
}
