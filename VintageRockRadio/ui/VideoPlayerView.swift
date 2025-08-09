import SwiftUI

struct VideoPlayerView: View {
    @StateObject private var viewModel = VideoPlayerViewModel()
    @State private var sliderValue: Double = 0

    private var decadeBinding: Binding<String> {
        Binding(
            get: { viewModel.state.currentDecade },
            set: { newDecade in viewModel.onAction(.changeDecade(newDecade)) }
        )
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // NOTE TO USER: Replace "background" with your actual background image asset name.
                // A dark, vintage-style background image would work best.
                Color.black.edgesIgnoringSafeArea(.all) // Placeholder background

                ScrollView {
                    VStack {
                    if let song = viewModel.state.currentSong {
                        DecadeSlider(selectedDecade: decadeBinding)
                        .frame(height: 50)
                        .padding()

                        ZStack {
                            YouTubePlayer(videoID: song.youtubeID,
                                          isPlaying: viewModel.state.isPlaying,
                                          seekTo: viewModel.state.currentPlaybackTimeSeconds,
                                          viewModel: viewModel)
                                .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.4)
                                .cornerRadius(10)
                                .padding()

                            if let error = viewModel.state.error {
                                Text(error)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(10)
                            }
                        }

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
                        }
                    }
                } // VStack
                } // ScrollView
            }
        }
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
