//
//  DirectorateApp.swift
//  Directorate
//
//  Created by Dan Wartnaby on 01/09/2021.
//

import SwiftUI

@main
struct DirectorateApp: App {
    let repo = RemoteRulesRepository()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: RuleViewModel(repo: repo)).environmentObject(Session.current)
        }
    }
}
