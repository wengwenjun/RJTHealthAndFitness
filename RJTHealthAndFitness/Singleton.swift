//
//  Singleton.swift
//  RJTHealthAndFitness
//
//  Created by Wenjun Weng on 5/22/17.
//  Copyright © 2017 rjt.compquest. All rights reserved.
//

import UIKit
import CoreBluetooth
enum Services: String {
    case heartMonitor = "CE4CFF01-B85D-49AA-8E03-0D34779A6EEF"
    case stepsMonitor = "3E18B512-D819-4550-8343-F9EFFDA2F896"
    case temperatureMonitor = "4B5CF42E-3224-43B4-AFA2-8A0917B34856"
}

enum Characteristics: String {
    case heartRate = "7821C91E-A551-4907-A5E0-F6CB64AC0A4B"
    case stepsCount = "EE6134CF-F907-45CD-B259-2AB681CA6B32"
    case temperatureStat = "2BCE8CF5-F03E-4EB2-BB35-77C87AC5F1A4"
}

protocol CentralDelegate {
    func showHearBeat(heartBeatString : String)
    func showStepsCount(stepsCountString : String)
    func showBodyTemperature(bodyTemperatureString : String)
}
class Singleton: NSObject,CBCentralManagerDelegate,CBPeripheralDelegate {
    var centralManager : CBCentralManager?
    var myperipheral : CBPeripheral?
    
    var heartRateCharactersitics: CBCharacteristic?
    var stepsCountCharactersitics: CBCharacteristic?
    var bodyTempCharactersitics: CBCharacteristic?
    
    var bluetoothDelegate: CentralDelegate?
    
    static let shareInstance : Singleton = {
        let instance = Singleton()
        instance.centralManager = CBCentralManager(delegate: instance, queue: nil)
        return instance
    }()
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        }else{
            print("BLE with Error")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        for(key,value) in advertisementData{
            if key == "kCBAdvDataLocalName" && (value as! String) == "Rebecca's rMBP"{
                print("Rebecca's rMBP")
                myperipheral = peripheral
                central.stopScan()
                central.connect(peripheral, options: nil)
                
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected to", peripheral.name ?? "Nothing")
        peripheral.delegate = self
        
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        for service in peripheral.services! {
            if service.uuid.uuidString == Services.heartMonitor.rawValue{
                print("Found Heart moniter service")
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
            if service.uuid.uuidString == Services.stepsMonitor.rawValue{
                print("Found Steps moniter service")
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
            if service.uuid.uuidString == Services.temperatureMonitor.rawValue{
                print("Found temperature moniter service")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristics  in service.characteristics! {
            if characteristics.uuid.uuidString == Characteristics.heartRate.rawValue {
                heartRateCharactersitics = characteristics
                myperipheral?.setNotifyValue(true, for: heartRateCharactersitics!)
            }
            
            if characteristics.uuid.uuidString == Characteristics.stepsCount.rawValue {
                stepsCountCharactersitics = characteristics
                
                getSteps()
            }
            
            if characteristics.uuid.uuidString == Characteristics.temperatureStat.rawValue {
                bodyTempCharactersitics = characteristics
                
                getTemperature()
            }
        }
    }
    
    func getSteps(){
        myperipheral?.readValue(for: stepsCountCharactersitics!)
    }
    
    func getTemperature(){
        myperipheral?.readValue(for: bodyTempCharactersitics!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic == stepsCountCharactersitics{
            if let value = characteristic.value {
                let s = String(bytes: value, encoding: .utf8)
                self.bluetoothDelegate?.showStepsCount(stepsCountString: s!)
                print("Steps count: ", s ?? "")
            }
        }
        
        if characteristic == heartRateCharactersitics{
            if let value = characteristic.value {
                let s = String(bytes: value, encoding: .utf8)
                self.bluetoothDelegate?.showHearBeat(heartBeatString: s!)
                print("Heart Rate: ", s ?? "")
            }
        }
        
        if characteristic == bodyTempCharactersitics{
            if let value = characteristic.value {
                let s = String(bytes: value, encoding: .utf8)
                self.bluetoothDelegate?.showBodyTemperature(bodyTemperatureString: s!)
                print("Body Temp: ", s ?? "")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error?.localizedDescription ?? "")
        }
    }
    
    // Formula for Calories burned
    // We need weight
    /*
     Calories burned per mile = 0.57 x 175 lbs.(your weight) = 99.75 calories per mile.
     */
    
}
