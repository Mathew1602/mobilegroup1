//
//  LocationListItem.swift
//  GroupProjectIOS
//
//  Created by Audrey Man on 2024-11-26.
//

import Foundation
import MapKit

public struct LocationListItem : Identifiable{
    public var id = UUID()
    
    let name: String
    let address: String
    let coordinate : CLLocationCoordinate2D //used for marker in map
    let carTime : Int //how long in minutes it takes to travel
    let route : MKRoute
    
    func carTimeString() -> String{
        let hours : Int = carTime / 60
        if hours == 0{
            return "\(carTime) minute(s)"
        }
        return "\(hours) hour(s) and \(carTime % 60) minute(s)"
        
    }//end of cartimeString()
    
}
