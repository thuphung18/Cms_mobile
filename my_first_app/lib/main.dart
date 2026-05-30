// bước 1: khai báo thư viện
import 'package:flutter/material.dart';

// bước 2: main
void main() {
  runApp(
    MaterialApp(
      // Bước 4: sử dụng thành phần để xây dựng giao diện người dùng
      home: SafeArea(
        child: Scaffold(
          // khung màn hình
          body: MyWidget(),

          // appBar: AppBar(// khung ở trên
          //   backgroundColor: Colors.red,
          //   title: Text('Tu hoc Flutter'),
          // ),
          // body:const Center(child: Text('hello world')) ,
        ),
      ),
      debugShowCheckedModeBanner: false, // gỡ nhãn debug
    ),
  );
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // if(loading)
    //   {
    //     return const CircularProgressIndicator();
    //   }
    // else{
    //   return Text('State');
    // }
    return const Text(
      'Nếu có bất cứ vấn đề gì về bản quyền, vui lòng liên hệ với tôi'
      ' qua Email. Mọi thứ sẽ được giải quyết sớm nhất.',
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
      style: TextStyle(
        color: Colors.red,
        backgroundColor: Colors.yellow,
        fontSize: 20,
        fontWeight: FontWeight(400),
        fontStyle: FontStyle.italic,
        fontFamily: 'Times New Roman',

        // wordSpacing: 10,
        // letterSpacing: 6,
      ),
    );
  }
}
