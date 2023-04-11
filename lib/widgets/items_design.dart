import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global/global.dart';
import '../mainScreens/item_detail_screen.dart';
import '../model/items.dart';
import '../model/menus.dart';

class ItemsDesignWidget extends StatefulWidget {
  final Items? model;
  final BuildContext? context;

  const ItemsDesignWidget({this.model, this.context, Key? key})
      : super(key: key);

  @override
  _ItemsDesignWidgetState createState() => _ItemsDesignWidgetState();
}

class _ItemsDesignWidgetState extends State<ItemsDesignWidget> {
  deleteMenu(String itemId) {
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("uid"))
        .collection("menus")
        .doc(widget.model!.menuID)
        .collection("items")
        .doc(itemId)
        .delete();

    Fluttertoast.showToast(msg: "items Deleted Successfully.");
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ItemDetailsScreen(model: widget.model!)));
      },
      splashColor: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 350,
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
                height: 210.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(
                height: 1.0,
              ),
              Text(
                widget.model?.title ?? "",
                style: const TextStyle(
                    color: Colors.cyan, fontSize: 20, fontFamily: "Train"),
              ),
              // Text(
              //   widget.model!.shortInfo!,
              //   style: const TextStyle(
              //     color: Colors.grey,
              //     fontSize: 12,
              //   ),
              // ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.pinkAccent,
                ),
                onPressed: () {
                  // delete menu
                  deleteMenu(widget.model!.menuID!);
                },
              ),
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
