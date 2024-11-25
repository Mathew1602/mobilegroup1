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
    @State var camPosition : MapCameraPosition = .userLocation(fallback:.automatic)
    
    @State var currentLocation : CLLocation?

    //this will be changed by the onChange()
    @State var region : MKCoordinateRegion = MKCoordinateRegion()
    
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
                        
                        //TODO: ON CHANGE !!
                        .onChange(of: locationManager.location, initial: true) {
                            region = MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: locationManager.location!.coordinate.latitude, longitude:locationManager.location!.coordinate.longitude),
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                )
                            print("\(locationManager.location!.coordinate.latitude )")
                            }//end of onChange
//                        }//end of if for map view

                    }//end of map VStack
                        .aspectRatio(1.0, contentMode: .fit)
                        .border(.black)
                
                //List of locations that will take user to the place they want in Maps
                HStack{
                    List{
                        //for the locations in a given search, grab the first three, show here
                        
                        
                        
//                        Text("Buttons here")
//                        Text("Buttons here")
//                        Text("Buttons here")
                            
                        Button("Test"){
                            if
                               CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                               CLLocationManager.authorizationStatus() ==  .authorizedAlways
                            {
                                currentLocation = locationManager.location!
                                print("Here!")
                            }
                            print("\(currentLocation!.coordinate.longitude)")
                            print("CAM: \(camPosition)")
                            print("REGION: \(region.center)")
                        }
                        
                        
                        
                    }//end of HSTACK
                
            }//end of map
            }//end of outer vStack
            
            
        }.onAppear()
        {
            //THIS ONE vv
//            region = MKCoordinateRegion(
//                center: CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude:locationManager.location?.coordinate.longitude ?? 0),
//                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//                )
            
//                region = MKCoordinateRegion(
//                    center: CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude!, longitude: locationManager.location?.coordinate.longitude!),
//                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) //zoom into the streets
//                )
//                
//                camPosition = MapCameraPosition.region(region) //this is the zoom level
            camPosition = MapCameraPosition.region(region) //this is the zoom level
            //do the map search, ask for permissions here
        }.navigationTitle("Nearest Grocery Store")
    }
}
