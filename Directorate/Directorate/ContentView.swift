//
//  ContentView.swift
//  Directorate
//
//  Created by Dan Wartnaby on 01/09/2021.
//

import SwiftUI


extension View {
    public func gradientForeground(colors: [Color]) -> some View {
        self.overlay(LinearGradient(gradient: .init(colors: colors),
                                    startPoint: .top,
                                    endPoint: .bottom))
            .mask(self)
    }
}


struct ContentView: View {
    @EnvironmentObject var state: Session
    
    @ObservedObject var viewModel: RuleViewModel

    @State private var scanQRCode = false
    @State private var searchTerm: String = ""
    
    var barButtons: some View {
        NavigationLink(destination: ProfileView().environmentObject(state)) {
            Image(systemName: "qrcode.viewfinder")
                .imageScale(.large)
        }
    }
        
    var body: some View {
        let binding = Binding<String>(get: {
                    self.searchTerm
                }, set: {
                    self.searchTerm = $0
                })
        
        let inset: CGFloat = 36
        
        GeometryReader { geo in
            ZStack {
                NavigationView {
                    ScrollView {
                        ZStack {
                            VStack {
                                
                                Spacer()
                            }
                            
                            VStack {
                                TextField("Search Rules", text: binding)
                                    .disableAutocorrection(true)
                                    .textFieldStyle(GradientTextFieldBackground(symbol: "magnifyingglass.circle.fill"))
                                    .submitLabel(.search)
                                    .onSubmit {
                                        viewModel.find(term: searchTerm, in: .tlaok)
                                    }
                                    .padding(.top, 10)
                                
                                if searchTerm.count < 3 {
                                    Text("Three characters, minimum")
                                        .font(.caption)
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.vertical, 10)
                                }
                                
                                    ForEach(viewModel.rules) { rule in
                                        if !rule.loading {
                                            VStack(spacing: 8) {
                                                Text(rule.name ?? "Unknown Name").font(.headline)
                                                    .gradientForeground(colors: [
                                                        Color("TextField_Start"),
                                                        Color("TextField_End")
                                                    ])
                                                    .frame(width: geo.size.width - inset, alignment: .leading)
                                                
                                                Divider()
                                                    .background(LinearGradient(
                                                        colors: [
                                                            Color("TextField_Start"),
                                                            Color("TextField_End")
                                                        ],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    ))
                                                    .padding(.vertical, 2)
                                                
                                                Text(try! AttributedString(markdown: rule.text ?? "Unknown Rule")).font(.body).lineSpacing(5)
                                                    .frame(width: geo.size.width - inset, alignment: .leading)
                                            }
                                            .padding(.vertical, 20)
                                        }
                                    }
                                
                                Spacer()
                            }
                            .listStyle(.plain)
                            .padding(0)
                            .padding(.horizontal, 18)
                        }
                    }
                    .navigationBarTitle(Text("Directorate"))
                    .navigationBarItems(trailing: barButtons)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        SpinnerProgressView(indeterminate: true, scale: 1.0)
                            .frame(width: 100, height: 100, alignment: .center)
                        Spacer()
                    }
                    Spacer()
                }
                .padding()
                .opacity(state.isLoading ? 1.0 : 0.0)
                .allowsHitTesting(state.isLoading)
                .edgesIgnoringSafeArea(.all)
            }
            
            
        }
    }
}
