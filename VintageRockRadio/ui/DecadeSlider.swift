import SwiftUI

struct DecadeSlider: View {
    let decades = ["50", "60", "70", "80", "90", "2000"]
    @Binding var selectedDecade: String

    @State private var offset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack(alignment: .leading) {
                    // Track
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(height: 4)

                    // Pointer
                    Image(systemName: "triangle.fill")
                        .resizable()
                        .frame(width: 30, height: 20)
                        .foregroundColor(.red.opacity(0.7))
                        .offset(x: offset - 15) // Center the pointer
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newOffset = lastOffset + value.translation.width
                                    offset = min(max(0, newOffset), geometry.size.width)
                                }
                                .onEnded { value in
                                    let segmentWidth = geometry.size.width / CGFloat(decades.count)
                                    let index = Int(round(offset / segmentWidth))
                                        .clamped(to: 0...decades.count - 1)

                                    let newOffset = segmentWidth * CGFloat(index) + segmentWidth / 2
                                    offset = newOffset
                                    lastOffset = newOffset

                                    let newDecade = decades[index]
                                    if newDecade != selectedDecade {
                                        selectedDecade = newDecade
                                    }
                                }
                        )
                }

                // Decade labels
                HStack {
                    ForEach(decades, id: \.self) { decade in
                        Text(decade)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .onTapGesture {
                                selectedDecade = decade
                            }
                    }
                }
            }
            .onAppear {
                updateOffset(width: geometry.size.width)
            }
            .onChange(of: selectedDecade) {
                updateOffset(width: geometry.size.width)
            }
        }
    }

    private func updateOffset(width: CGFloat) {
        let segmentWidth = width / CGFloat(decades.count)
        if let index = decades.firstIndex(of: selectedDecade) {
            let newOffset = segmentWidth * CGFloat(index) + segmentWidth / 2
            offset = newOffset
            lastOffset = newOffset
        }
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
