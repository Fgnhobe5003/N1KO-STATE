import SwiftUI

struct CPUCard: View {
    @ObservedObject var cpu: CPUMonitor
    @ObservedObject var memory: MemoryMonitor
    @ObservedObject var processes: ProcessMonitor
    @ObservedObject private var chartRange = ChartRangeStore.shared
    @State private var processSort: ProcessSortMode = .cpu
    @State private var chartValues: [Double] = []
    @State private var lastLongRangeRefresh = Date.distantPast

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 11) {
                CardHeader(icon: "cpu",
                           title: Module.cpu.localizedTitle,
                           accent: Theme.info,
                           trailing: Formatters.percent(cpu.totalUsage),
                           trailingColor: Theme.semantic(for: cpu.totalUsage))

                ChartRangePicker(range: $chartRange.range, accent: Theme.accent)

                MetricChart(values: chartValues, maxValue: 1,
                            color: Theme.semantic(for: cpu.totalUsage))
                    .frame(height: 52)
                    .accessibilityLabel("CPU usage chart".loc)

                if !cpu.cores.isEmpty {
                    CoreGrid(cores: cpu.cores)
                }

                HStack(spacing: 0) {
                    StatPill(label: "Load 1m", value: String(format: "%.2f", cpu.loadAverage.one),
                             help: "Average runnable threads over the last minute.")
                    Spacer()
                    StatPill(label: "Load 5m", value: String(format: "%.2f", cpu.loadAverage.five),
                             help: "Average runnable threads over the last five minutes.")
                    Spacer()
                    StatPill(label: "Uptime", value: Formatters.uptime(cpu.uptime))
                    if let f = cpu.frequency {
                        Spacer()
                        StatPill(label: "Freq", value: String(format: "%.1fG", f))
                    }
                }

                if !processes.topByCPU.isEmpty || !processes.topByMemory.isEmpty {
                    Divider().overlay(Theme.stroke)
                    ProcessListSection(cpuList: processes.topByCPU,
                                       memList: processes.topByMemory,
                                       sortMode: processSort,
                                       totalMemory: memory.total,
                                       accent: Theme.info,
                                       onSortToggle: { processSort = processSort == .cpu ? .memory : .cpu })
                }
            }
        }
        .onAppear { updateChartValues(force: true) }
        .onChange(of: chartRange.range) { _ in updateChartValues(force: true) }
        .onChange(of: cpu.history) { _ in updateChartValues() }
    }

    private func updateChartValues(force: Bool = false) {
        let range = chartRange.resolvedRange
        if !force, range != .m1, Date().timeIntervalSince(lastLongRangeRefresh) < 25 { return }
        chartValues = HistoryStore.shared.values(for: .cpu, range: range, shortWindow: cpu.history)
        if range != .m1 { lastLongRangeRefresh = Date() }
    }
}
