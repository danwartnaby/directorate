//
//  RuleViewModel.swift
//  Directorate
//
//  Created by Dan Wartnaby on 21/04/2022.
//

import Foundation
import Combine

class RuleViewModel: ObservableObject {
    let repo: RemoteRulesRepository
    
    init(repo: RemoteRulesRepository) {
        self.repo = repo
    }
    
    @Published var rules = [Rule]()
    
    func add(rule: Rule) {
        rules.append(rule)
    }
    
    func find(term: String, in ruleset: RuleSet) {
        repo.find(rule: term.trimmingCharacters(in: .whitespacesAndNewlines), in: ruleset) { rules in
            DispatchQueue.main.async {
                if let rules = rules {
                    self.rules = rules
                }
                else {
                    self.objectWillChange.send()
                }
            }
        }
    }
}
