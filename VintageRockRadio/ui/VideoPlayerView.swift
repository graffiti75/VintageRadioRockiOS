import SwiftUI

struct VideoPlayerView: View {
    @StateObject private var viewModel = VideoPlayerViewModel()
    @State private var sliderValue: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // NOTE TO USER: Replace "background" with your actual background image asset name.
                // A dark, vintage-style background image would work best.
                Color.black.edgesIgnoringSafeArea(.all) // Placeholder background

                ScrollView {
                    VStack {
                        // Decade buttons
                        HStack(spacing: 20) {
                        DecadeButton(title: "50s", action: { viewModel.onAction(.changeDecade("50")) })
                        DecadeButton(title: "60s", action: { viewModel.onAction(.changeDecade("60")) })
                        DecadeButton(title: "70s", action: { viewModel.onAction(.changeDecade("70")) })
                        DecadeButton(title: "80s", action: { viewModel.onAction(.changeDecade("80")) })
                        DecadeButton(title: "90s", action: { viewModel.onAction(.changeDecade("90")) })
                        DecadeButton(title: "00s", action: { viewModel.onAction(.changeDecade("2000")) })
                    }
                    .padding()

                    if let song = viewModel.state.currentSong {
                        YouTubePlayer(videoID: song.youtubeID,
                                      isPlaying: viewModel.state.isPlaying,
                                      seekTo: viewModel.state.currentPlaybackTimeSeconds,
                                      viewModel: viewModel)
                            .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.4)
                            .cornerRadius(10)
                            .padding()

                        Text(song.song)
                            .font(.custom("HelveticaNeue-Bold", size: 36))
                            .foregroundColor(.white)
                        Text(song.band)
                            .font(.custom("HelveticaNeue-Medium", size: 24))
                            .foregroundColor(.gray)
                        Text("\(song.year) (\(song.decade)s)")
                            .font(.custom("HelveticaNeue-Light", size: 18))
                            .foregroundColor(.gray)

                        // Playback controls
                        HStack(spacing: 40) {
                            Button(action: { viewModel.onAction(.previousSong) }) {
                                Image(systemName: "backward.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                            }
                            .disabled(!viewModel.state.isPrevButtonEnabled)

                            Button(action: { viewModel.onAction(.playPause) }) {
                                Image(systemName: viewModel.state.isPlaying ? "pause.fill" : "play.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.orange)
                            }

                            Button(action: { viewModel.onAction(.nextSong) }) {
                                Image(systemName: "forward.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()

                        // Slider
                        Slider(value: $sliderValue, in: 0...viewModel.state.totalDurationSeconds, onEditingChanged: { editing in
                            if !editing {
                                viewModel.onAction(.seekTo(sliderValue))
                            }
                        })
                        .accentColor(.orange)
                        .padding()
                        .onReceive(viewModel.$state) { state in
                            sliderValue = state.currentPlaybackTimeSeconds
                        }


                    } else {
                        if viewModel.state.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(2)
                        } else if let error = viewModel.state.error {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                            Button("Try Again") {
                                viewModel.onAction(.changeDecade(viewModel.state.currentDecade))
                            }
                            .foregroundColor(.orange)
                        }
                    }
                } // VStack
                } // ScrollView
            }
        }
    }
}

struct DecadeButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("HelveticaNeue-Medium", size: 18))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
