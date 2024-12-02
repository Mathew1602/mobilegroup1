//
//  NearestGroceryView.swift
//  GroupProjectIOS
//
//  Created by Audrey Man on 2024-11-11
//

import SwiftUI
import MapKit

struct NearestGroceryView: View {
    
    @StateObject var locationManager = LocationManager()
    
    //camera state objects
    @State var camPosition : MapCameraPosition = .userLocation(fallback:.automatic)
    @State var currentLocation : CLLocation?
    
    @State var selectedLocationItem : LocationListItem? //chose items in a list later
    
    //route
    @State var selectedPlacemark : LocationListItem?
    @State private var showRoute = false
    @State var mkRoute : MKRoute? //this is set in getRoute
    @State private var routeDestination : MKMapItem?
    
    
    var body: some View {
        NavigationView{
            VStack{
                
                if(locationManager.locationEnabled){
                
                    VStack{
                        Map(position : $camPosition){
                            
                            //USER
                            UserAnnotation()
                            
                            //LOCATION MARKER
                            //checks if location item exists, if so -- display
                            if let locItem = selectedLocationItem{
                                Marker(coordinate: locItem.coordinate){
                                    Text("\(locItem.name)")
                                }
                            }//if statement ends
                            
                            //ROUTES
                            if let route = mkRoute{
                                MapPolyline(route.polyline)
                                    .stroke(.red, style: StrokeStyle(lineWidth: 5))
                            }//end of route
                        }//end of map
                        
                        //if location changed, so will the region
                        .onChange(of: locationManager.location, initial: true) {
                            //if the location has changed; stops multiple calls on reloading the screen
                            if(currentLocation != locationManager.location){
                                Task{
                                    do{
                                        camPosition = MapCameraPosition.region(locationManager.region) //this is the zoom level
                                        await locationManager.searchStores()
                                        
                                        currentLocation = locationManager.location //sets the currentlocation
                                    }//end of do
                                }//end of task
                            }//end of if currentLocation
                        }//end of onChange
                    }//end of map's VStack
                    .aspectRatio(1.0, contentMode: .fit)
                    .border(.black)
                    
                    if(locationManager.groceryStoreItems.isEmpty){
                        VStack{
                            ProgressView()
                            Text("Loading grocery stores...")
                        }
                        .padding(20)
                    }//if statement ending
                    
                    //List of locations that will take user to the place they want in Maps
                    List(locationManager.getStoreItems(), id: \.id){store in
                        HStack{
                            VStack(alignment: .leading){
                                Text("\(store.name)").bold()
                                Text("\(store.address)")
                                Text("\(store.carTimeString())")
                            }
                            
                            Spacer()
                            
                            Button("Directions"){
                                MKMapItem(placemark: MKPlacemark(coordinate: store.coordinate)).openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])//goes to apple maps on click
                            }
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            
                        }.frame(maxWidth: .infinity, alignment: .leading) //end of VStack
                            .contentShape(RoundedRectangle(cornerRadius: 10)) // make the whole row tappable
                        
                            .onTapGesture {
                                selectedLocationItem = store
                                //print("Selected Location Item: \(store.name)") //location item grabbed test
                                
                                Task{
                                    do{
                                        //make location pin based on address of that store
                                        if selectedLocationItem != nil {
                                            mkRoute = await locationManager.getRoute(store: selectedLocationItem!)
                                            
                                            //once set, change camera position
                                            let rect = mkRoute?.polyline.boundingMapRect
                                            camPosition = (mkRoute != nil ? MapCameraPosition.rect(rect!) : .userLocation(fallback: .automatic))
                                        }
                                        
                                        //print("\(mkRoute ?? MKRoute()) Print statement") //test for mkRoute
                                        
                                    }//end of do
                                }//end of task
                            }//end of ontapgesture
                    }//end of list
                }//end of if location enabled statement
                
                else{
                    
                    //used Xiaoya's icon for not-found
                    Image("not-found")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.secondary)
                    
                    Text("Please enable location services to see the nearest grocery store")
                        .bold()
                        .multilineTextAlignment(.center)
                }//end of else
                    
            }//end of outer vStack
            .navigationTitle("Nearest Grocery Store")
            
        }
    }
}
