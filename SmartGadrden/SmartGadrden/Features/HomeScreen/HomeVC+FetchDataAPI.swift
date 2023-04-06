//
//  HomeVC+FetchDataAPI.swift
//  SmartGadrden
//
//  Created by Vu Duc Trong on 04/04/2023.
//

import UIKit

// MARK: - fetchData

extension HomeViewController {
    func fetchDataFromAPI() {
        guard let url = URL(string: "https://api.weatherapi.com/v1/current.json?key=b421cb51418a45ef9f1150452232203&q=Hanoi&aqi=no") else { return }
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                print("Error")
                return
            }
            var fullWeatherData: WeatherData?
            do {
                fullWeatherData = try JSONDecoder().decode(WeatherData.self, from: data)
            } catch {
                print("Error")
            }

            DispatchQueue.main.async {
                self.cityLabel.text = "\(fullWeatherData?.location.name ?? ""),"
                self.countryLabel.text = "\(fullWeatherData?.location.country ?? "")"
                self.temperatureLabel.text = String(format: "%.f℃", fullWeatherData?.current.tempC ?? 0)
            }
        })
        dataTask.resume()
    }
}
