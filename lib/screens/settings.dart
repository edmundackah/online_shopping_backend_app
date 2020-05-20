import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onlineshoppingbackendapp/screens/partials/appbar.dart';
import 'package:onlineshoppingbackendapp/screens/partials/navigation_drawer.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key, @required this.position}): super();

  final int position;

  @override
  _settingsScreenState createState() => _settingsScreenState();
}

class _settingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Settings"),
      body: StreamBuilder(
        stream: Firestore.instance.collection("user_settings")
            .document("qmHWLXV17pvLEWclXcKc").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return SettingsList(
            sections: [
              SettingsSection(
                tiles: [
                  SettingsTile.switchTile(
                    title: 'Sentiment Classifier',
                    subtitle: 'Social media feedback classifier',
                    leading: Icon(Icons.people),
                    switchValue: snapshot.data["sentiment"],
                    onToggle: (bool value) async {
                      updateSettings("sentiment", value);
                    },
                  ),

                  SettingsTile.switchTile(
                    title: 'Image Classifier',
                    subtitle: "Product recognition AI",
                    leading: Icon(Icons.shop),
                    switchValue: snapshot.data["image_rec"],
                    onToggle: (bool value) async {
                      updateSettings("image_rec", value);
                    },
                  ),

                  SettingsTile.switchTile(
                    title: 'Chatbot',
                    subtitle: "Turn Chatbot on/off",
                    leading: Icon(Icons.record_voice_over),
                    switchValue: snapshot.data["chatbot"],
                    onToggle: (bool value) async {
                      updateSettings("chatbot", value);
                    },
                  )
                ],
              ),
            ],
          );
        }
      ),
      drawer: NavDrawer(currentPage: widget.position,),
    );
  }

  void updateSettings(String key, bool value) async {
    final DocumentReference postRef = Firestore.instance.collection("user_settings")
        .document("qmHWLXV17pvLEWclXcKc");

    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(postRef);
      if (postSnapshot.exists) {
        await tx.update(postRef, <String, dynamic>{key: value});
      }
    });
  }

}