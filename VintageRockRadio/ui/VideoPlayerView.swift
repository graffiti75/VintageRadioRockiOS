import SwiftUI

struct VideoPlayerView: View {
    @StateObject private var viewModel = VideoPlayerViewModel()
    @State private var sliderValue: Double = 0
    @State private var isInteractingWithSlider = false

    private var decadeBinding: Binding<String> {
        Binding(
            get: { viewModel.state.currentDecade },
            set: { newDecade in viewModel.onAction(.changeDecade(newDecade)) }
        )
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    // Top Section
                    HStack(spacing: 0) {
                        // Left Side: Player
                        ZStack {
                            if let song = viewModel.state.currentSong {
                                YouTubePlayer(videoID: song.youtubeID,
                                              isPlaying: viewModel.state.isPlaying,
                                              seekTo: viewModel.state.currentPlaybackTimeSeconds,
                                              viewModel: viewModel)

                                // Transparent overlay to block user interaction
                                Color.clear
                                    .contentShape(Rectangle())

                                if let error = viewModel.state.error {
                                    Text(error)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.7))
                                        .cornerRadius(10)
                                }
                            } else if viewModel.state.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(2)
                            }
                        }
                        .frame(width: geometry.size.width * 0.6)
                        .padding()

                        // Right Side: Song Info and Controls
                        VStack {
                            if let song = viewModel.state.currentSong {
                                SongDetailsView(song: song)
                            }

                            Spacer()

                            HStack(spacing: 40) {
                                Button(action: { viewModel.onAction(.previousSong) }) {
                                    Image(systemName: "backward.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.white)
                                }
                                .disabled(!viewModel.state.isPrevButtonEnabled)

                                Button(action: { viewModel.onAction(.playPause) }) {
                                    Image(systemName: viewModel.state.isPlaying ? "pause.fill" : "play.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.orange)
                                }

                                Button(action: { viewModel.onAction(.nextSong) }) {
                                    Image(systemName: "forward.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    .frame(height: geometry.size.height * 0.7)

                    // Bottom Section
                    VStack {
                        DecadeSlider(selectedDecade: decadeBinding)
                            .frame(height: 50)
                            .padding(.horizontal)

                        CustomProgressSlider(
                            value: $sliderValue,
                            range: 0...(viewModel.state.totalDurationSeconds > 0 ? viewModel.state.totalDurationSeconds : 1),
                            onEditingChanged: { isEditing in
                                isInteractingWithSlider = isEditing
                            },
                            onSeek: { newValue in
                                viewModel.onAction(.seekTo(newValue))
                            }
                        )
                        .onReceive(viewModel.$state) { state in
                            if !isInteractingWithSlider {
                                sliderValue = state.currentPlaybackTimeSeconds
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
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
