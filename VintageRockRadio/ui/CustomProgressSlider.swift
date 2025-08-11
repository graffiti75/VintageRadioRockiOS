import SwiftUI

struct CustomProgressSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var onEditingChanged: (Bool) -> Void = { _ in }
    let onSeek: (Double) -> Void

    @State private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let percentage = (range.upperBound > range.lowerBound) ? (value - range.lowerBound) / (range.upperBound - range.lowerBound) : 0
            let thumbX = totalWidth * CGFloat(percentage)

            ZStack(alignment: .leading) {
                // Background Track
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 8)

                // Progress Track
                Capsule()
                    .fill(Color.orange)
                    .frame(width: thumbX, height: 8)

                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .offset(x: thumbX - 10) // Center the thumb on the line
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if !isDragging {
                            isDragging = true
                            onEditingChanged(true)
                        }
                        updateValue(for: gesture.location, in: totalWidth)
                    }
                    .onEnded { gesture in
                        isDragging = false
                        onSeek(value)
                        onEditingChanged(false)
                    }
            )
        }
        .frame(height: 20)
    }

    private func updateValue(for location: CGPoint, in width: CGFloat) {
        let newPercentage = min(max(0, location.x / width), 1)
        let newValue = (range.upperBound - range.lowerBound) * Double(newPercentage) + range.lowerBound
        self.value = newValue
    }
}
