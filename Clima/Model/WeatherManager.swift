//
//  WeatherManager.swift
//  Clima
//
//  Created by MAC on 22/02/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation


protocol WeatherManagerDelegate {
    func didUpdateWeather (_ weathermanager: WeatherManager, weather:WeatherModel)
    func didFailWithError (error: Error)
}

struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=e72ca729af228beabd5d20e3b7749713&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        //urlsession for networking
        // 1 create url
        if let url = URL(string: urlString) {
            // 2 create a urlSession
            let session = URLSession(configuration: .default)
            // 3 give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                // completion handler
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                        
                    }
                }
                
            }
            
            task.resume()
        }
        
        
        
    }
    
    func parseJSON (_ weatherData: Data) -> WeatherModel? {
        
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            print(weather.conditionName)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
        
    }
}
        
    
