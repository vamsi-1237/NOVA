import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text("Welcome to Nova"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: double.infinity,
            height: 400,
            child: Image.network(
              'https://imgs.search.brave.com/YcohkVoWR9yYjrzaV1Tg_oICUUKlB2amLHIrJ5sgdqY/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly90My5m/dGNkbi5uZXQvanBn/LzE4Lzg1LzkxLzQ0/LzM2MF9GXzE4ODU5/MTQ0NDFfb3FnRDBW/ekJpaTNlMlNvWXBn/cjVYbmtjc1MwSnF3/STAuanBn',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: ElevatedButton(
                      onPressed: (){
                        Navigator.pushNamed(context, "/login");
                      },
                      child: Text("Get Started"),
                    )
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: ElevatedButton(
                      onPressed: (){},
                      child: Text("Login with google"),
                    )
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}
