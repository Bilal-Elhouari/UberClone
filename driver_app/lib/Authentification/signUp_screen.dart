import 'dart:io';

import 'package:driver_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../methods/common_methods.dart';
import '../widgets/loadind_dialog.dart';
import 'login_screen.dart';



class SignUpScreen extends StatefulWidget {
  const SignUpScreen ({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}


class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController PhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController PasswordTextEditingController = TextEditingController();

  TextEditingController carModelTextEditingController = TextEditingController();
  TextEditingController carColorTextEditingController = TextEditingController();
  TextEditingController carIdTextEditingController = TextEditingController();

  CommonMethods cMethods = CommonMethods();
  XFile? imageFile;
  String urlOfUploadedImage = "";

  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    if(imageFile != null) // image validation
      {
        signUpFormValidation();
      }
    else
    {
      cMethods.displaySnackBar("Please choose image first", context);
    }
  }

  signUpFormValidation() {
    if (userNameTextEditingController.text
        .trim()
        .length < 3) {
      cMethods.displaySnackBar(
          "your name musst be atleast 4 or more characters.", context);
    }
    else if (PhoneTextEditingController.text
        .trim()
        .length < 10) {
      cMethods.displaySnackBar(
          "your name musst be atleast 10 or more characters.", context);
    }

    else if (PasswordTextEditingController.text
        .trim()
        .length < 10) {
      cMethods.displaySnackBar(
          "yours password must be atleast 11 or more characteres", context);
    }
    else if (carModelTextEditingController.text.trim().isEmpty)
    {
      cMethods.displaySnackBar(
          "Please write your car model", context);
    }
    else if (carColorTextEditingController.text.trim().isEmpty) {
      cMethods.displaySnackBar(
          "please write your car color", context);
    }
    else if (carIdTextEditingController.text.trim().isEmpty) {
      cMethods.displaySnackBar(
          "please write your matricule", context);
    }
    else {
      UploadImageToStorage();
    }
  }

  UploadImageToStorage() async
  {
    String imageIdName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage = FirebaseStorage.instance.ref().child("image").child(imageIdName);

    UploadTask uploadTask= referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfUploadedImage =await snapshot.ref.getDownloadURL();

    setState(() {
      urlOfUploadedImage;
    });
    registerNewDriver();
  }
  registerNewDriver() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Register your account ..."),
    );

    final User? userFirebase = (
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: PasswordTextEditingController.text.trim(),
        ).catchError((errorMsg)
        {
          Navigator.pop(context);
          cMethods.displaySnackBar(errorMsg.toString(), context);
        })
    ).user;

    if (!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("drivers").child(userFirebase!.uid);

    Map driverCarInfo=
    {
      "carColor" : carColorTextEditingController.text.trim(),
      "carModel" : carModelTextEditingController.text.trim(),
      "carId" : carIdTextEditingController.text.trim(),
    };


    Map driverDataMap =
    {
      "Photo" : urlOfUploadedImage,
      "car_details" : driverCarInfo,
      "name": userNameTextEditingController.text.trim(),
      "email": emailTextEditingController.text.trim(),
      "phone": PhoneTextEditingController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
    };
    usersRef.set(driverDataMap);

    Navigator.push(context, MaterialPageRoute(builder: (c) => Dashboard()));
  }

  chooseImageFromGallery() async
  {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null)
    {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }



  @override
  Widget build(BuildContext context)

  {
    return Scaffold(
      body: SingleChildScrollView(

        child: Padding(

          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              const SizedBox(
                height: 60,
              ),
             imageFile == null ?
             const CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage("assets/image/avatarman.png"),
              ) : Container(
               height: 180,
               width: 180,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 color: Colors.grey,
                 image: DecorationImage(
                   fit: BoxFit.fitHeight,
                   image: FileImage(
                     File(
                       imageFile!.path,
                     ),
                   )
                 )
               ),
             ),
              const SizedBox(
                height: 20,
              ),
               GestureDetector(
                 onTap: ()
                 {
                    chooseImageFromGallery();
                 },
                 child: const Text(
                  "Select Image",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                               ),
               ),
      //text field + button
              Padding(

                  padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
 //user name
                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "your Name",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "driver Name",
                      ),
                      style:const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10,),

                    TextField(
                      controller: PhoneTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "your Phone",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "driver Phone",
                      ),
                      style:const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10,),
// user email
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "your Email",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "driver Email",
                      ),
                      style:const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10,),
// user password
                    TextField(
                      controller: PasswordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "your Password",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "driver Password",
                      ),
                      style:const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10,),

                    TextField(
                      controller: carModelTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "your Car Model",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "car Name",
                      ),
                      style:const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10,),

                    TextField(
                      controller: carColorTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "your car color",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "Car Color",
                      ),
                      style:const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10,),

                    TextField(
                      controller: carIdTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "your car Matricule",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "Matricule",
                      ),
                      style:const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20,),


                    ElevatedButton(
                      onPressed:()
                      {
                        checkIfNetworkIsAvailable();
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 40,vertical: 10)
                    ),
                    child: const Text(
                      "Sign Up"
                    ),
                  ),
                  ],
                ),
              ),

//textbutton
            TextButton(
              onPressed: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=>LoginScreen()));


                  },
              child: const Text(
                "Already have an Account? Login Here",
                style: TextStyle(
                  color: Colors.blue,
                ),

              ),
            )
            ],
          ),

        ),


      ),

    );
  }
}
