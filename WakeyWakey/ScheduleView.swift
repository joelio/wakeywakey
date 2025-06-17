import SwiftUI

struct ScheduleView: View {
    @ObservedObject var scheduleManager: ScheduleManager
    @State private var selectedDay: ScheduleDay?
    
    private let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    private let accentColor = Color(red: 1.0, green: 0.7, blue: 0.0)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Schedule")
                    .font(.headline)
                
                Spacer()
                
                Toggle("Enable Schedule", isOn: $scheduleManager.isScheduleEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: accentColor))
            }
            
            Text("Next activation: \(scheduleManager.getNextScheduledTime())")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .opacity(scheduleManager.isScheduleEnabled ? 1.0 : 0.5)
            
            Divider()
            
            Text("Set active hours for each day:")
                .font(.subheadline)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(scheduleManager.scheduleDays) { day in
                        ScheduleDayRow(
                            day: binding(for: day),
                            dayName: dayNames[day.dayOfWeek],
                            accentColor: accentColor
                        )
                    }
                }
            }
            
            Spacer()
            
            Text("The app will automatically activate during scheduled hours and deactivate when outside scheduled hours.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(width: 350, height: 450)
    }
    
    private func binding(for day: ScheduleDay) -> Binding<ScheduleDay> {
        guard let index = scheduleManager.scheduleDays.firstIndex(where: { $0.id == day.id }) else {
            fatalError("Day not found in schedule")
        }
        return $scheduleManager.scheduleDays[index]
    }
}

struct ScheduleDayRow: View {
    @Binding var day: ScheduleDay
    let dayName: String
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dayName)
                    .font(.headline)
                
                Spacer()
                
                Toggle("", isOn: $day.isEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: accentColor))
                    .labelsHidden()
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("Start")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    DatePicker("", selection: $day.startTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .disabled(!day.isEnabled)
                }
                
                VStack(alignment: .leading) {
                    Text("End")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    DatePicker("", selection: $day.endTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .disabled(!day.isEnabled)
                }
            }
        }
        .padding(10)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .opacity(day.isEnabled ? 1.0 : 0.6)
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        let cafeinateManager = CafeinateManager()
        let scheduleManager = ScheduleManager(cafeinateManager: cafeinateManager)
        ScheduleView(scheduleManager: scheduleManager)
    }
}
