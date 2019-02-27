//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "0a497e24a398e9207931b048835f5cc1"
    
    
    //Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabelC: UILabel!
    @IBOutlet weak var temperatureLabelF: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String: String]) {
        //debug message
        print("Starting getWeatherData.")
        //Alamofire may cause issues.
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                
                
                print(weatherJSON)
                
                self.updateWeatherData(json: weatherJSON)
                //If successfully requested data, print a message to inform the users. Else also print a message to show the failure.
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    //Method for converting celsius to fahrenheit.
    func temperatureInFahrenheit(temperature: Int) -> Int {
        let fahrenheitTemperature = temperature * 9 / 5 + 32
        return fahrenheitTemperature
    }
    
    //Write the updateWeatherData method here.
    func updateWeatherData(json : JSON) {
        
        let tempResult = json["main"]["temp"].doubleValue
        
        weatherDataModel.temperature = Int(tempResult - 273.15)
        //conversion from Kelvin to Celsius for internal storage.
        
        weatherDataModel.city = json["name"].stringValue
        //attach string value to city name
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        
        //cut this portion from UpdateUIWithWeatherData and moved it here.
        temperatureLabelC.text = "\(Int(weatherDataModel.temperature))°C"
        temperatureLabelF.text = "\(Int(temperatureInFahrenheit(temperature: weatherDataModel.temperature)))°F"
        
        updateUIWithWeatherData()
    }
   
   
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
 
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            
            self.locationManager.stopUpdatingLocation()
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    //this variable makes sure that visually, the C/F switch stays consistent over views.
    var persistentTempSwitch = false
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    //associating the toggle state with which temperature labels are on or off. Easier than changing text.
    func gotTemperatureSwitch(tempSwitchOn: Bool) {
        if tempSwitchOn{
            temperatureLabelC.isHidden = true
            temperatureLabelF.isHidden = false
            persistentTempSwitch = true
        }else{
            temperatureLabelF.isHidden = true
            temperatureLabelC.isHidden = false
            persistentTempSwitch = false
        }
    }
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    //Write the PrepareForSegue Method here
    //using a delegate to pass information between the two viewControllers.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            //persistentTempSwitch stores what temperature mode we're in right now.
            //it then passes that information to the next view by delegate.
            //similarly, the city information is passed to next view so that the cancel button will function properly.
            destinationVC.switchTemp = persistentTempSwitch
            destinationVC.delegate = self
            
        }
        
    }
    
    
}











