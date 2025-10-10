//
//  ContentView.swift
//  wamood
//
//  Created by Simone Marton on 09.10.2025.
//

import SwiftUI
import Dotenv




Dotenv.load()

let apiKey = ProcessInfo.processInfo.environment["API_KEY"]
let cityname:String = "Dej"

func fetchDataWeather(){
    let api_URL = URL(String: "https://api.openweathermap.org/data/2.5/weather?q=(cityname)&appid=(APIkey)")!

    let (data, _) = try await URLSession.shared.data(from: api_URL)

    let decode = try JSONDecoder().decode(weatherResponse.self, from: data)

    return decode.results
}
Task {
    do {
        let movies = try await fetchDataWeather()

        print(movies)
    } catch {
        print(error)
    }
}




struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}



#Preview {
    ContentView()
}
