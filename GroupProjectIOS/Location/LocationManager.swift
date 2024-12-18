
//
//  LocationManager.swift
//  GroupProjectIOS
//
//  Created by Audrey Man on 2024-11-11.
//

import Foundation
import MapKit
import SwiftUICore

//based on from LocationServicesDemo, editedfor app's usage

class LocationManager : NSObject, ObservableObject, CLLocationManagerDelegate{
    
    @Published var location : CLLocation?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude:43.4561, longitude:-79.7000),//base value center
        span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1) //base value span
    )
    
    @Published var mkRoute : MKRoute?
    
    private var groceryStores: [MKMapItem] = []
    
    //for convertToItem()
    @Published var groceryStoreItems : [LocationListItem] = []
    
    @Published var locationEnabled = false
    
    let manager = CLLocationManager()
    
    //Counter system
    //let counter = RouteRequestCounter()
    
    override init(){
        self.location = CLLocation()
        
        super.init()
        
        manager.distanceFilter = 50.0 //update location when user changes 50 or more meters from their original position
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()//asks user for their location
        manager.requestLocation()//grab location from user
        
        manager.startUpdatingLocation() //this tells the application to check if locations' been updated
    }
    
    //manages with updates in location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.last != nil else{
            print("Location error")
            return
        }
        
        //everytime the location changes... go to the user's location, most recent one
        //print("\(locations[locations.count-1].coordinate.latitude),\(locations[locations.count-1].coordinate.longitude)")
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
            print("Location service always enabled")
            locationEnabled = true
            break
            
        case .authorizedWhenInUse:
            print("Location service authorized only in use")
            locationEnabled = true
            break
            
            //this is default when app starts, .notDetermined
        case .notDetermined:
            print("Location undetermined")
            locationEnabled = false

            manager.requestWhenInUseAuthorization() //ask for authorization
            break
        
        default:
            locationEnabled = false
            break
        }
        
    }
    
    /*
    CUSTOM METHODS
     */
    
    //what the view calls to search for stores. It searches for stores and adds the results to the variable
    func searchStores() async {
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
        
        //let pastRequestTimes : [Date]
        
        while(time == -1){
            do{
                
                /*guard self.counter.addCounter() == 1 else {
                    print("Add counter in getCarTimeRoute(); currently full")
                    throw LocationErrors.overRequestCounter(message: "Add counter in getCarTimeRoute(); currently full")
                }
                 */
                                
                let geoCoder = CLGeocoder()
                let result = try await geoCoder.geocodeAddressString(storeNameAddress) //gets the store location in geocoder
                
                if let placemarker = result.first{
                    let request = MKDirections.Request()
                    request.source = MKMapItem(placemark: .init(coordinate: location!.coordinate))
                    request.destination = MKMapItem(placemark: .init(coordinate: placemarker.location!.coordinate))
                    request.transportType = .automobile
                    // print("Request in getCarTimeRoute(): \(request)")
                    
                    let response = try await MKDirections(request: request).calculateETA()
                    
                    
                    time = Int(response.expectedTravelTime / 60) //convert the expected travel time from seconds to minutes
                    //print("\(time) minutes for store \(storeNameAddress)") //testing for times
                    
                }//end of placemaker
                
            }catch{
                print("Error, cannot find car route time: \(error)")
            }
        }//end of while loop
        
        return time //if -1, some error occured. else should return in minutes
        
    }//end of getCarTimeRoute
    
    
//    func getRoute(store : LocationListItem) async -> MKRoute{
    func getRoute(store : MKMapItem) async -> MKRoute{
            
        var route = MKRoute()
        
        let request = MKDirections.Request()
        let sourcePlacemark = MKPlacemark(coordinate: location!.coordinate)
        let routeSource = MKMapItem(placemark: sourcePlacemark)
        
//        let destinationPlacemark = MKPlacemark(coordinate: store.coordinate) //old
        let destinationPlacemark = MKPlacemark(coordinate: store.placemark.coordinate)

        
        let routeDestination = MKMapItem(placemark: destinationPlacemark)
        
        request.source = routeSource
        request.destination = routeDestination
        request.transportType = .automobile
        
        let directions = MKDirections(request:request)
        let result = try? await directions.calculate()
        route = (result?.routes.first)!
        
        //print("getRoute() route: \(route)")
       
        return route
         
    }//end of getRoute()
    
    
    /*
     HELPER METHODS -- for the list view
     */
    
    //takes the list of groceries -- the groceryStores list -- and modifies to make it LocationListItem type
    private func convertToItem() async{
        
        var convertedList : [LocationListItem] = [] //used in the for loop
        
            for i in 0...2{

            let store = groceryStores[i]
   
            
            let name = store.name ?? "No Location Name"
            let address = ("\(store.placemark.subThoroughfare ?? "No Street Number") \(store.placemark.thoroughfare ?? "No Street")")
            let coordinate = store.placemark.coordinate
            
            let time = await getCarTimeRoute(storeNameAddress: "\(name) \(address)")
                
            let route = await getRoute(store: store)
            
            //let item = LocationListItem(name: name, address: address, coordinate: coordinate, carTime: time)
                let item = LocationListItem(name: name, address: address, coordinate: coordinate, carTime: time, route: route)

            
            convertedList.append(item)
            
        }//end of for loop
        
        DispatchQueue.main.sync {
            self.groceryStoreItems = convertedList //change grocery store items to converted list
        }
            
        }//covertToItem() ending
        
        //returns grocery story items for the view
        func getStoreItems() -> [LocationListItem]{
            
            return self.groceryStoreItems
        }
        
        
    }//end of location manager
