import 'package:flutter/material.dart';

//TODO: Add card for online sentiment
enum CardType {
  ToDo,
  Requests,
  Orders,
  Users,

}

class CardItemModel {

  String cardTitle;
  IconData icon;
  int tasksRemaining;
  double taskCompletion;

  CardItemModel(this.cardTitle, this.icon, this.tasksRemaining, this.taskCompletion);

}