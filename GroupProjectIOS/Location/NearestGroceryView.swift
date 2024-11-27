
import SwiftUI
import MapKit

struct NearestGroceryView: View {
    
    @StateObject var locationManager = LocationManager()
    
    //camera state objects
    @State var camPosition : MapCameraPosition = .userLocation(fallback:.automatic)
//    @State var currentLocation : CLLocation?
    
    //to test LocationList Item
    //@State var exampleItem : LocationListItem = LocationListItem(name: "Example Item", address: "123 Example Street", carTime: 24, url: "http://hello.ca")
    @State var selectedLocationItem : LocationListItem? //chose items in a list later
    
    
    
    var body: some View {
        NavigationView{
            VStack{
                                
                VStack{
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
                    
                }//end of map's VStack
                .aspectRatio(1.0, contentMode: .fit)
                .border(.black)
                
                //List of locations that will take user to the place they want in Maps
                List(locationManager.getStoreItems(), id: \.id){store in
                    HStack{
                        VStack(alignment: .leading){
                            Text("\(store.name)").bold()
                            Text("\(store.address)")
                            Text("\(store.carTimeString())")
                            //Text("\(store.url)") //this was for testing
                        }
                        
                        Spacer()
                        
                        Button("Directions"){
                            //go to apple maps or google maps
                        }
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        
                    }.frame(maxWidth: .infinity, alignment: .leading) //end of VStack
                        .contentShape(RoundedRectangle(cornerRadius: 10)) // Make the whole row tappable
                        .onTapGesture {
                            selectedLocationItem = store
//                            print("Selected Location Item: \(store.name)") //location item grabbed test
                        }
                }//end of list
                    
            }//end of outer vStack
            .navigationTitle("Nearest Grocery Store")
            
            
        }.onAppear() //end of navstack
        {
            //do the map search, ask for permissions here
            locationManager.searchStores() //for the first time

        }
        
    }
}
