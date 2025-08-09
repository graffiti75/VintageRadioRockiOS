import Foundation

struct Song: Identifiable {
    let id = UUID()
    let decade: String
    let year: String
    let band: String
    let song: String
    let youtubeID: String
}
