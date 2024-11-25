//
//  LocationManager.swift
//  GroupProjectIOS
//
//  Created by Audrey Man on 2024-11-11.
//

import Foundation
import MapKit

//copied from LocationServicesDemo, edit for app's usage

class LocationManager : NSObject, ObservableObject, CLLocationManagerDelegate{
    
    @Published var location : CLLocation?
    @Published var coordinate : CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude:43.4561, longitude:-79.7000),//center -> should technically be user, but for sake in purpose is this
        span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))//span in this case is how much is the barrier between your location and the other to be searched locations
    
    @Published var MapItems: [MKMapItem] = []
    @Published var mkRoute : MKRoute?

    let manager = CLLocationManager()
    
    override init(){
        self.location = CLLocation()

        super.init()
        
        manager.distanceFilter = 50.0 //update location when user changes 50 or more meters from their original position
        
        //desired acccuracy = best type; manager will figure out what is "best" in given moment and return that to desired accuracy
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self //this is where all the method stuffs is
        manager.requestWhenInUseAuthorization()//asks user for their location
        manager.requestLocation()//grab location from user
        
        manager.startUpdatingLocation() //this tells the application to check if locations' been updated
        
    }
    
    //these are from the delegate -- we add the last bits of the implementation
    //deals with updates in location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{
            print("Location error")
            return
        }
//        print("lat\(location.coordinate.latitude) long\(location.coordinate.longitude)")
////        region.center = location.coordinate //theoretical
        
        //TODO: everytime the location changes... go to the user's location, most recent one
        print("\(locations[0].coordinate.latitude), \(locations[0].coordinate.longitude)")
        
    }
    
    //deals with errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }

    //deals with changes in authorization
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch(manager.authorizationStatus){
        case .authorizedAlways:
            print("location service always enabled")
            break
            
        case .authorizedWhenInUse:
            print("location service authorized only in use")
            break
            
            //this is default when app starts, .notDetermined
        case .notDetermined:
            print("Location undetermined")
            manager.requestWhenInUseAuthorization() //ask for authorization
            break
            
        case .restricted: //meaning user can't change; i.e. company phone
            print("restricted")
            break
            
          default:
            break
        }
        
    }

    
    func searchLocation(for name : String){
        var items : [MKMapItem] = []

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = name
        request.region = region //makes the search specific to the region
        
        let search = MKLocalSearch(request: request) //will find the result of the search
        search.start{response, error in
            guard let res = response else{
                print("error location not found")
                return
            }
            print("location found")
            print(res.mapItems.count)
            items = res.mapItems
            self.MapItems = items
        }
        
        }//end of searchLocation
    
    
}
