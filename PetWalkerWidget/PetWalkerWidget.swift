//
//  PetWalkerWidget.swift
//  PetWalkerWidget
//
//  Created by Nicholas Melekian on 6/6/23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WanderEntry {
        WanderEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WanderEntry) -> ()) {
        let entry = WanderEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [WanderEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = WanderEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct WanderEntry: TimelineEntry {
    let date: Date
//    let data:
}

struct PetWalkerWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
        var entry: Provider.Entry

        var body: some View {
            switch widgetFamily {
                case .accessoryCorner:
                    ComplicationCorner()
                case .accessoryCircular:
                    ComplicationCircular()
                case .accessoryInline:
                    ComplicationInline()
                case .accessoryRectangular:
                    ComplicationRectangular()
                @unknown default:
                    //mandatory as there are more widget families as in lockscreen widgets etc
                    Text("Not an implemented widget yet")
            }
        }
}

struct ComplicationInline : View {
    var body: some View {
        Text("This will be a quote")
            .widgetAccentable(true)
            .unredacted()
        }
}
struct ComplicationCircular : View {
    var body: some View {
         Text("This will be a quote")
             .widgetAccentable(true)
             .unredacted()
    }
}
struct ComplicationCorner : View {
    var body: some View {
        Image(systemName: "quote.bubble")
            .widgetLabel {
                Text("This will be a quote")
                    .widgetAccentable(true)
            }
        
             .unredacted()
    }
}
struct ComplicationRectangular : View {
    var body: some View {
        Text("This will be a quote")
            .widgetAccentable(true)
            .unredacted()
        }
}

@main
struct PetWalkerWidget: Widget {
    let kind: String = "PetWalkerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PetWalkerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Step Progression")
        .description("This is a complication that shows your your step and distance progress every day.")
    }
}

struct PetWalkerWidget_Previews: PreviewProvider {
    static var previews: some View {
        PetWalkerWidgetEntryView(entry: WanderEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        
        PetWalkerWidgetEntryView(entry: WanderEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        
        PetWalkerWidgetEntryView(entry: WanderEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
        
        PetWalkerWidgetEntryView(entry: WanderEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .accessoryCorner))
        
    }
}
