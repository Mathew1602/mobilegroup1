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

    //to be changed -- make sure that the region's center will be the user
    @State var region : MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.2341, longitude: -79.7000),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) //zoom into the streets
    )
    
    var body: some View {
        NavigationView{
            VStack{
            
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                
                VStack {
                    Map(position : $camPosition){
                        
                        UserAnnotation() //shows you, the user, on the application
                        
                    }//end of map
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
                        }
                        
                        
                        
                    }//end of HSTACK
                
            }//end of map
            }//end of outer vStack
            
            
        }.onAppear()
        {
            camPosition = MapCameraPosition.region(region) //this is the zoom level
            //do the map search, ask for permissions here
        }.navigationTitle("Nearest Grocery Store")
    }
}
