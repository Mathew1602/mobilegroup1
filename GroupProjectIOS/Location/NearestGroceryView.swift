//
//  NearestGroceryView.swift
//  GroupProjectIOS
//
//  Created by Audrey Man on 2024-11-11.
//

import SwiftUI
import MapKit

struct NearestGroceryView: View {
    
    @StateObject var locationManager = LocationManager()
    
    //camera state objects
    @State var camPosition : MapCameraPosition = .userLocation(fallback:.automatic)
    @State var currentLocation : CLLocation?
    
    //to test LocationList Item
    @State var exampleItem : LocationListItem = LocationListItem(name: "Example Item", address: "123 Example Street", carTime: 24, url: "http://hello.ca")
    
    var body: some View {
        NavigationView{
            VStack{
                
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                
                VStack {
                    //if the map is legal -- (0,0) is null island, but highly unlikely someone would look for grocery near null island
                    //                    if(!(region.center.latitude == 0 && region.center.longitude == 0)){ //add this later
                    Map(position : $camPosition){
                        
                        UserAnnotation() //shows you, the user, on the application
                        
                    }//end of map
                    
                    //if location changed, so will the region
                    .onChange(of: locationManager.location, initial: true) {
                        camPosition = MapCameraPosition.region(locationManager.region) //this is the zoom level
                    }//end of onChange
                    //                        }//end of if for map view
                    
                }//end of map VStack
                .aspectRatio(1.0, contentMode: .fit)
                .border(.black)
                
                //List of locations that will take user to the place they want in Maps
                HStack{
                    List{
                        VStack{
                            Text("\(exampleItem.name)")
                            Text("\(exampleItem.address)")
                            Text("Time (by car): \(exampleItem.carTime)")
                        }
                        
                        Button("Directions"){
                            //will go to google maps or apple maps
                        }
                        
                        
                        //                        //for the locations in a given search, grab the first three, show here /fix this later
                        //                        ForEach(locationManager.groceryStores) { food in
                        ////                            Text("\(groceryStore.description)")
                        //                        }
                        
                    }//end of list
                    
                    
                    Button("Test"){
                        if
                            CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                                CLLocationManager.authorizationStatus() ==  .authorizedAlways
                        {
                            currentLocation = locationManager.location!
                            //                            print("\(currentLocation!.coordinate.longitude)")
                            //                            print("CAM: \(camPosition)")
                        }
                        
                        //testing search function
                        print(locationManager.searchStores())
                        
                        
                        
                        
                        
                        
                    }//end of HSTACK
                    
                }//end of map
            }//end of outer vStack
            
            
        }.onAppear()
        {
            //            camPosition = MapCameraPosition.region(region) //this is the zoom level
            //do the map search, ask for permissions here
        }.navigationTitle("Nearest Grocery Store")
        
    }
}
