import 'package:flutter/material.dart';

class StarsRow extends StatefulWidget {
  final double starsCount;
  final bool isDetail;

  StarsRow(this.starsCount,this.isDetail);

  @override
  _StarsRowState createState() => _StarsRowState();
}

class _StarsRowState extends State<StarsRow> {
  List<Widget> stars = [];

  @override
  void initState() {
    super.initState();
    _buildStars();
  }

  void _buildStars() {
    stars.clear();

    for (int i = 0; i < widget.starsCount.floor(); i++) {
      stars.add(Icon(Icons.star_sharp));
    }

    if (widget.starsCount - widget.starsCount.floor() >= 0.5) {
      stars.add(Icon(Icons.star_half_sharp));
    }

    stars.add(Text(widget.starsCount.toString()));
  }

  @override
  Widget build(BuildContext context) {
    if(widget.isDetail){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: stars,
      );
    }
    else return Row(
      children: stars,
    );
  }
}

//sudah tidak dipakai
/*
Widget _buildStars(BuildContext context, Restaurant _items){
  var starsCount = _items.rating;
  List<Widget> stars = [];

  for(int i=0;i<starsCount.floor();i++){
    stars.add(Icon(Icons.star_sharp));
  }

  if(starsCount-starsCount.floor() >= 0.5){
    stars.add(Icon(Icons.star_half_sharp));
  }

  stars.add(Text(starsCount.toString()));

  return Row(
      children: stars
  );
}
*/   //Fungsi asli sebelum diganti

