import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_app/Authentification/login_screen.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/pages/home_page.dart';
import 'package:users_app/widgets/loadind_dialog.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen ({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}


class _SignUpScreenState extends State<SignUpScreen>
{
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController PhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController PasswordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    signUpFormValidation();
  }

  signUpFormValidation()
  {
  if(userNameTextEditingController.text.trim().length < 3 ) 
  {
    cMethods.displaySnackBar("your name musst be atleast 4 or more characters.", context);
  }
  else  if(PhoneTextEditingController.text.trim().length < 10 )
  {
    cMethods.displaySnackBar("your name musst be atleast 10 or more characters.", context);
  }

  else  if(PasswordTextEditingController.text.trim().length < 10 )
  {
    cMethods.displaySnackBar("yours password must be atleast 11 or more characteres", context);
  }
else
  {
    registerNewUser();
  }
  }

  registerNewUser() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Register your account ..."),
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

    if(!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference usersRef =FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);
    Map userDataMap =
        {
          "name": userNameTextEditingController.text.trim(),
          "email": emailTextEditingController.text.trim(),
          "phone" : PhoneTextEditingController.text.trim(),
          "id" : userFirebase.uid,
          "blockStatus" : "no",
        };
        usersRef.set(userDataMap);

        Navigator.push(context, MaterialPageRoute(builder: (c)=> HomePage()));
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
              
              Image.asset(
                "assets/images/logo.png"
              ),
              Text(
                "Create a User\'s Account ",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
      //text field + button
              Padding(

                  padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
 //user name
                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Name",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "User Name",
                      ),
                      style:const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 22,),

                    TextField(
                      controller: PhoneTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Phone",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "User Phone",
                      ),
                      style:const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 22,),
// user email
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "User Email",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "User Name",
                      ),
                      style:const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 22,),
// user password
                    TextField(
                      controller: PasswordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Password",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "User Name",
                      ),
                      style:const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 22,),

                  ElevatedButton(
                      onPressed:()
                      {
                        checkIfNetworkIsAvailable();
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
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
                  color: Colors.grey,
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
