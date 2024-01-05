import SwiftDate
import SwiftUI
import UIKit

struct LoopView: View {
    private enum Config {
        static let lag: TimeInterval = 30
    }

    @Binding var suggestion: Suggestion?
    @Binding var enactedSuggestion: Suggestion?
    @Binding var closedLoop: Bool
    @Binding var timerDate: Date
    @Binding var isLooping: Bool
    @Binding var lastLoopDate: Date
    @Binding var manualTempBasal: Bool
    @Binding var loopStatusStyle: LoopStatusStyle

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    private let rect = CGRect(x: 0, y: 0, width: 18, height: 18)

    @ViewBuilder private func loopStatusBar(_ text: String) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Rectangle()
                .fill(color)
                .frame(height: 3)

            if isLooping {
                ProgressView().foregroundColor(Color.loopGreen)
            } else {
                Text(text)
                    .padding(4)
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }

            Rectangle()
                .fill(color)
                .frame(height: 3)
        }
    }

    var body: some View {
        if loopStatusStyle == .bar {
            if isLooping {
                loopStatusBar("")
            } else if manualTempBasal {
                loopStatusBar("Manual")
            } else if actualSuggestion?.timestamp != nil {
                loopStatusBar(timeString)
            } else if closedLoop {
                loopStatusBar("--")
            } else {
                loopStatusBar("--")
            }

        } else {
            HStack(alignment: .center) {
                if isLooping {
                    Text("looping")
                } else if manualTempBasal {
                    Text("Manual")
                } else if actualSuggestion?.timestamp != nil {
                    Text(timeString)
                } else {
                    Text("--")
                }
                ZStack {
                    Image(systemName: "circle")
                        .fontWeight(.black)
                        .mask(mask(in: rect).fill(style: FillStyle(eoFill: true)))
                    if isLooping {
                        ProgressView()
                    }
                }
            }
            .strikethrough(!closedLoop || manualTempBasal, pattern: .solid, color: color)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(color)
        }
    }

    private var timeString: String {
        let minAgo = Int((timerDate.timeIntervalSince(lastLoopDate) - Config.lag) / 60) + 1
        if minAgo > 1440 {
            return "--"
        }
        return "\(minAgo) " + NSLocalizedString("min", comment: "Minutes ago since last loop")
    }

    private var color: Color {
        guard actualSuggestion?.timestamp != nil else {
            return .secondary
        }
        guard manualTempBasal == false else {
            return .loopManualTemp
        }
        guard closedLoop == true else {
            return .secondary
        }

        let delta = timerDate.timeIntervalSince(lastLoopDate) - Config.lag

        if delta <= 5.minutes.timeInterval {
            guard actualSuggestion?.deliverAt != nil else {
                return .loopYellow
            }
            return .loopGreen
        } else if delta <= 10.minutes.timeInterval {
            return .loopYellow
        } else {
            return .loopRed
        }
    }

    func mask(in rect: CGRect) -> Path {
        var path = Rectangle().path(in: rect)
        if !closedLoop || manualTempBasal {
            path.addPath(Rectangle().path(in: CGRect(x: rect.minX, y: rect.midY - 4, width: rect.width, height: 5)))
        }
        return path
    }

    private var actualSuggestion: Suggestion? {
        if closedLoop, enactedSuggestion?.recieved == true {
            return enactedSuggestion ?? suggestion
        } else {
            return suggestion
        }
    }
}

extension View {
    func animateForever(
        using animation: Animation = Animation.easeInOut(duration: 1),
        autoreverses: Bool = false,
        _ action: @escaping () -> Void
    ) -> some View {
        let repeated = animation.repeatForever(autoreverses: autoreverses)

        return onAppear {
            withAnimation(repeated) {
                action()
            }
        }
    }
}
