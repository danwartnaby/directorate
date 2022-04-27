//
//  WebViewContainer.swift
//  Directorate
//
//  Created by Dan Wartnaby on 21/04/2022.
//

import UIKit
import WebKit
import SwiftUI



enum ProfileViewState {
    case qrcode
    case favourites
    case unit(URL)
}


class Session: ObservableObject {
    @Published var profileState: ProfileViewState = .qrcode
    @Published var isLoading = false
    
    static let current: Session = Session()
}



struct ProfileView: View {
    
    var onClose: (()->())?
    
    @EnvironmentObject var state: Session
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                switch state.profileState {
                case .unit(let url):
                    UnitView(url: url)
                        .opacity(state.isLoading ? 0.0 : 1.0)
                case .favourites:
                    FavouritesView()
                case .qrcode:
                    QRView()
                }
            }
            .onDisappear {
                state.profileState = .qrcode
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
          color: #\(String(describing: Color(UIColor.label).toHex()!)) !important;
          background-color: #\(String(describing: Color(UIColor.systemBackground).toHex()!)) !important;
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
          background-color: #\(String(describing: Color(UIColor.systemBackground).toHex()!)) !important;
          color: #\(String(describing: Color(UIColor.label).toHex()!)) !important;
        }
        
        .rules-link {
          color: #\(String(describing: Color(UIColor.label).toHex()!)) !important;
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
