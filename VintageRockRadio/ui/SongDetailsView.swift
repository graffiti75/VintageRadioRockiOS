import SwiftUI

struct SongDetailsView: View {
    let song: Song

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(song.song)
                .font(.custom("HelveticaNeue-Bold", size: 36))
                .foregroundColor(.white)
            Text(song.band)
                .font(.custom("HelveticaNeue-Medium", size: 24))
                .foregroundColor(.gray)
            Text("\(song.year) (\(song.decade)s)")
                .font(.custom("HelveticaNeue-Light", size: 18))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}
