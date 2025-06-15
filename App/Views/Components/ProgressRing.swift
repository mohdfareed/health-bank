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

    let icon: Image?

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
                        .background.secondary.opacity(0.2),
                        style: StrokeStyle(
                            lineWidth: lineWidth, lineCap: .round
                        )
                    )
                    .transition(.opacity)

                // Tip segment
                tipBackground(width: lineWidth, color: tipColor)

                // Progress segment
                Circle()
                    .trim(from: 0, to: circleProgress)
                    .stroke(
                        color,
                        style: StrokeStyle(
                            lineWidth: lineWidth, lineCap: .round
                        )
                    )
                    .animation(.spring, value: progress)
                    .rotationEffect(.degrees(-90))

            }
            .overlay(
                icon?.foregroundColor(color)
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    func tipBackground(width: CGFloat, color: Color?) -> some View {
        let range = 360 - min(360, circleTipStart * 360)
        let fadeAngles: Double = min(range / 2, 20)
        let fadeProgress: Double = fadeAngles / 360

        let startGradient = AngularGradient(
            gradient: Gradient(stops: [
                .init(color: tipColor?.opacity(0.0) ?? .clear, location: 0),
                .init(
                    color: tipColor?.opacity(0.2) ?? .clear,
                    location: 1
                ),
            ]),
            center: .center,
            startAngle: .degrees(min(circleTipStart * 360, 360)),
            endAngle: .degrees(min(circleTipStart * 360 + fadeAngles, 360))
        )

        let endGradient = AngularGradient(
            gradient: Gradient(stops: [
                .init(color: tipColor?.opacity(0.2) ?? .clear, location: 0),
                .init(
                    color: tipColor?.opacity(0.0) ?? .clear,
                    location: 1
                ),
            ]),
            center: .center,
            startAngle: .degrees(360 - fadeAngles),
            endAngle: .degrees(360)
        )

        // Tip segment Transition
        Circle()
            .trim(from: circleTipStart, to: circleTipStart + fadeProgress)
            .stroke(
                startGradient,
                style: StrokeStyle(lineWidth: width, lineCap: .butt)
            )
            .transition(.opacity)
            .rotationEffect(.degrees(-90))
        // Tip segment
        Circle()
            .trim(from: circleTipStart + fadeProgress, to: 1 - fadeProgress)
            .stroke(
                tipColor?.opacity(0.2) ?? .clear,
                style: StrokeStyle(lineWidth: width, lineCap: .butt)
            )
            .transition(.opacity)
            .rotationEffect(.degrees(-90))
        // Tip segment Transition
        Circle()
            .trim(from: 1 - fadeProgress, to: 1)
            .stroke(
                endGradient,
                style: StrokeStyle(lineWidth: width, lineCap: .butt)
            )
            .transition(.opacity)
            .rotationEffect(.degrees(-90))
    }
}

// MARK: - Previews

#Preview {
    ProgressRing(
        value: 1000,
        progress: 750,
        color: .calories,
        tip: 1200,
        tipColor: .green,
        icon: .calories
    )
    .padding()
    .padding()

    ProgressRing(
        value: 1000,
        progress: 500,
        color: .calories,
        tip: 750,
        tipColor: .red,
        icon: .calories
    )
    .padding()
    .padding()

    ProgressRing(
        value: 1000,
        progress: 0,
        color: .calories,
        tip: 50,
        tipColor: .red,
        icon: .calories
    )
    .padding()
    .padding()
}
