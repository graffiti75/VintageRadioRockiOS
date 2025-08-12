import SwiftUI
import WebKit
import Combine

enum YTPlayerState: Int {
    case unstarted = -1
    case ended = 0
    case playing = 1
    case paused = 2
    case buffering = 3
    case cued = 5
}

struct YouTubePlayer: UIViewRepresentable {
    let videoID: String
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
        // The view is now command-driven, so updateUIView should be minimal.
        // We might still need to load the initial video if it's not handled by a command.
        if context.coordinator.lastVideoID != videoID {
            uiView.evaluateJavaScript("loadVideo('\(videoID)');", completionHandler: nil)
            context.coordinator.lastVideoID = videoID
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: YouTubePlayer
        var viewModel: VideoPlayerViewModel
        var lastVideoID: String?
        var lastPlayerState: YTPlayerState? = nil
        private var webView: WKWebView?
        private var cancellables = Set<AnyCancellable>()

        init(_ parent: YouTubePlayer, viewModel: VideoPlayerViewModel) {
            self.parent = parent
            self.viewModel = viewModel
            super.init()

            viewModel.commandPublisher
                .sink { [weak self] command in
                    self?.handle(command)
                }
                .store(in: &cancellables)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.webView = webView
            // When the webview is ready, load the initial video.
            handle(.load(videoID: parent.videoID))
        }

        private func handle(_ command: PlayerCommand) {
            guard let webView = webView else { return }
            switch command {
            case .load(let videoID):
                webView.evaluateJavaScript("loadVideo('\(videoID)');", completionHandler: nil)
                lastVideoID = videoID
            case .play:
                webView.evaluateJavaScript("playVideo();", completionHandler: nil)
            case .pause:
                webView.evaluateJavaScript("pauseVideo();", completionHandler: nil)
            case .seek(let to):
                webView.evaluateJavaScript("seekTo(\(to));", completionHandler: nil)
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "playbackHandler",
                  let dict = message.body as? [String: Any],
                  let type = dict["type"] as? String else { return }

            DispatchQueue.main.async {
                switch type {
                case "timeUpdate":
                    if let currentTime = dict["currentTime"] as? Double,
                       let duration = dict["duration"] as? Double {
                        self.viewModel.onAction(.updatePlaybackTime(currentTime))
                        self.viewModel.onAction(.updateTotalDuration(duration))
                    }
                case "error":
                    if let errorCode = dict["errorCode"] as? Int {
                        self.viewModel.onAction(.onPlayerError(errorCode))
                    }
                case "stateChange":
                    if let stateCode = dict["stateCode"] as? Int,
                       let state = YTPlayerState(rawValue: stateCode) {
                        self.lastPlayerState = state
                        // Also update the ViewModel's state based on the player's actual state
                        switch state {
                        case .playing:
                            self.viewModel.onAction(.setPlaying(true))
                        case .paused, .ended:
                            self.viewModel.onAction(.setPlaying(false))
                        default:
                            break // Do nothing for buffering, cued, etc.
                        }
                    }
                default:
                    break
                }
            }
        }
    }
}
