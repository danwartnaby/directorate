//
//  Rule.swift
//  Directorate
//
//  Created by Dan Wartnaby on 01/09/2021.
//

import Foundation

enum RuleSet: String {
    case tlaok = "tlaok"
    case firstBlood = "fb"
}

class RuleSummary: Decodable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "text"
    }
    
    var id: Int
    var name: String
}

class RuleData: Decodable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case text = "content"
    }
    
    var id: Int
    var name: String?
    var text: String?
}

class Rule: ObservableObject, Identifiable {
    @Published var loading = true
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case text = "content"
    }
    
    var id: Int
    @Published var name: String?
    @Published var text: String?
    
    init(id: Int) {
        self.id = id
    }
    
    private func markdown(_ text: String?) -> String? {
        guard let text = text else {
            return nil
        }
        
        return text.replacingOccurrences(of: "<strong>", with: "**")
                   .replacingOccurrences(of: "</strong>", with: "**")
                   .replacingOccurrences(of: "<em>", with: "*")
                   .replacingOccurrences(of: "</em>", with: "*")
                   .replacingOccurrences(of: "<br/>", with: "\n")
    }
    
    @discardableResult
    func hydrate(data: RuleData, text: String = "") -> Self {
        DispatchQueue.main.async {
            self.name = data.name
            self.text = self.markdown(data.text)
            self.loading = false
            
            self.objectWillChange.send()
        }
        return self
    }
}
