//
//  RuleRepository.swift
//  Directorate
//
//  Created by Dan Wartnaby on 01/09/2021.
//

import Foundation

protocol RulesRepository {
    func request(for path: String) -> URLRequest
    
    func find(rule: String, in ruleset: RuleSet, completion: @escaping ([Rule]?)-> ())
    func hydrate(rule: Rule, completion: @escaping (Rule?) -> ())
}

extension RulesRepository {
    func request(for path: String) -> URLRequest {
        let endpoint = "https://armybuilder.para-bellum.com/directives\(path)"
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }
}

class FindRulesResponse: Decodable {
    var results: [RuleSummary]?
}

class HydrateRuleResponse: Decodable {
    var main: RuleData?
}

class RemoteRulesRepository: RulesRepository {
    func find(rule: String, in ruleset: RuleSet, completion: @escaping ([Rule]?) -> ()) {
        let task = URLSession.shared.dataTask(with: request(for: "?term=\(rule)&rulepack=\(ruleset.rawValue)")) { data, response, error -> Void in
            
            let summaries = (try? JSONDecoder().decode(FindRulesResponse.self, from: data!))?.results ?? []
            let rules: [Rule] = summaries.map { summary in
                Rule(id: summary.id)
            }
            
            rules.forEach { rule in
                self.hydrate(rule: rule) { rule in
//                    if let rule = rule {
                        completion(nil)
//                    }
                }
            }
            
            completion(rules)
        }
        task.resume()
    }
    
    func hydrate(rule: Rule, completion: @escaping (Rule?) -> ()) {
        print("Calling: \(request(for: "/\(rule.id)"))")
        let task = URLSession.shared.dataTask(with: request(for: "/\(rule.id)")) { [rule] data, response, error -> Void in
            if let error =  error {
                print("Error: \(error)")
            }
            
            if let hydratedRule = try? JSONDecoder().decode(HydrateRuleResponse.self, from: data!), let data = hydratedRule.main {
                rule.hydrate(data: data)
            }
            
            completion(rule)
        }
        task.resume()
    }
}

