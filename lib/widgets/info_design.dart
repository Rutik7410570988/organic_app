import 'package:flutter/material.dart';
import 'package:foodpanda_seller_app/model/menus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';
import '../mainScreens/items_screen.dart';
import '../splashScreen/splash_screen.dart';

class InfoDesignWidget extends StatefulWidget {
  final Menus? model;
  final BuildContext? context;

  const InfoDesignWidget({this.model, this.context, Key? key})
      : super(key: key);

  @override
  _InfoDesignWidgetState createState() => _InfoDesignWidgetState();
}

class _InfoDesignWidgetState extends State<InfoDesignWidget> {
  deleteMenu(String menuID) {
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("uid"))
        .collection("menus")
        .doc(menuID)
        .delete()
        .then((value) {
        FirebaseFirestore.instance.collection("menus").doc(menuID).delete();

        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
        Fluttertoast.showToast(msg: "menu Deleted Successfully.");
      });

    // Fluttertoast.showToast(msg: "Menu Deleted Successfully.");
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ItemsScreen(model: widget.model!)));
      },
      splashColor: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 285,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Divider(
                height: 4,
                thickness: 3,
                color: Colors.grey[300],
              ),
              Image.network(
                widget.model!.thumbnailUrl!,
                height: 200.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(
                height: 1.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.model!.menuTitle!,
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontSize: 20,
                      fontFamily: "Train",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.pinkAccent,
                    ),
                    onPressed: () {
                      //delete menu
                      deleteMenu(widget.model!.menuID!);
                    },
                  ),
                ],
              ),
              // Text(
              //   widget.model?.menuTitle ?? "",
              //   style: const TextStyle(
              //       color: Colors.cyan, fontSize: 20, fontFamily: "Train"),
              // ),
              // Text(
              //   widget.model!.menuInfo!,
              //   style: const TextStyle(
              //     color: Colors.grey,
              //     fontSize: 12,
              //   ),
              // ),
              Divider(
                height: 4,
                thickness: 3,
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
