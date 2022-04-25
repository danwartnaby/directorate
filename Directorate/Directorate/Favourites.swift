//
//  Favourites.swift
//  Directorate
//
//  Created by Dan Wartnaby on 22/04/2022.
//

import Foundation

extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }

    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}

class Favourites {
    static var favourites: [String: URL] = [:]
    
    static func add(name: String, url: URL) {
        favourites[name] = url
        UserDefaults.standard.set(object: favourites, forKey: "favourites")
    }
    
    static func remove(name: String) {
        favourites.removeValue(forKey: name)
    }
    
    static func isFavourited(name: String) -> Bool {
        (favourites[name] != nil)
    }
    
    static func allUnitNames() -> [String] {
        if favourites.isEmpty {
            favourites = UserDefaults.standard.object([String: URL].self, with: "favourites") ?? [:]
        }
        
        return favourites.keys.map { key in
            key
        }
    }
    
    static func urlFor(unit name: String) -> URL? {
        favourites[name]
    }
}
