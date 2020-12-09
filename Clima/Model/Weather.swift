//
//  Waether.swift
//  Clima
//
//  Created by apple on 23/11/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "http://api.openweathermap.org/data/2.5/weather?appid=7cc3530f5b22131438b47dc2556846c8&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fecthWeather(cityName : String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        perfromRequest(with: urlString)
    }
    func fecthWeather(latitude : CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        perfromRequest(with: urlString)
    }
    func perfromRequest(with urlString : String) {
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) {(data, respond, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let weather = self.parseJSON(weatherData: safeData){
                    self.delegate?.didUpdateWeather(self, weather: weather)
                }
            }
        }
            task.resume()
        }
    }
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let weather = WeatherModel(condition: id, cityName: name, temperature: temp)
            return weather
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
