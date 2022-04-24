import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CoolButton extends StatelessWidget{
  var pressFunc;
  CoolButton(onPressed){
    pressFunc=onPressed;
  }
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          width: 200,
          height: 39,
          child: MaterialButton(
              onPressed: pressFunc,
              minWidth: 200,
              height: 39,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36)),
              color: Color(0xff35258a),
              child: Stack(children: <Widget>[
                const Positioned(
                  top: 5,
                  right: 50,
                  child: const Text("Login",
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      )),
                )
              ]))),
      Positioned(
          top: 5,
          right: 165,
          child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: Colors.white, width: 9),
              ))),
    ]);
  }

}


class SignupButton extends StatelessWidget{
  var pressFunc;
  SignupButton(onPressed){
    pressFunc=onPressed;
  }
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          width: 400,
          height: 39,
          child: MaterialButton(
              onPressed: pressFunc,
              minWidth: 200,
              height: 39,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36)),
              color: Colors.blueAccent,
              child: Stack(children: <Widget>[
                const Positioned(
                  top: 10,
                  right: 20,
                  child: const Text("Not registerd yet? Click here to sign up",
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )),
                )
              ]))),
      Positioned(
          top: 5,
          right: 327,
          child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: Colors.white, width: 9),
              ))),
    ]);
  }

}