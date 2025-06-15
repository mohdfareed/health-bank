import Foundation
import SwiftUI

/// A simple view that displays a measurement value with an icon and optional tint
struct ProgressRing: View {
    let value: Double  // Total progress value
    let progress: Double  // Current progress value
    let color: Color

    let tip: Double  // Progress value at which circle tip starts
    let tipColor: Color

    let width: CGFloat

    // Properties

    var totalProgress: Double {
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
        if tip < value {
            return max(0, min(1, tip / totalProgress))
        } else {
            return max(0, min(1, value / totalProgress))
        }
    }

    // Design

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 1)
                .stroke(
                    .background.tertiary,
                    style: StrokeStyle(lineWidth: width, lineCap: .round)
                )
                .transition(.opacity)

            Circle()
                .trim(from: circleTipStart, to: 1)
                .stroke(
                    tipColor,
                    style: StrokeStyle(lineWidth: width, lineCap: .round)
                )
                .transition(.opacity)
                .rotationEffect(.degrees(-90))

            Circle()
                .trim(from: 0, to: circleProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: width, lineCap: .round)
                )
                .animation(.spring, value: progress)
                .rotationEffect(.degrees(-90))
        }
    }
}
