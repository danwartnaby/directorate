//
//  FavouritesView.swift
//  Directorate
//
//  Created by Dan Wartnaby on 22/04/2022.
//

import SwiftUI

struct FavouritesView: View {
    var onSelect: ((URL)->())?
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVStack {
                    ForEach(Favourites.allUnitNames(), id: \.self) { name in
                        VStack {
                            Button {
                                if let url = Favourites.urlFor(unit: name) {
                                    onSelect?(url)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "star.fill")
                                    Text(name).offset(x: -25, y: 1)
                                    .font(.headline)
                                    Spacer()
                                }
                            }
                            .padding(0)
                            
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
                        }
                    }
                }
                .padding(.horizontal, 18)
                .navigationBarTitle(Text("Starred"), displayMode: .large)
            }
            
        }
    }
}

struct FavouritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritesView()
    }
}
