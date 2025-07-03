import SwiftUI

// Define a struct for container statistics
struct ContainerStats: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let cpuUsage: Double
    let memoryUsage: Double
}

struct ContentView: View {
    private let savedAPIKey = "SavedAPIAddress"

    @State private var containerStats: [ContainerStats] = [] // Holds container stats
    @State private var apiAddress: String = UserDefaults.standard.string(forKey: "SavedAPIAddress") ?? "http://127.0.0.1:5005/stats?api_key=123abc" // Default or saved API address
    private let refreshInterval = 5.0 // Refresh container stats every 5 seconds

    var body: some View {
        VStack(spacing: 10) {
            header // Header with app title

            apiConfiguration // UI for API address input

            ScrollView {
                containerStatsList // List of container stats
            }
            .padding(.horizontal, 8) // Compact horizontal padding

            Spacer() // Dynamic spacer for layout
        }
        .fixedSize(horizontal: false, vertical: false) // Allow both horizontal and vertical resizing
        .padding() // Add some padding around content
        .onAppear(perform: startFetchingStats)
    }

    // MARK: - Subviews

    private var header: some View {
        Text("Docker Container Stats")
            .font(.headline)
            .padding(.vertical, 8)
    }

    private var apiConfiguration: some View {
        VStack(alignment: .leading) {
            Text("Docker API Address:")
                .font(.footnote)
                .fontWeight(.semibold)

            TextField("Enter Docker backend URL", text: $apiAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.primary)
                .padding(.bottom, 8)
                .onChange(of: apiAddress) { newValue in
                    UserDefaults.standard.set(newValue, forKey: savedAPIKey)
                }
        }
    }

    private var containerStatsList: some View {
        VStack(spacing: 4) {
            ForEach(containerStats) { container in
                containerBubble(for: container)
            }
        }
    }

    @ViewBuilder
    private func containerBubble(for container: ContainerStats) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(container.name)
                    .font(.system(size: 12))
                    .fontWeight(.bold)
                    .lineLimit(1) // Prevent overly long names from blocking layout

                cpuDetails(for: container)
                memoryDetails(for: container)
            }
            Spacer(minLength: 0) // Dynamic horizontal stretching
        }
        .padding(6)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(6)
        .shadow(radius: 1)
    }

    private func cpuDetails(for container: ContainerStats) -> some View {
        HStack {
            Text("CPU:")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            Text("\(String(format: "%.2f%%", container.cpuUsage))")
                .font(.system(size: 10))
                .foregroundColor(.primary)
            Spacer(minLength: 0) // Flexible horizontal shrinking
        }
    }

    private func memoryDetails(for container: ContainerStats) -> some View {
        HStack {
            Text("Mem:")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            Text("\(String(format: "%.2f", container.memoryUsage)) MB")
                .font(.system(size: 10))
                .foregroundColor(.primary)
            Spacer(minLength: 0) // Flexible horizontal shrinking
        }
    }

    // MARK: - API and Timer

    private func startFetchingStats() {
        Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in
            fetchContainerStats()
        }
    }

    private func fetchContainerStats() {
        guard let url = URL(string: apiAddress.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            print("Invalid API address: \(apiAddress)")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching stats: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decodedStats = try JSONDecoder().decode([ContainerStats].self, from: data)
                DispatchQueue.main.async {
                    containerStats = decodedStats
                }
            } catch {
                print("Failed to decode stats: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

