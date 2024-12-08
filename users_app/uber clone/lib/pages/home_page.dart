import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:users_app/Authentification/login_screen.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/pages/search_dest.dart';


class HomePage extends StatefulWidget
{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{

  final Completer<GoogleMapController> googleMapCompletterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  CommonMethods cMethods = CommonMethods();
  double searchContainerHeight= 276;
  double bottomMapPadding= 0;


  void updateMapTheme(GoogleMapController controller)
  {
    getJsonFileFromTheme("Theme/retro_style.json").then((value)=> setGoogleMapStyle(value,controller));
  }

 Future<String> getJsonFileFromTheme(String mapStylePath) async
  {
    ByteData byteData=await rootBundle.load(mapStylePath);
    var list = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller)
  {
    controller.setMapStyle(googleMapStyle);
  }

  getCurentLiveLocationOfUser() async
  {
    Position positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;
    
    
   LatLng positionOfUserLatlng =LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
    
   CameraPosition cameraPosition= CameraPosition(target: positionOfUserLatlng, zoom: 15);
   controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

   await getUserInfoAndCheckBlockStatus();

  }

getUserInfoAndCheckBlockStatus() async
{
  DatabaseReference usersRef =FirebaseDatabase.instance.ref()
      .child("users")
      .child(FirebaseAuth.instance.currentUser!.uid);
  await usersRef.once().then((snap)
  {
    if(snap.snapshot.value != null)
    {
      if((snap.snapshot.value as Map)["blockStatus"] == "no")
      {
        setState(() {
          userName= (snap.snapshot.value as Map)["name"];
        });
      }
      else
      {
        FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
        cMethods.displaySnackBar("you are blocked. contact admin: bilal01.elhou@gmail.com.", context);
      }

    }
    else
    {
      FirebaseAuth.instance.signOut();
      Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));

    }
  });
}


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      key: sKey,
      drawer: Container(
        width: 255,
        color: Colors.black87,
        child: Drawer(
          backgroundColor: Colors.black26,
          child: ListView(
            children: [
              //header
              Container(
                color: Colors.black26,
                height: 160,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(width:16,),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                           const Text(
                            "Profile",
                            style:  TextStyle(
                              color: Colors.white,
                            ),
                          ),

                        ],
                      )

                    ],
                  ),


                ),
              ),

              const Divider(
                height: 1,
                color: Colors.black26,
                thickness: 1,
              ),

              const SizedBox(height: 10,),

              //body

              ListTile(
                leading: IconButton(
                  onPressed: (){},
                  icon: const Icon(Icons.info,color: Colors.grey,),
                ),

                title: const Text("About",style: TextStyle(color: Colors.grey),),
              ),

              GestureDetector(
                onTap: ()
                {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: (){},
                    icon: const Icon(Icons.logout,color: Colors.grey,),
                  ),
                  title: const Text("Logout",style: TextStyle(color: Colors.grey),),
                ),
              )

            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          ///google maps
          GoogleMap(
            padding:EdgeInsets.only(top: 60,bottom: bottomMapPadding) ,
            mapType:MapType.normal ,
            myLocationEnabled: true,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController)
            {
              controllerGoogleMap = mapController;
              updateMapTheme(controllerGoogleMap!);

              googleMapCompletterController.complete(controllerGoogleMap);
              setState(() {
                bottomMapPadding=120;
              });

              getCurentLiveLocationOfUser();
            },
          ),

          ///drawer button
          Positioned(
            top: 60,
            left: 19,
            child: GestureDetector(
              onTap: ()
              {
                sKey.currentState!.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const
                      [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7),
                        ),

                  ],
                ),
                child:const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child:Icon(
                    Icons.menu,
                    color: Colors.black,
                  ) ,
                ),
              ),
            ),
          ),

          ///search location icon button
          Positioned(
            left: 0,
            right: 0,
            bottom: -80,
            child:  Container(
              height: searchContainerHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: ()
                    {
                      Navigator.push(context, MaterialPageRoute(builder:(c)=> SearchDestinationPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding:const EdgeInsets.all(24),
                      
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),

                  ElevatedButton(
                    onPressed: ()
                    {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding:const EdgeInsets.all(24),

                    ),
                    child: const Icon(
                      Icons.home,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),


                  ElevatedButton(
                    onPressed: (){},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding:const EdgeInsets.all(24),

                    ),
                    child: const Icon(
                      Icons.work,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),


                ],
              ),
            ),
          )

        ],
      ),
        );
  }
}
