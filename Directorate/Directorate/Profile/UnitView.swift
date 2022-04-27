//
//  UnitView.swift
//  Directorate
//
//  Created by Dan Wartnaby on 27/04/2022.
//

import SwiftUI

struct UnitView: View {
    @State var url: URL
    @State var unitTitle = "Loading..."
    @State var isFavourited: Bool = false
    
    @EnvironmentObject var state: Session
    
    var body: some View {
        ZStack {
            NavigationView {
                WebViewContainer(url: url) { name in
                    withAnimation {
                        state.isLoading = false
                    }
                    unitTitle = name
                    isFavourited = Favourites.isFavourited(name: name)
                }
                .onAppear(perform: {
                    state.isLoading = true
                })
                .mask(
                    VStack(spacing: 0) {

                        // Left gradient
                        LinearGradient(gradient:
                           Gradient(
                               colors: [Color.black.opacity(0), Color.black]),
                               startPoint: .top, endPoint: .bottom
                           )
                           .frame(height: 30)

                        // Middle
                        Rectangle().fill(Color.black)

                        // Right gradient
                        LinearGradient(gradient:
                           Gradient(
                               colors: [Color.black, Color.black.opacity(0)]),
                                       startPoint: .top, endPoint: .bottom
                           )
                           .frame(height: 80)
                    }
                 )
//                .navigationBarHidden(true)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            Session.current.profileState = .qrcode
                        } label: {
                            Image(systemName: "qrcode.viewfinder")
                                .imageScale(.large)
                        }
                    
                        Spacer()
                        
                        Button {
                            !isFavourited ? Favourites.add(name: unitTitle, url: url) : Favourites.remove(name: unitTitle)
                            isFavourited.toggle()
                        } label: {
                            Image(systemName: isFavourited ? "star.fill" : "star")
                                .imageScale(.large)
                        }
                        
                        Spacer()
                        
                        Button {
                            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                            UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .imageScale(.large)
                        }
                        
        //                                NavigationLink(destination: FavouritesView(onSelect: { url in
        //                                    self.url = url
        //                                })) {
        //                                    Image(systemName: "list.star")
        //                                        .imageScale(.large)
        //                                }
                        
                    }
                }
                
            }
        }
        .navigationTitle(Text(unitTitle))
    }
}
