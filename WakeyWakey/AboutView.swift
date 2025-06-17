import SwiftUI

struct AboutView: View {
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    private let accentColor = Color(red: 1.0, green: 0.7, blue: 0.0)
    
    var body: some View {
        VStack(spacing: 20) {
            Image("MenuBarIconActive")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64)
            
            Text("Wakey Wakey")
                .font(.title)
                .bold()
            
            Text("Version \(appVersion)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("A simple utility to keep your Mac awake.")
                    .font(.body)
                
                Link("GitHub Repository", destination: URL(string: "https://github.com/joelio/wakeywakey")!)
                    .font(.body)
            }
            
            Spacer()
            
            Text("© 2025 • MIT License")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 300, height: 200)
        .padding()
        .multilineTextAlignment(.center)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
