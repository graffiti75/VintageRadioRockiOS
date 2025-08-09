import Foundation

enum VideoPlayerAction {
    case playPause
    case setPlaying(Bool)
    case nextSong
    case previousSong
    case seekTo(Double)
    case updatePlaybackTime(Double)
    case updateTotalDuration(Double)
    case onError(String)
    case dismissError
    case changeDecade(String)
}
