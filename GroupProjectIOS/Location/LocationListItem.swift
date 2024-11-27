//
//  LocationListItem.swift
//  GroupProjectIOS
//
//  Created by Audrey Man on 2024-11-26.
//

import Foundation

public struct LocationListItem : Hashable{
    let name: String
    let address: String
    let carTime : Int //how long in minutes it takes to travel
    let url : String //url for the google maps link to this location
    
    
    func carTimeString() -> String{
        var hours : Int = carTime / 60
        if hours == 0{
            return "\(carTime) minute(s)"
        }
        return "\(hours) hour(s) and \(carTime % 60) minute(s)"
        
    }//end of cartimeString()
    
}
