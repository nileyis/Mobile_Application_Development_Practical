
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  File? _image;
  final _picker = ImagePicker();

  Future<void> _loadProfile()async{
    final prefs = await SharedPreferences.getInstance();
    _nameCtrl.text = prefs.getString('name')?? "";
    _emailCtrl.text = prefs.getString('email') ?? "";
  }

  Future<void> _updateProfile() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', _nameCtrl.text);
    prefs.setString('email', _emailCtrl.text);
  }

  Future<void> getImageFromGallery() async{
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if(pickedFile != null){
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }


  Future<void> savePicture() async{

    if(_image != null){
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final newImagePath = '${appDocDir.path}/profile.png';
        await _image!.copy(newImagePath);
        print('File image copied successfully to $newImagePath');
      }catch(e){
        print('File error copying image: $e');
      }
    }else{
      AlertDialog(
          title: const Text('Profile Image'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Profile Image'),
                Text('Profile Image file is missing.')
              ],
            ),
          )
      );
    }
  }

  Future<void> loadProfileImage() async{
    final appDocDir = await getApplicationDocumentsDirectory();
    final imagePath = '${appDocDir.path}/profile.png';

    final file = File(imagePath);

    if(await file.exists()){
      setState(() {
        _image = file;
        print('File path: $imagePath');
      });
    }else{
      print('File not found in $imagePath');
    }
  }

  @override
  void initState() {
    _loadProfile();
    super.initState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: .center,
          children: [
            _image == null
                ? Icon(Icons.person,size: 150)
                : Image.file(
              _image!,
              width: 150,
              height: 150,
            ),

            const SizedBox(height: 8.0,),

            IconButton(
              onPressed: (){
                getImageFromGallery();
              },
              icon : Icon(Icons.edit),
            ),

            ElevatedButton(
              onPressed:(){
                savePicture();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(content: Text('Picture saved')),
                );
              },
              child: const Text('Save Picture'),
            ),

            TextField(
              controller: _nameCtrl,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),


            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),


            ElevatedButton(
                onPressed: (){
                  _updateProfile();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated!'),
                    ),
                  );
                },
                child: const Text('Save')
            ),
          ],
        ),
      ),
    );
  }
}
