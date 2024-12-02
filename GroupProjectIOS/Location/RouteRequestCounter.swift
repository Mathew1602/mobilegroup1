//
//  RouteRequestCounter.swift
//  GroupProjectIOS
//
//  Created by Audrey Man on 2024-12-01.
//

import Foundation

//RouteRequestCounter will help determine LocationManager manage number of requests and limiting it
class RouteRequestCounter{
    
    private var counter: Int
    
    init(){
        counter = 0
    }
    
    func addCounter() -> Int{
        if counter >= 50{
            print("Returned 0; Counter is full; cannot be added")
            return 0 //not a success; too full
        }
        
        print("Counter added: Value \(counter)")
        counter += 1
        return 1;
    }//addCounter
    
    func subtractCounter() -> Int{
        if counter < 0{
            print("Returned 0; Counter is empty; cannot be subtracted")
            return 0 //not a success; it is empty
        }
        
        print("Counter subtracted: Value \(counter)")
        counter -= 1
        return 1; //success
    }//end of subtractCounter
    
    
    func clearCounter(){
        print("Counter cleared")
        counter = 0;
    }//end of clearCounter
    
    
    
}
