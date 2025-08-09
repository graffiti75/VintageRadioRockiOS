import Foundation

struct VideoPlayerState {
    var songs: [Song] = []
    var currentSongIndex: Int = 0
    var isPlaying: Bool = false
    var currentPlaybackTimeSeconds: Double = 0
    var totalDurationSeconds: Double = 0
    var isLoading: Bool = true
    var error: String? = nil
    var currentDecade: String = "70"
    var isTabletAndLandscape: Bool = false
    var isPrevButtonEnabled: Bool = false

    var currentSong: Song? {
        guard !songs.isEmpty, songs.indices.contains(currentSongIndex) else {
            return nil
        }
        return songs[currentSongIndex]
    }
}
