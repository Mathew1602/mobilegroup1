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
//    @State var currentLocation : CLLocation?
    
    //to test LocationList Item
    //@State var exampleItem : LocationListItem = LocationListItem(name: "Example Item", address: "123 Example Street", carTime: 24, url: "http://hello.ca")
//    @State var selectedLocationItem : LocationListItem //chose items in a list later
    
    var body: some View {
        NavigationView{
            VStack{
                                
                VStack {
                    //if the map is legal -- (0,0) is null island, but highly unlikely someone would look for grocery near null island
                    //                    if(!(region.center.latitude == 0 && region.center.longitude == 0)){ //add this later
                    Map(position : $camPosition){
                        
                        UserAnnotation() //shows you, the user, on the application
                        
                    }//end of map
                    
                    //if location changed, so will the region
                    .onChange(of: locationManager.location, initial: true) {
                        camPosition = MapCameraPosition.region(locationManager.region) //this is the zoom level
                        locationManager.searchStores()
                    }//end of onChange
                    //                        }//end of if for map view
                    
                }//end of map VStack
                .aspectRatio(1.0, contentMode: .fit)
                .border(.black)
                
                //List of locations that will take user to the place they want in Maps
                HStack{
                    
                    List(locationManager.getStoreItems(), id: \.self){store in
                        VStack{
                            Text("\(store.name)").bold()
                            Text("\(store.address)")
                            Text("Time (by car): \(store.carTimeString())")
                            Text("\(store.url)")
                            
                            HStack{
                                Button("Directions"){
                                    //go to apple maps or google maps
                                }
                            }.frame(maxWidth: .infinity, alignment: .trailing)//end ofHSTack
                                .background(.blue)
                            
                        
                        }.frame(maxWidth: .infinity, alignment: .leading) //end of VStack
                        
                    }//list end
                    
                }//end of map
            }//end of outer vStack
            .navigationTitle("Nearest Grocery Store")
            
            
        }.onAppear()
        {
            //do the map search, ask for permissions here
            locationManager.searchStores() //for the first time

        }
        
    }
}
