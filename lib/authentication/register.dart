import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:flutter/material.dart';
import 'package:foodpanda_seller_app/widgets/custom_textfield.dart';
import 'package:foodpanda_seller_app/widgets/error_dialog.dart';
import 'package:foodpanda_seller_app/widgets/loading_dialog.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global/global.dart';
import '../mainScreens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  String _phonenumber = '';
  RegExp regExp = RegExp(r'^[789]\d{9}$');
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();
  String completeAddress = "";
  String downloadUrl = "";
  Position? position;
  List<Placemark>? placeMarks;

  takeImage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: const Text(
                "Select Image :",
                style:
                    TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
              children: [
                SimpleDialogOption(
                  child: const Text(
                    "Capture Image with Camera",
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: captureImageWithCamera,
                ),
                SimpleDialogOption(
                  child: const Text(
                    "Select From Gallery",
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: (() async {
                    Navigator.pop(context);
                    imageXFile =
                        await _picker.pickImage(source: ImageSource.gallery);
                    setState(() {
                      imageXFile;
                    });
                  }),
                ),
                SimpleDialogOption(
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ));
  }

  Future<void> captureImageWithCamera() async {
    Navigator.pop(context);
    imageXFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      imageXFile;
    });
  }

  // Future<void> pickImageFromGallery() async {
  //   imageXFile = await _picker.pickImage(source: ImageSource.gallery);

  //   setState(() {
  //     imageXFile;
  //   });
  // }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getCurrentLocation() async {
    Position newPosition = await _determinePosition();

    position = newPosition;
    placeMarks =
        await placemarkFromCoordinates(position!.latitude, position!.longitude);

    Placemark pMark = placeMarks![0];

    completeAddress =
        '${pMark.subThoroughfare}, ${pMark.thoroughfare}, ${pMark.subLocality}, ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea}, ${pMark.postalCode}, ${pMark.country}';

    print('Address $completeAddress');
    locationController.text = completeAddress;
  }

  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please select an image",
            );
          });
    } else {
      if (passwordController.text == confirmPasswordController.text) {
        if (confirmPasswordController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            phoneController.text.isNotEmpty &&
            nameController.text.isNotEmpty &&
            locationController.text.isNotEmpty) {
          if (regExp.hasMatch(phoneController.text)) {
            showDialog(
                context: context,
                builder: (c) {
                  return const LoadingDialog(
                    message: "Registering Acccount",
                  );
                });

            String fileName = DateTime.now().millisecondsSinceEpoch.toString();
            fStorage.Reference reference = fStorage.FirebaseStorage.instance
                .ref()
                .child("sellers")
                .child(fileName);

            fStorage.UploadTask uploadTask =
                reference.putFile(File(imageXFile!.path));
            fStorage.TaskSnapshot taskSnapshot =
                await uploadTask.whenComplete(() => {});
            downloadUrl = await taskSnapshot.ref.getDownloadURL();

            authenticateSellerAndSignUp();
          } else {
            showDialog(
                context: context,
                builder: (c) {
                  return const ErrorDialog(
                    message: "Invalid Phone number",
                  );
                });
          }
        } else {
          showDialog(
              context: context,
              builder: (c) {
                return const ErrorDialog(
                  message: "Please complete the required info for registration",
                );
              });
        }
      } else {
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "Password do not match",
              );
            });
      }
    }
  }

  void authenticateSellerAndSignUp() async {
    User? currentUser;

    await firebaseAuth
        .createUserWithEmailAndPassword(
            email: emailController.text.trim().toString(),
            password: passwordController.text.trim().toString())
        .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (builder) {
            return ErrorDialog(message: error.message.toString());
          });
    });

    if (currentUser != null) {
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);

        // send user to homepage
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (builder) => const HomeScreen()));
      });
    }
  }

  Future saveDataToFirestore(User currentUser) async {
    FirebaseFirestore.instance.collection("sellers").doc(currentUser.uid).set(
      {
        "sellerUID": currentUser.uid,
        "sellerEmail": currentUser.email,
        "sellerName": nameController.text.trim().toString(),
        "sellerAvatarUrl": downloadUrl,
        "phone": phoneController.text.trim().toString(),
        "address": completeAddress,
        "status": "approved",
        "earnings": 0.0,
        "lat": position!.latitude,
        "lng": position!.longitude
      },
    );

    // save data locally

    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", emailController.text.trim());
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("photoUrl", downloadUrl);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              takeImage(context);
            },
            child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.2,
                backgroundColor: Colors.white,
                backgroundImage: imageXFile == null
                    ? null
                    : FileImage(File(imageXFile!.path)),
                child: imageXFile == null
                    ? Icon(
                        Icons.add_photo_alternate,
                        size: MediaQuery.of(context).size.width * 0.2,
                        color: Colors.grey,
                      )
                    : null),
          ),
          const SizedBox(
            height: 10,
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  data: Icons.person,
                  controller: nameController,
                  hintText: "name",
                  isObscure: false,
                ),
                CustomTextField(
                  data: Icons.email,
                  controller: emailController,
                  hintText: "Email",
                  isObscure: false,
                ),
                CustomTextField(
                  data: Icons.lock,
                  controller: passwordController,
                  hintText: "Password",
                ),
                CustomTextField(
                  data: Icons.lock,
                  controller: confirmPasswordController,
                  hintText: " Confirm Password",
                ),
                CustomTextField(
                  data: Icons.phone,
                  controller: phoneController,
                  hintText: "Phone",
                  isObscure: false,
                  TextInputType: TextInputType.number,
                  onSaved: (val) => {
                    _phonenumber = val,
                  },
                ),
                CustomTextField(
                  data: Icons.my_location,
                  controller: locationController,
                  hintText: "Cafe/Residential Address",
                  isObscure: false,
                  // enabled: false,
                ),
                Container(
                  width: 400,
                  height: 40,
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      getCurrentLocation();
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text(
                      "Get my Current Location",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.amber,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: () {
              formValidation();
            },
            child: const Text(
              'Sign Up',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
                primary: Colors.cyan,
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 10)),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
