//
//  QRView.swift
//  Directorate
//
//  Created by Dan Wartnaby on 27/04/2022.
//

import SwiftUI
import CodeScanner

struct QRView: View {
    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            Session.current.profileState = .unit(URL(string: "https://armybuilder.para-bellum.com/tlaok/\(result.string)")!)
        case .failure(_):
            Session.current.profileState = .qrcode
        }
    }
    
    var body: some View {
        CodeScannerView(codeTypes: [.qr], simulatedData: "f39ff87e94", completion: handleScan).navigationBarTitle(Text("QR Code"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Session.current.profileState = .favourites
                    } label: {
                        Image(systemName: "list.star")
                            .imageScale(.large)
                    }
                }
            }
        .edgesIgnoringSafeArea(.all)
    }
}
