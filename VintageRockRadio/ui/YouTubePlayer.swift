import SwiftUI
import WebKit

struct YouTubePlayer: UIViewRepresentable {
    let videoID: String
    let isPlaying: Bool
    let seekTo: Double
    let viewModel: VideoPlayerViewModel

    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "playbackHandler")
        webConfiguration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = context.coordinator

        do {
            if let url = Bundle.main.url(forResource: "youtube_player", withExtension: "html") {
                let htmlString = try String(contentsOf: url)
                webView.loadHTMLString(htmlString, baseURL: URL(string: "https://www.youtube.com"))
            }
        } catch {
            print("Error loading youtube_player.html: \(error)")
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if context.coordinator.lastVideoID != videoID {
            uiView.evaluateJavaScript("loadVideo('\(videoID)');", completionHandler: nil)
            context.coordinator.lastVideoID = videoID
        }

        if isPlaying {
            uiView.evaluateJavaScript("playVideo();", completionHandler: nil)
        } else {
            uiView.evaluateJavaScript("pauseVideo();", completionHandler: nil)
        }

        if abs(seekTo - context.coordinator.lastSeekTo) > 1 {
            uiView.evaluateJavaScript("seekTo(\(seekTo));", completionHandler: nil)
            context.coordinator.lastSeekTo = seekTo
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: YouTubePlayer
        var viewModel: VideoPlayerViewModel
        var lastVideoID: String?
        var lastSeekTo: Double = 0

        init(_ parent: YouTubePlayer, viewModel: VideoPlayerViewModel) {
            self.parent = parent
            self.viewModel = viewModel
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "playbackHandler" {
                if let dict = message.body as? [String: Any],
                   let type = dict["type"] as? String {
                    if type == "timeUpdate",
                       let currentTime = dict["currentTime"] as? Double,
                       let duration = dict["duration"] as? Double {
                        DispatchQueue.main.async {
                            self.viewModel.onAction(.updatePlaybackTime(currentTime))
                            self.viewModel.onAction(.updateTotalDuration(duration))
                        }
                    } else if type == "error", let errorCode = dict["errorCode"] as? Int {
                        DispatchQueue.main.async {
                            self.viewModel.onAction(.onPlayerError(errorCode))
                        }
                    }
                }
            }
        }
    }
}
