import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:foodpanda_seller_app/global/global.dart';
import 'package:foodpanda_seller_app/mainScreens/home_screen.dart';
import 'package:foodpanda_seller_app/widgets/progress_bar.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/error_dialog.dart';

class MenuUploadScreen extends StatefulWidget {
  const MenuUploadScreen({Key? key}) : super(key: key);

  @override
  _MenuUploadScreenState createState() => _MenuUploadScreenState();
}

class _MenuUploadScreenState extends State<MenuUploadScreen> {
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController shortInfoController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  bool uploading = false;
  String uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
  @override
  Widget build(BuildContext context) {
    return imageXFile == null ? defaultScreen() : menusUploadFormScreen();
  }

  defaultScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New Products",
          style: TextStyle(fontSize: 30, fontFamily: "Lobster"),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.cyan, Colors.amber],
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(1.0, 1.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp)),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (builder) => const HomeScreen()));
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.cyan, Colors.amber],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shop_two,
                color: Colors.white,
                size: 200.0,
              ),
              ElevatedButton(
                onPressed: () {
                  takeImage(context);
                },
                child: const Text(
                  "Add New Products",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.amber),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)))),
              )
            ],
          ),
        ),
      ),
    );
  }

  takeImage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: const Text(
                "Product Image",
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
                  onPressed: pickImageFromGallery,
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

  void captureImageWithCamera() async {
    Navigator.pop(context);
    imageXFile = await _picker.pickImage(
        source: ImageSource.camera, maxHeight: 720, maxWidth: 1280);
    setState(() {
      imageXFile;
    });
  }

  void pickImageFromGallery() async {
    Navigator.pop(context);
    imageXFile = await _picker.pickImage(
        source: ImageSource.gallery, maxHeight: 720, maxWidth: 1280);
    setState(() {
      imageXFile;
    });
  }

  clearMenusUploadForm() {
    imageXFile = null;
    setState(() {
      imageXFile;
      shortInfoController.clear();
      titleController.clear();
      Navigator.push(
          context, MaterialPageRoute(builder: (builder) => const HomeScreen()));
    });
  }

  menusUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Uploading New Product",
          style: TextStyle(fontSize: 20, fontFamily: "Lobster"),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.cyan, Colors.amber],
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(1.0, 1.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp)),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            clearMenusUploadForm();
          },
        ),
        actions: [
          TextButton(
              onPressed: uploading ? null : () => validateUploadForm(),
              child: const Text(
                "Add",
                style: TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: "Varela",
                    letterSpacing: 3),
              ))
        ],
      ),
      body: ListView(
        children: [
          uploading ? linearProgress() : Container(),
          SizedBox(
              height: 250,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(File(imageXFile!.path)),
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
              )),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.perm_device_information,
              color: Colors.cyan,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: shortInfoController,
                decoration: const InputDecoration(
                    hintText: "Product info",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none),
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.title,
              color: Colors.cyan,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: titleController,
                decoration: const InputDecoration(
                    hintText: "Product title",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none),
              ),
            ),
          ),
          const Divider(
            color: Colors.amber,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  void validateUploadForm() async {
    if (imageXFile != null) {
      if (shortInfoController.text.isNotEmpty &&
          titleController.text.isNotEmpty) {
        setState(() {
          uploading = true;
        });
        // upload Image
        String downloadUrl = await uploadImage(imageXFile!);

        // save to Firestore
        saveInfo(downloadUrl);
      } else {
        showDialog(
            context: context,
            builder: (builder) {
              return const ErrorDialog(
                  message: "Please write a title or info for Product");
            });
      }
    } else {
      showDialog(
          context: context,
          builder: (builder) {
            return const ErrorDialog(
                message: "Please pick an image for Product");
          });
    }
  }

  uploadImage(XFile imageXFile) async {
    File fileImage = File(imageXFile.path);
    Reference ref = FirebaseStorage.instance.ref().child("menus");
    UploadTask uploadTask = ref.child("$uniqueIdName.jpg").putFile(fileImage);

    TaskSnapshot taskSnapshot = await uploadTask;

    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  void saveInfo(String downloadUrl) {
    final ref = FirebaseFirestore.instance
        .collection("sellers")
        .doc(firebaseAuth.currentUser?.uid)
        .collection("menus");

    ref.doc(uniqueIdName).set({
      "menuID": uniqueIdName,
      "sellerUID": sharedPreferences!.getString("uid"),
      "menuTitle": titleController.text.toString(),
      "menuInfo": shortInfoController.text.toString(),
      "publishedDate": DateTime.now(),
      "status": "available",
      "thumbnailUrl": downloadUrl
    }).then((value) {
      final menuRef = FirebaseFirestore.instance.collection("menus");

      menuRef.doc(uniqueIdName).set({
        "menuID": uniqueIdName,
        "sellerUID": sharedPreferences!.getString("uid"),
        "menuTitle": titleController.text.toString(),
        "menuInfo": shortInfoController.text.toString(),
        "publishedDate": DateTime.now(),
        "status": "available",
        "thumbnailUrl": downloadUrl
      });
      clearMenusUploadForm();

      setState(() {
        uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();
        uploading = false;
      });
    });
  }
}
