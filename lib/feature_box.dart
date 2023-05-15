
import 'package:chatgpt_voice_assistant/pallete.dart';
import 'package:flutter/material.dart';

class FeatureBox extends StatelessWidget {
  final Color color;
  final String headerTitle;
  final String headerDesc;
  const FeatureBox({Key? key, required this.color, required this.headerTitle, required this.headerDesc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 35,vertical: 10),
      decoration: BoxDecoration(color: color,borderRadius: BorderRadius.circular(15 )),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20).copyWith(left: 15),
        child: Column(children: [
          Align(alignment:Alignment.centerLeft,child: Text(headerTitle,style: const TextStyle(fontFamily: 'Cera',fontWeight: FontWeight.bold,fontSize: 18,color: Pallete.blackColor ),)),
          const SizedBox(height: 3,),
          Text(headerDesc,style: const TextStyle(fontFamily: 'Cera',fontWeight: FontWeight.normal,fontSize: 12,color: Pallete.blackColor ),)
        ],),
      ),
    );
  }
}
