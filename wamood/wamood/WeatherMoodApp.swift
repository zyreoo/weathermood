//
//  WeatherMoodApp.swift
//  WeatherMood
//
//  Created by Simone Marton on 09.10.2025.
//

import SwiftUI


struct Environment {
    static func loadEnvFile() {
        let path = "/Users/simonemarton/WeatherMood/.env"
        guard FileManager.default.fileExists(atPath: path) else {
            print("No .env file found")
            return
        }
        
        do {
            let contents = try String(contentsOfFile: path, encoding: .utf8)
            let lines = contents.components(separatedBy: .newlines)
            
            for line in lines {
                let parts = line.components(separatedBy: "=")
                if parts.count == 2 {
                    let key = parts[0].trimmingCharacters(in: .whitespaces)
                    let value = parts[1].trimmingCharacters(in: .whitespaces)
                    setenv(key, value, 1)
                }
            }
        } catch {
            print("Error loading .env file: \(error)")
        }
    }
}

struct WeatherResponse: Codable {
    let weather: [Weather]
    let main: Main
    let name: String
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
}


struct YoutubePlaylist: Codable{
    let playlistUrl: String
    let name: String
}


public struct WeatherMainView: View {
    @State private var weatherData: WeatherResponse?
    @State private var errorMessage: String?
    @State private var city: String = ""
    @State private var isButtonDisabled = true
    @State private var playlist: YoutubePlaylist?
    
    public init() {}
    
    
    func fetchYoutubeData(query:String) async{
    
        guard let apiKey = ProcessInfo.processInfo.environment["YOUTUBE_APIKEY"] else  {
            errorMessage = "API KEY IS NOT FOUND"
            return
        }
        
        let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(query)&type=playlist&maxResults=1&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else{
            errorMessage = "Invalid URL"
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                
                print("\n\(prettyString)")
            } else {
                print("Failed to parse JSON.")
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error: \(error)")
        }
    }
 
    func fetchWeatherData() async {
        guard let apiKey = ProcessInfo.processInfo.environment["API_KEY"] else {
            errorMessage = "API key not found in .env file"
            return
        }
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            weatherData = try JSONDecoder().decode(WeatherResponse.self, from: data)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            weatherData = nil
        }
    }
    
    func resetApp(){
        weatherData = nil
        errorMessage = nil
        city = ""
    }
    
    
    public var body: some View {
        VStack(spacing: 20) {
            TextField("Enter city", text: $city)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            
            if weatherData == nil {
                var isButtonDisabled = true
                
                if isButtonDisabled{
                    Button("Get Weather"){
                        Task{
                            await fetchWeatherData()
                        }
                    }
                }
            }
            
            
            if let weather = weatherData {
                    
                    VStack(spacing: 10) {
                        Text(weather.name)
                            .font(.title)
                        
                        
                        if let firstWeather = weather.weather.first {
                            Text(firstWeather.description.capitalized)
                                .font(.headline)
                            
                        }
                        
                        
                        Button("Search a good playlist based on the weather mood"){
                            Task{
                                let query = "music " + (weather.weather.first?.description ?? "music")
                                
                                await fetchYoutubeData(query: query)
                            }
                        }
                        
//                        
//                        Button("Get a quote based on your mode"){
//
//                        }
                        
                        
                        Button("reset"){
                            resetApp()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Text(String(format: "%.1f°C", weather.main.temp))
                            .font(.largeTitle)
                        
                        Text("Humidity: \(weather.main.humidity)%")
                            .font(.subheadline)
                        
                    }
                }
            
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .frame(
            minWidth: 100, maxWidth: 400,
            minHeight: 100, maxHeight: 400)
        .padding()
        .onAppear {
            Environment.loadEnvFile()
        }
    }
}

// MARK: - Preview
#Preview {
    WeatherMainView()
}
