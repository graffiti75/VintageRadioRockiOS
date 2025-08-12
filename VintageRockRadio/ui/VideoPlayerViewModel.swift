import Foundation
import Combine

enum PlayerCommand {
    case load(videoID: String)
    case play
    case pause
    case seek(to: Double)
}

class VideoPlayerViewModel: ObservableObject {
    @Published private(set) var state = VideoPlayerState()
    let commandPublisher = PassthroughSubject<PlayerCommand, Never>()

    private let songParser = SongParser()

    init() {
        loadSongs(decade: state.currentDecade)
    }

    func onAction(_ action: VideoPlayerAction) {
        switch action {
        case .playPause:
            if state.songs.isEmpty { return }
            state.isPlaying.toggle()
            if state.isPlaying {
                commandPublisher.send(.play)
            } else {
                commandPublisher.send(.pause)
            }
        case .setPlaying(let playing):
            if state.songs.isEmpty { return }
            if state.isPlaying != playing {
                state.isPlaying = playing
            }
        case .nextSong:
            if state.songs.isEmpty { return }
            goToNextSong()
        case .previousSong:
            if state.songs.isEmpty { return }
            goToPreviousSong()
        case .seekTo(let positionSeconds):
            if state.songs.isEmpty { return }
            state.currentPlaybackTimeSeconds = positionSeconds
            commandPublisher.send(.seek(to: positionSeconds))
        case .updatePlaybackTime(let timeSeconds):
            if state.songs.isEmpty { return }
            state.currentPlaybackTimeSeconds = timeSeconds
        case .updateTotalDuration(let durationSeconds):
            if state.songs.isEmpty { return }
            state.totalDurationSeconds = durationSeconds
        case .onPlayerError(let errorCode):
            handlePlayerError(errorCode)
        case .onError(let error):
            state.error = error
            state.isLoading = false
            state.isPlaying = false
        case .dismissError:
            goToNextSong()
        case .changeDecade(let decade):
            handleChangeDecade(decade: decade)
        }
    }

    private func loadSongs(decade: String) {
        state.isLoading = true
        songParser.parseSongs(decade: decade) { [weak self] songs in
            guard let self = self else { return }

            let shuffledSongs = songs.shuffled()
            if !shuffledSongs.isEmpty {
                var newState = self.state
                newState.songs = shuffledSongs
                newState.isLoading = false
                newState.currentSongIndex = 0
                newState.currentPlaybackTimeSeconds = 0
                newState.totalDurationSeconds = 0
                newState.error = nil
                newState.isPlaying = true
                self.state = newState
                if let firstSong = shuffledSongs.first {
                    commandPublisher.send(.load(videoID: firstSong.youtubeID))
                }
            } else {
                var newState = self.state
                newState.isLoading = false
                newState.error = "No songs found for decade \(decade) in ids.txt."
                self.state = newState
            }
        }
    }

    private func goToNextSong() {
        let nextIndex = (state.currentSongIndex + 1) % state.songs.count
        state.currentSongIndex = nextIndex
        state.currentPlaybackTimeSeconds = 0
        state.totalDurationSeconds = 0
        state.isPlaying = true
        state.error = nil
        state.isPrevButtonEnabled = true
        if let newSong = state.currentSong {
            commandPublisher.send(.load(videoID: newSong.youtubeID))
        }
    }

    private func goToPreviousSong() {
        let prevIndex = (state.currentSongIndex - 1 + state.songs.count) % state.songs.count
        state.currentSongIndex = prevIndex
        state.currentPlaybackTimeSeconds = 0
        state.totalDurationSeconds = 0
        state.isPlaying = true
        state.isPrevButtonEnabled = true
        if let newSong = state.currentSong {
            commandPublisher.send(.load(videoID: newSong.youtubeID))
        }
    }

    private func handleChangeDecade(decade: String) {
        state.currentDecade = decade
        loadSongs(decade: decade)
        state.isPrevButtonEnabled = false
    }

    private func handlePlayerError(_ errorCode: Int) {
        let errorMessage: String
        switch errorCode {
        case 2:
            errorMessage = "Player Error: Invalid video ID."
        case 5:
            errorMessage = "Player Error: HTML5 Player issue."
        case 100:
            errorMessage = "Video not found or private."
        case 101, 150:
            errorMessage = "Playback restricted by owner."
        default:
            errorMessage = "An unknown player error occurred."
        }
        state.error = errorMessage

        // Skip to the next song after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.state.error == errorMessage { // Only skip if the error is still the same
                self.goToNextSong()
            }
        }
    }
}
