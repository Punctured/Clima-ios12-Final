//
//  ChangeCityViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit


//Write the protocol declaration here:
protocol ChangeCityDelegate {
    func userEnteredANewCityName(city: String)
    func gotTemperatureSwitch(tempSwitchOn: Bool)
}


class ChangeCityViewController: UIViewController {
    
    //one delegate is used for both functions because F/C toggle only applies when the user hits "get weather" anyway
    var delegate : ChangeCityDelegate?
    //the switch starts at Celsius mode.
    var switchTemp : Bool = false
    
    //This is the pre-linked IBOutlets to the text field:
    @IBOutlet weak var changeCityTextField: UITextField!
    //This is the IBAction that gets called when the user taps on the "Get Weather" button:
    override func viewDidLoad() {
        super.viewDidLoad()
        //whichever position the switch displays should match the internal counter.
        //this is a redundancy
        tempSwitch.isOn = switchTemp
        print(switchTemp)
    }
    
    
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
    //calls the EnteredCityName function via protocol.

        let cityName = changeCityTextField.text!
        
        delegate?.userEnteredANewCityName(city: cityName)

        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var tempSwitch: UISwitch!
    
    //calls the gotTemperatureSwitch function via protocol.
    @IBAction func tempSwitchAction(_ sender: UISwitch) {
        delegate?.gotTemperatureSwitch(tempSwitchOn: sender.isOn)
    }
    
    //This is the IBAction that gets called when the user taps the back button. It dismisses the ChangeCityViewController.
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
