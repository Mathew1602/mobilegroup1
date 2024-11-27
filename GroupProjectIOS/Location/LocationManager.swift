
//
//  LocationManager.swift
//  GroupProjectIOS
//
//  Created by Audrey Man on 2024-11-11.
//

import Foundation
import MapKit
import SwiftUICore

//copied from LocationServicesDemo, edit for app's usage

class LocationManager : NSObject, ObservableObject, CLLocationManagerDelegate{
    
    @Published var location : CLLocation?
    @Published var coordinate : CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude:43.4561, longitude:-79.7000),//center -> should technically be user, but for sake in purpose is this
        span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1) //span in this case is how much is the barrier between your location and the other to be searched locations
        )
    
    @Published var groceryStores: [MKMapItem] = [] //does this have to be published?
    @Published var mkRoute : MKRoute?
    
    //for convertToItem()
    @Published var groceryStoreItems : [LocationListItem] = []

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
        
        //everytime the location changes... go to the user's location, most recent one
        print("\(locations[locations.count-1].coordinate.latitude), \(locations[locations.count-1].coordinate.longitude)")
        self.location = locations[locations.count-1] //this = publisher variable
        
        //this is connected to view's camera -- will change what is counted in this region
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: self.location!.coordinate.latitude, longitude: self.location!.coordinate.longitude),
            span: MKCoordinateSpan(latitudeDelta:0.05, longitudeDelta: 0.05))
        
    }//didUpdateLocations end
    
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

    //what the view calls to search for stores. It searches for stores and adds the results to the variable
    func searchStores(){
        var storeItems : [MKMapItem] = []

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "grocery store"
        request.region = region //makes the search specific to the region
        
        let search = MKLocalSearch(request: request) //will find the result of the search
        search.start{ (response, error) in
            guard let res = response else{
                print("Error: No grocery store locations found")
                self.groceryStores = []
                return
            }
            print("\(res.mapItems.count) stores found")
            storeItems = res.mapItems
            
            
            /*
            //Test stuff:
            print("\(storeItems[0].placemark)") // gives you a MKMapItem response
            print(storeItems[0].placemark.thoroughfare)
            print(storeItems[0].placemark.subThoroughfare)

            //https://developer.apple.com/documentation/swift/string/split(separator:maxsplits:omittingemptysubsequences:) - string seperator into an array
           
             MKMapItem: 0x1048f9cb0> {
                 isCurrentLocation = 0;
                 name = Safeway;
                 phoneNumber = "+1 (408) 253-0112";
                 placemark = "Safeway, 20620 W Homestead Rd, Cupertino, CA 95014, United States @ <+37.33616270,-122.03470590> +/- 0.00m, region CLCircularRegion (identifier:'<+37.33616271,-122.03470590> radius 141.17', center:<+37.33616271,-122.03470590>, radius:141.17m)";
                 timeZone = "America/Los_Angeles (PST) offset -28800";
                 url = "https://local.safeway.com/safeway/ca/cupertino/20620-w-homestead-rd.html";
             }
             */
            
            
            self.groceryStores = storeItems
            
            self.convertToItem()//convert the new stores into item types
            //print(self.groceryStoreItems) //testing

            
        }//end of search start
        
    }//end of searchLocation
    
    
    //takes the list of groceries -- the groceryStores list -- and modifies to make it LocationListItem type
    func convertToItem(){
        for store in groceryStores{
            
            let name = store.name ?? "No Location Name"
            let address = ("\(store.placemark.subThoroughfare ?? "No Street Number") \(store.placemark.thoroughfare ?? "No Street")")
            let time = 0;
            //let time = carTime(store) //TODO: When you make the route display, you'll also get the time
            let url = "comgooglemaps://?daddr=48.8566,2.3522)&directionsmode=driving&zoom=14&views=traffic" //based on https://medium.com/swift-productions/launch-google-to-show-route-swift-580aca80cf88 ; TODO: Add exact link for that specific store
            
            let item = LocationListItem(name: name, address: address, carTime: time, url: url)
            
            self.groceryStoreItems.append(item)
        }//end of for loop
        
    }//covertToItem() ending
    
    
}
