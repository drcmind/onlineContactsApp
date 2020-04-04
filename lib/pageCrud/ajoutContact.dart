import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:online_contacts/constants/chargement.dart';

class AjoutContact extends StatefulWidget {
  @override
  _AjoutContactState createState() => _AjoutContactState();
}

class _AjoutContactState extends State<AjoutContact> {

  String nomContact = '';
  String postNomCont = '';
  String emailContact = '';
  String numTelContact = '';
  String urlImage = '';

  File _fichierSelectionE;
  bool _enProcessus = false;
  bool chargement = false;

  final _formKey = GlobalKey<FormState>();

  // la reference de la collection utilisateur
  final CollectionReference collectionUtil = Firestore.instance.collection('utilisateurs');

  FirebaseUser currentUser;

  @override
  Widget build(BuildContext context) {

    FirebaseAuth.instance.currentUser().then((FirebaseUser user){
      setState(() {
        this.currentUser = user;
      });
    });

    String _idUtil(){
      if(currentUser != null){
        return currentUser.uid;
      }else{
        return "pas id";
      }
    }

    obtenirImage(ImageSource source) async {

      setState(() {
        _enProcessus = true;
      });

      File image = await ImagePicker.pickImage(source: source);
      if(image != null){
        File croppE = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          compressFormat: ImageCompressFormat.png,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.white,
            toolbarTitle: 'Rognez l\'image',
            statusBarColor: Colors.amber,
            backgroundColor: Colors.black,
          ));
        this.setState((){
          _fichierSelectionE = croppE;
          _enProcessus = false;
        });
      }else{
        this.setState((){
          _enProcessus = false;
        });
      }
    }

    enregistrerContact() async {
      setState(() => chargement = true);

      if(_fichierSelectionE == null) {
        await collectionUtil.document(_idUtil()).collection('contacts')
            .document(numTelContact).setData({
          'urlImage' : '',
          'nomContact' : nomContact,
          'postNomContact' : postNomCont,
          'emailContact' : emailContact,
          'numTel' : numTelContact,
        });
        this.setState((){
          Navigator.pop(context);
        });
      }else{

        //Enreigistrement avec l'image
        StorageReference reference =
        FirebaseStorage.instance.ref().child('$nomContact$numTelContact.png');
        StorageUploadTask uploadTask = reference.putFile(_fichierSelectionE);
        StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
        this.urlImage = await taskSnapshot.ref.getDownloadURL();

        await collectionUtil.document(_idUtil()).collection('contacts')
            .document(numTelContact).setData({
          'urlImage' : urlImage,
          'nomContact' : nomContact,
          'postNomContact' : postNomCont,
          'emailContact' : emailContact,
          'numTel' : numTelContact,
        });
        this.setState((){
          Navigator.pop(context);
        });

      }
    }
    return chargement ? Chargement() : Scaffold(
      appBar: AppBar(
        title: Text('Nouveau contact'),
        backgroundColor: Colors.white,
        actions: <Widget>[
          RaisedButton(
            onPressed: (){
              if(_formKey.currentState.validate()){
                enregistrerContact();
              }
            },
            color : Colors.black,
            child: Text('Enregistrer',
                style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            obtenirImage(ImageSource.gallery);
                          },
                          child: CircleAvatar(
                            radius: 40.0,
                            backgroundImage: _fichierSelectionE != null ?
                            FileImage(_fichierSelectionE) : AssetImage('assets/customer.png'),
                          ),
                        ),
                        IconButton(
                          onPressed: (){
                            obtenirImage(ImageSource.camera);
                          },
                          icon: Icon(Icons.camera, color: Colors.amber),
                        ),

                      ],
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Nom du contact',
                          border: OutlineInputBorder()
                      ),
                      validator: (val) => val.isEmpty ? 'Entrez un nom' : null,
                      onChanged: (val) => nomContact = val,
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Post-nom',
                          border: OutlineInputBorder()
                      ),
                      validator: (val) => val.isEmpty ? 'Entrez un post-nom' : null,
                      onChanged: (val) => postNomCont = val,
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder()
                      ),
                      validator: (val) => val.isEmpty ? 'Entrez un email' : null,
                      onChanged: (val) => emailContact = val,
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Numero de tél',
                          border: OutlineInputBorder()
                      ),
                      validator: (val) => val.isEmpty ? 'Entrez un numèro de tél' : null,
                      onChanged: (val) => numTelContact = val,
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
              ): Container()
        ],
      ),
    );
  }
}
