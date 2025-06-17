import SwiftUI

struct ContentView: View {
    @EnvironmentObject var cafeinate: CafeinateManager
    @ObservedObject var scheduleManager: ScheduleManager
    @AppStorage("launchAtStartup") private var launchAtStartup = false
    @State private var customDuration: String = ""
    @State private var showingScheduleView = false
    
    private let accentColor = Color(red: 1.0, green: 0.7, blue: 0.0)
    private let presets: [(label: String, minutes: Int)] = [
        ("15 min", 15),
        ("30 min", 30),
        ("1 hour", 60),
        ("2 hours", 120),
        ("Indefinite", 0)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            
            Divider()
            
            presetsView
            
            customDurationView
            
            Divider()
            
            preventionTogglesView
            
            Divider()
            
            preferencesView
            
            Spacer()
            
            footerView
        }
        .padding()
        .frame(width: 280)
        .background(Color(.windowBackgroundColor))
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Wakey Wakey")
                    .font(.headline)
                    .foregroundColor(accentColor)
                
                Text(cafeinate.isActive ? "Active" : "Inactive")
                    .font(.subheadline)
                    .foregroundColor(cafeinate.isActive ? accentColor : .secondary)
            }
            
            Spacer()
            
            Image(systemName: cafeinate.isActive ? "sun.max.fill" : "moon.zzz")
                .font(.title)
                .foregroundColor(cafeinate.isActive ? accentColor : .secondary)
        }
    }
    
    private var presetsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Duration Presets")
                .font(.headline)
            
            HStack {
                ForEach(presets, id: \.minutes) { preset in
                    Button(preset.label) {
                        activatePreset(minutes: preset.minutes)
                    }
                    .buttonStyle(PresetButtonStyle(isSelected: cafeinate.isActive && cafeinate.currentDuration == preset.minutes, accentColor: accentColor))
                    
                    if let last = presets.last, preset != last {
                        Spacer()
                    }
                }
            }
        }
    }
    
    private var customDurationView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Custom Duration")
                .font(.headline)
            
            HStack {
                TextField("Minutes", text: $customDuration)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Start") {
                    if let minutes = Int(customDuration), minutes > 0 {
                        cafeinate.activate(minutes: minutes)
                        customDuration = ""
                    }
                }
                .buttonStyle(BorderedButtonStyle())
                .disabled(customDuration.isEmpty || Int(customDuration) == nil)
            }
        }
    }
    
    private var preventionTogglesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prevention Options")
                .font(.headline)
            
            Toggle("Prevent display sleep", isOn: $cafeinate.preventDisplaySleep)
                .disabled(cafeinate.isActive)
            
            Toggle("Prevent disk sleep", isOn: $cafeinate.preventDiskSleep)
                .disabled(cafeinate.isActive)
            
            Toggle("Prevent system sleep", isOn: $cafeinate.preventSystemSleep)
                .disabled(cafeinate.isActive)
        }
    }
    
    private var preferencesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preferences")
                .font(.headline)
            
            Toggle("Launch at startup", isOn: $launchAtStartup)
                .onChange(of: launchAtStartup) { newValue in
                    LaunchAtLogin.isEnabled = newValue
                }
                
            Button("Schedule") {
                showingScheduleView = true
            }
            .buttonStyle(.bordered)
            .sheet(isPresented: $showingScheduleView) {
                ScheduleView(scheduleManager: scheduleManager)
            }
        }
    }
    
    private var footerView: some View {
        HStack {
            Button("About") {
                showAboutWindow()
            }
            .buttonStyle(.link)
            
            Spacer()
            
            Button(cafeinate.isActive ? "Stop" : "Start") {
                if cafeinate.isActive {
                    cafeinate.deactivate()
                } else {
                    cafeinate.activate(minutes: 60) // Default to 1 hour
                }
            }
            .buttonStyle(BorderedButtonStyle())
            .foregroundColor(cafeinate.isActive ? .white : .black)
            .background(cafeinate.isActive ? Color.red : accentColor)
            .cornerRadius(5)
        }
    }
    
    private func activatePreset(minutes: Int) {
        cafeinate.activate(minutes: minutes)
    }
    
    private func showAboutWindow() {
        let aboutWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        aboutWindow.center()
        aboutWindow.title = "About Wakey Wakey"
        
        let aboutView = AboutView()
        aboutWindow.contentView = NSHostingView(rootView: aboutView)
        aboutWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct PresetButtonStyle: ButtonStyle {
    let isSelected: Bool
    let accentColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 5)
            .padding(.horizontal, 8)
            .background(isSelected ? accentColor : Color(.controlBackgroundColor))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let cafeinateManager = CafeinateManager()
        let scheduleManager = ScheduleManager(cafeinateManager: cafeinateManager)
        return ContentView(scheduleManager: scheduleManager)
            .environmentObject(cafeinateManager)
    }
}
