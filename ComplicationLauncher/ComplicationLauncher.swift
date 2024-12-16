import WidgetKit
import SwiftUI

@main
struct ComplicationLauncher: Widget {
    let kind: String = "ComplicationLauncher"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ComplicationLauncherView(entry: entry)
        }
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
        .configurationDisplayName("RideWaitZ Launcher")
        .description("Launch RideWaitZ quickly.")
    }
}

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let timeline = Timeline(entries: [SimpleEntry(date: Date())], policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

// MARK: - Complication View
struct ComplicationLauncherView: View {
    var entry: SimpleEntry

    var body: some View {
        ZStack {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
            // Optional Overlay
        }
    }
}
