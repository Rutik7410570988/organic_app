import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:foodpanda_seller_app/global/global.dart';
import 'package:foodpanda_seller_app/mainScreens/home_screen.dart';
import 'package:foodpanda_seller_app/widgets/progress_bar.dart';
import 'package:image_picker/image_picker.dart';

import '../model/menus.dart';
import '../widgets/error_dialog.dart';

class ItemsUploadScreen extends StatefulWidget {
  final Menus model;
  const ItemsUploadScreen({required this.model, Key? key}) : super(key: key);

  @override
  _ItemsUploadScreenState createState() => _ItemsUploadScreenState();
}

class _ItemsUploadScreenState extends State<ItemsUploadScreen> {
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();
  TextEditingController shortInfoController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  bool uploading = false;
  String uniqueIdName = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void dispose() {
    // TODO: implement dispose
    shortInfoController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return imageXFile == null ? defaultScreen() : itemsUploadFormScreen();
  }

  defaultScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New Items",
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
                  "Add New Item",
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
                "Items Image",
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
      descriptionController.clear();
      priceController.clear();
    });
  }

  itemsUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Uploading New Items",
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
          // ListTile(
          //   leading: const Icon(
          //     Icons.perm_device_information,
          //     color: Colors.cyan,
          //   ),
          //   title: SizedBox(
          //     width: 250,
          //     child: TextField(
          //       style: const TextStyle(color: Colors.black),
          //       controller: shortInfoController,
          //       decoration: const InputDecoration(
          //           hintText: "info",
          //           hintStyle: TextStyle(color: Colors.grey),
          //           border: InputBorder.none),
          //     ),
          //   ),
          // ),
          // const Divider(
          //   color: Colors.amber,
          //   thickness: 1,
          // ),
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
                    hintText: "title",
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
              Icons.description,
              color: Colors.cyan,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: descriptionController,
                decoration: const InputDecoration(
                    hintText: "description",
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
              Icons.currency_rupee_sharp,
              color: Colors.cyan,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    hintText: "price",
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
              Icons.production_quantity_limits,
              color: Colors.cyan,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: shortInfoController,
                decoration: const InputDecoration(
                    hintText: "Quantity",
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
          titleController.text.isNotEmpty &&
          descriptionController.text.isNotEmpty &&
          priceController.text.isNotEmpty) {
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
                  message: "Please write a title or info for Menu");
            });
      }
    } else {
      showDialog(
          context: context,
          builder: (builder) {
            return const ErrorDialog(message: "Please pick an image for Menu");
          });
    }
  }

  uploadImage(XFile imageXFile) async {
    File fileImage = File(imageXFile.path);
    Reference ref = FirebaseStorage.instance.ref().child("items");
    UploadTask uploadTask = ref.child("$uniqueIdName.jpg").putFile(fileImage);

    TaskSnapshot taskSnapshot = await uploadTask;

    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  void saveInfo(String downloadUrl) {
    final ref = FirebaseFirestore.instance
        .collection("sellers")
        .doc(firebaseAuth.currentUser?.uid)
        .collection("menus")
        .doc(widget.model.menuID)
        .collection("items");

    ref.doc(uniqueIdName).set({
      "itemID": uniqueIdName,
      "menuID": widget.model.menuID,
      "sellerUID": sharedPreferences!.getString("uid"),
      "sellerName": sharedPreferences!.getString("name"),
      "title": titleController.text.toString(),
      "shortInfo": shortInfoController.text.toString(),
      "longDescription": descriptionController.text.toString(),
      "price": int.parse(priceController.text),
      "publishedDate": DateTime.now(),
      "status": "available",
      "thumbnailUrl": downloadUrl
    }).then((value) {
      final itemsRef = FirebaseFirestore.instance.collection("items");

      itemsRef.doc(uniqueIdName).set({
        "itemID": uniqueIdName,
        "menuID": widget.model.menuID,
        "sellerUID": sharedPreferences!.getString("uid"),
        "sellerName": sharedPreferences!.getString("name"),
        "title": titleController.text.toString(),
        "shortInfo": shortInfoController.text.toString(),
        "longDescription": descriptionController.text.toString(),
        "price": int.parse(priceController.text),
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
