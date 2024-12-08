import 'package:driver_app/Authentification/signUp_screen.dart';
import 'package:driver_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';



import '../methods/common_methods.dart';
import '../widgets/loadind_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController PasswordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();
  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    signInFormValidation();
  }

  signInFormValidation()
  {
    if(!emailTextEditingController.text.contains("@"))
      {
        cMethods.displaySnackBar("please write valid email", context);
      }
     else if(PasswordTextEditingController.text.trim().length < 10 )
    {
      cMethods.displaySnackBar("yours password must be atleast 11 or more characteres", context);
    }
    else
    {
      signinUser();
    }
  }

  signinUser() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Allowing you to login ..."),
    );
    final User? userFirebase = (
        await FirebaseAuth.instance.signInWithEmailAndPassword(
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

    if(userFirebase != null)
      {
        DatabaseReference usersRef =FirebaseDatabase.instance.ref().child("drivers").child(userFirebase.uid);
        usersRef.once().then((snap)
        {
          if(snap.snapshot.value != null)
            {
              if((snap.snapshot.value as Map)["blockStatus"] == "no")
                {
                  //userName = (snap.snapshot.value as Map)["name"];
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> Dashboard()));
                }
              else
              {
                FirebaseAuth.instance.signOut();
                cMethods.displaySnackBar("you are blocked. contact admin: bilal01.elhou@gmail.com.", context);
              }

            }
          else
            {
              FirebaseAuth.instance.signOut();
              cMethods.displaySnackBar("your not a driver.", context);
            }
        });
      }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(

        child: Padding(

          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              const SizedBox(
                height: 80,
              ),


              Image.asset(
                  "assets/image/uberexec.png",
                width: 250,
              ),

              const SizedBox(
                height: 30,
              ),



              Text(
                "Login as a Driver ",
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

// user email
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Driver Email",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "driver email",
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
                        labelText: "driver Password",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintText: "driver password",
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

                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(horizontal: 40,vertical: 10)
                      ),
                      child: const Text(
                          "Login"

                      ),
                    ),
                  ],
                ),
              ),

//textbutton
              TextButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=>SignUpScreen()));


                },
                child: const Text(
                  "Dont\'t have an Account? Register Here",
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
