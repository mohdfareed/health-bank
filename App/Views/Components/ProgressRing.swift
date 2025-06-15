import Foundation
import SwiftUI

/// A progress ring that displays a circular progress indicator.
/// The circle can be segmented into a tip section and a progress section.
struct ProgressRing: View {
    let value: Double  // Total progress value
    let progress: Double  // Current progress value
    let color: Color

    let tip: Double?  // Progress value at which circle tip starts
    let tipColor: Color?

    // Properties

    var totalProgress: Double {
        guard let tip = tip else {
            return value
        }

        if tip < value {
            return value
        } else {
            return tip
        }
    }

    var circleProgress: Double {
        max(0, min(1, progress / totalProgress))
    }

    var circleTipStart: Double {
        if let tip = tip, tip < value {
            return max(0, min(1, tip / totalProgress))
        } else {
            return max(0, min(1, value / totalProgress))
        }
    }

    // Design

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let lineWidth = size * 0.2
            ZStack {
                // Background ring
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(
                        .background.tertiary,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .transition(.opacity)

                // Tip segment
                Circle()
                    .trim(from: circleTipStart, to: 1)
                    .stroke(
                        tipColor?.opacity(0.35) ?? .clear,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                    )
                    .transition(.opacity)
                    .rotationEffect(.degrees(-90))

                // Progress segment
                Circle()
                    .trim(from: 0, to: circleProgress)
                    .stroke(
                        color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .animation(.spring, value: progress)
                    .rotationEffect(.degrees(-90))
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Previews

#Preview {
    ProgressRing(
        value: 1000,
        progress: 750,
        color: .calories,
        tip: 1200,
        tipColor: .green
    )
    .padding()

    ProgressRing(
        value: 1000,
        progress: 750,
        color: .calories,
        tip: 800,
        tipColor: .red
    )
    .padding()

    ProgressRing(
        value: 1000,
        progress: 750,
        color: .calories,
        tip: nil, tipColor: nil
    )
    .padding()

    ProgressRing(
        value: 1000,
        progress: 750,
        color: .calories,
        tip: nil, tipColor: nil
    )
    .padding()

    ProgressRing(
        value: 1000,
        progress: 750,
        color: .calories,
        tip: nil, tipColor: nil
    )
    .padding()

    ProgressRing(
        value: 1000,
        progress: 750,
        color: .calories,
        tip: nil, tipColor: nil
    )
    .padding()

    ProgressRing(
        value: 1000,
        progress: 750,
        color: .calories,
        tip: nil, tipColor: nil
    )
    .padding()

    ProgressRing(
        value: 1000,
        progress: 750,
        color: .calories,
        tip: nil, tipColor: nil
    )
    .padding()
}
