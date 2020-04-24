import 'package:flutter/material.dart';
class CustomButton extends StatelessWidget {
  final VoidCallback callback;
  final String text;
  final IconData icon;

  CustomButton(this.text, this.callback,this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Material(
        borderRadius: BorderRadius.circular(30),
        elevation: 6,
        color: Theme.of(context).primaryColor,
        child: MaterialButton(
          onPressed: callback,
          child: Row(
            children: <Widget>[
              Icon(icon),
              Container(
                width: 20,
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          minWidth: 400,
          height: 45,
        ),
      ),
    );
  }
}
