//
//  WebViewContainer.swift
//  Directorate
//
//  Created by Dan Wartnaby on 21/04/2022.
//

import UIKit
import WebKit
import SwiftUI
import CodeScanner

struct ProfileView: View {
    @State var url: URL?
    @State private var isLoading = true
    @State var unitTitle = "Loading..."
    
    @State var isFavourited: Bool = false
    
    var onClose: (()->())?
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            url = URL(string: "https://armybuilder.para-bellum.com/tlaok/\(result.string)")
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            if let url = url {
                ZStack {
                    NavigationView {
                        WebViewContainer(url: url) { name in
                            withAnimation {
                                isLoading = false
                            }
                            unitTitle = name
                            isFavourited = Favourites.isFavourited(name: name)
                        }
                        .navigationTitle(Text(unitTitle))
                        .toolbar {
                            ToolbarItem(placement: .bottomBar) {
                                Button {
                                    withAnimation {
                                        self.url = nil
                                        isLoading = true
                                    }
                                } label: {
                                    Image(systemName: "qrcode.viewfinder")
                                        .imageScale(.large)
                                }
                            }
                            
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    !isFavourited ? Favourites.add(name: unitTitle, url: url) : Favourites.remove(name: unitTitle)
                                    isFavourited.toggle()
                                } label: {
                                    Image(systemName: isFavourited ? "star.fill" : "star")
                                        .imageScale(.large)
                                }
                            }
                            
                            ToolbarItem(placement: .primaryAction) {
                                Button {
                                    onClose?()
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                        
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
                    .background(.background)
                    .opacity(isLoading ? 1.0 : 0.0)
                    .allowsHitTesting(isLoading)
                }
                .navigationBarTitle(Text(unitTitle), displayMode: .large)
                .navigationBarTitleDisplayMode(.large)
                .edgesIgnoringSafeArea(.all)
            }
            else {
                NavigationView {
                    CodeScannerView(codeTypes: [.qr], simulatedData: "f39ff87e94", completion: handleScan).navigationBarTitle(Text("QR Code"))
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                NavigationLink(destination: FavouritesView(onSelect: { url in
                                    self.url = url
                                })) {
                                    Image(systemName: "list.star")
                                        .imageScale(.large)
                                }
                            }
                            
                            ToolbarItem(placement: .primaryAction) {
                                Button {
                                    onClose?()
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                    .edgesIgnoringSafeArea(.all)
                }
                .navigationBarTitle(Text("QR Code"), displayMode: .large)
                
            }
        }
    }
}



struct WebViewContainer: UIViewRepresentable {

    let url: URL
    let onLoad: ((String) -> Void)?
    
    func makeUIView(context: Context) -> WKWebView {
        let css = """
        html, body, h1, .h1, h2, .h2, h3, .h3, h4, .h4, h5, .h5, h6, .h6, .rules-popup-content {
          overflow-x: hidden;
          font-family: -apple-system, "Helvetica Neue", "Lucida Grande" !important;
          color: white !important;
        }
        
        h1, span.cq-txt-bold {
          background: -webkit-linear-gradient(#F86100, #663300);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
        }
        
        .reveal {
          padding: 18px !important;
        }
        
        .card-panel, .simplebar-scroll-content {
          padding: 0px !important;
        }
        
        .simplebar-content {
          padding: 18px !important;
        }
        
        .rules-popup-title {
          font-weight: bold !important;
        }

        #header-section, .close-btn, .entry-name {
          display: none !important;
        }
        
        .card-panel .stats-table tr:first-child {
          border-bottom: 1px solid #CCCCCC !important;
        }
        
        .card-panel .stats-table tr {
          height: 40px !important;
        }
        
        .cq-papyrus, .fading-bgr, .reveal {
          background-image: none !important;
          background-color: black !important;
          color: gray !important;
        }
        
        .rules-link {
          color: white !important;
        }
        """
        
        let cssString = css.components(separatedBy: .newlines).joined()

        // Create JavaScript that loads the CSS
        let javaScript = """
           var element = document.createElement('style');
           element.innerHTML = '\(cssString)';
           document.head.appendChild(element);
        """
        
        let userScript = WKUserScript(source: javaScript,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        let request = URLRequest(url: url)
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        
        webView.load(request)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.showsVerticalScrollIndicator = false
                
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {

                webView.evaluateJavaScript("document.getElementsByClassName('entry-name')[0].innerText",
                                           completionHandler: { (html: Any?, error: Error?) in
                    if let unitname = html as? String {
                        onLoad?(unitname)
                    }
                    else {
                        onLoad?("Unit Profile")
                    }
                })

        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
}
