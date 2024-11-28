
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
        guard locations.last != nil else{
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
    
    /*
    CUSTOM METHODS
     */
    
    //what the view calls to search for stores. It searches for stores and adds the results to the variable
    func searchStores() async{
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
            
            Task{
                do{
                    await self.convertToItem()//convert the new stores into item types
                    //print(self.groceryStoreItems) //testing
                }
                //catch is unreachable
                
            }//end of Task
            
            
        }//end of search start
        
    }//end of searchStores
    
    func getCarTimeRoute(storeNameAddress : String) async -> Int{
        var time = -1
        
        do{
            let geoCoder = CLGeocoder()
            let result = try await geoCoder.geocodeAddressString(storeNameAddress) //gets the store location in geocoder
            
            if let placemarker = result.first{
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: .init(coordinate: location!.coordinate))
                request.destination = MKMapItem(placemark: .init(coordinate: placemarker.location!.coordinate))
                request.transportType = .automobile
                print("IN GET TIME ROUTE \(request)")
                
                let response = try await MKDirections(request: request).calculateETA()
                time = Int(response.expectedTravelTime / 60) //convert the expected travel time from seconds to minutes
                //                print("\(time) minutes for store \(storeNameAddress)") //testing for times
                
            }//end of placemaker
            
        }catch{
            print("Error, cannot find car route time: \(error)")
        }
        
        return time //if -1, some error occured. else should return in minutes
        
    }//end of getCarTimeRoute
    
    
    func getRoute(storeNameAddress : String) async -> MKRoute{
        var route = MKRoute()
        
        Task{
            do{
                let geoCoder = CLGeocoder()
                let result = try await geoCoder.geocodeAddressString(storeNameAddress) //gets the store location in geocoder
                
                if let placemarker = result.first{
                    let request = MKDirections.Request()
                    request.source = MKMapItem(placemark: .init(coordinate: location!.coordinate))
                    request.destination = MKMapItem(placemark: .init(coordinate: placemarker.location!.coordinate))
                    request.transportType = .automobile
                    
                    print("IN GET ROUTE \(request)")
                    
                    let response = try await MKDirections(request: request).calculate()
                    route = response.routes.first!
                }//end of first
            }//end of do
            catch{
                print("Error: cannnot get route: \(error)")
            }
        }//end of task
        
        /*calculate the route in a different method -- on specific place selected
         // mkRoute = res.routes.first //basically setting the route
         //
         // if let route = res.routes.first{ //you'll find several routes
         // for step in route.steps{
         //                        print(step.instructions)
         //                        routeSteps.append(RouteStep(step: step.instructions)) //add it to list of steps, in a list
         //                    }//end of for step in route
         //                } */
        
        return route
    }//end of getRoute()
    
    /*
     HELPER METHODS -- for the list view
     */
    
    //takes the list of groceries -- the groceryStores list -- and modifies to make it LocationListItem type
    private func convertToItem() async{
        
        var convertedList : [LocationListItem] = [] //used in the for loop
        
//        for store in groceryStores{
            for i in 0...2{ //continue this logic to the conversion

            let store = groceryStores[i]
                        
//            if(!groceryStores.isEmpty){
//                for i in 0...2{ //continue this logic to the conversion
//                    var store = groceryStore[i]
//                
//            }
            
            let name = store.name ?? "No Location Name"
            let address = ("\(store.placemark.subThoroughfare ?? "No Street Number") \(store.placemark.thoroughfare ?? "No Street")")
            let coordinate = store.placemark.coordinate
            
            //let time = 0;
            let time = await getCarTimeRoute(storeNameAddress: "\(name) \(address)")
            let url = "comgooglemaps://?daddr=\(store.placemark.coordinate.latitude),\(store.placemark.coordinate.longitude))&directionsmode=driving&zoom=14&views=traffic" //based on https://medium.com/swift-productions/launch-google-to-show-route-swift-580aca80cf88 ; TODO: Add exact link for that specific store
            
            let item = LocationListItem(name: name, address: address, coordinate: coordinate, carTime: time, url: url)
            
                convertedList.append(item)
            
            
        }//end of for loop
        
        DispatchQueue.main.sync {
            self.groceryStoreItems = convertedList //change grocery store items to converted list
        }
            
        }//covertToItem() ending
        
        //returns grocery story items for the view
        func getStoreItems() -> [LocationListItem]{
            
//            var smallList : [LocationListItem] = [] //something works.. as rudimentary ..
//            
//            if(!groceryStoreItems.isEmpty){
//                for i in 0...2{
//                    smallList.append(self.groceryStoreItems[i])
//                }
//            }
            
            return self.groceryStoreItems
        }
        
        
    }//end of location manager
