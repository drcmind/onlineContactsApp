import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:online_contacts/constants/chargement.dart';

class ModifierContact extends StatefulWidget {
  @override
  _ModifierContactState createState() => _ModifierContactState();
}

class _ModifierContactState extends State<ModifierContact> {

  Map donnEs = {};
  File _fichierSelectionE;
  bool _enProcessus = false;
  bool chargement = false;

  final _keyForm = GlobalKey<FormState>();
  final CollectionReference collectionUtil = Firestore.instance.collection('utilisateurs');
  FirebaseUser currentUser;

  @override
  Widget build(BuildContext context) {

    donnEs = ModalRoute.of(context).settings.arguments;

    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      setState(() { // call setState to rebuild the view
        this.currentUser = user;
      });
    });

    String _idUtil() {
      if (currentUser != null) {
        return currentUser.uid;
      } else {
        return "no current user";
      }
    }

    String nomContact = donnEs['nomContact'];
    String postNomContact = donnEs['postNomContact'];
    String emailContact = donnEs['emailContact'];
    String numTel = donnEs['numTel'];
    String urlImage = donnEs['urlImage'];

    var inialLetter = nomContact[0];
    if(urlImage.length > 0){
      inialLetter = "";
    }
    enregistrerContact() async {
      setState(() => chargement = true);

      if ((urlImage == '') & (_fichierSelectionE == null)) {

        await collectionUtil.document(_idUtil()).collection('contacts').document(numTel).setData({
          'urlImage' : '',
          'nomContact' : nomContact,
          'postNomContact' : postNomContact,
          'emailContact' : emailContact,
          'numTel' : numTel,
        });

        this.setState((){
          Navigator.pop(context);
        });

      } else {

        StorageReference reference =
        FirebaseStorage.instance.ref().child("$nomContact+ $numTel.png");
        StorageUploadTask uploadTask = reference.putFile(_fichierSelectionE);
        StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
        urlImage = await taskSnapshot.ref.getDownloadURL();

        await collectionUtil.document(_idUtil()).collection('contacts').document(numTel).setData({
          'urlImage' : urlImage,
          'nomContact' : nomContact,
          'postNomContact' : postNomContact,
          'emailContact' : emailContact,
          'numTel' : numTel,
        });

        this.setState((){
          Navigator.pop(context);
        });

      }
    }

    obtenirImage(ImageSource source) async {

      setState(() {
        _enProcessus = true;
      });

      File image = await ImagePicker.pickImage(source: source);
      if (image != null) {
        File croppE = await ImageCropper.cropImage(
            sourcePath: image.path,
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            compressQuality: 100,
            maxHeight: 700,
            maxWidth: 700,
            compressFormat: ImageCompressFormat.jpg,
            androidUiSettings: AndroidUiSettings(
              toolbarColor: Colors.amber,
              toolbarTitle: 'Rognez l\'image',
              statusBarColor: Colors.amber.shade900,
              backgroundColor: Colors.black,
            ));

        this.setState(() {
          _fichierSelectionE = croppE;
          _enProcessus = false;
        });
      } else {
        this.setState(() {
          _enProcessus = false;
        });
      }
    }

    return chargement ? Chargement() :  Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Modifier contact'),
          actions: <Widget>[
            RaisedButton(
              onPressed: () async {
                if (_keyForm.currentState.validate()) {
                  enregistrerContact();
                }
              },
              color : Colors.black,
              child: Text(
                'Modifier',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 30.0),
                child: Form(
                  key: _keyForm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              obtenirImage(ImageSource.gallery);
                            },
                            child: CircleAvatar(
                              radius: 40.0,
                              backgroundColor: Colors.amberAccent,
                              backgroundImage: _fichierSelectionE != null
                                  ? FileImage(_fichierSelectionE)
                                  : NetworkImage(urlImage),
                              child: Text(
                                inialLetter,
                                style: Theme.of(context).textTheme.display1,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              obtenirImage(ImageSource.camera);
                            },
                            icon: Icon(Icons.camera, color: Colors.amber,),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        initialValue: nomContact,
                        decoration: InputDecoration(
                            border: OutlineInputBorder()),
                        validator: (val) =>
                        val.isEmpty ? 'Entrez un nom' : null,
                        onChanged: (val) => setState(() => nomContact = val),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        initialValue: postNomContact,
                        decoration: InputDecoration(
                            border: OutlineInputBorder()),
                        validator: (val) =>
                        val.isEmpty ? 'Entrez un postNom' : null,
                        onChanged: (val) => setState(() => postNomContact = val),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        initialValue: emailContact,
                        decoration: InputDecoration(
                            border: OutlineInputBorder()),
                        onChanged: (val) => setState(() => emailContact = val),
                        validator: (val) =>
                        val.isEmpty ? 'Entrez un email' : null,
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        initialValue: numTel,
                        decoration: InputDecoration(
                            border: OutlineInputBorder()),
                        onChanged: (val) => setState(() => numTel = val),
                        validator: (val) => val.isEmpty
                            ? 'Entrez un numero de téléphone'
                            : null,
                      ),

                    ],
                  ),
                ),
              ),
            ),
            (_enProcessus)
                ? Container(
              height: MediaQuery.of(context).size.height * 0.95,
              child: Center(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            )
                : Container()
          ],
        )
    );
  }
}
