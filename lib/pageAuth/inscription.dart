import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_contacts/constants/chargement.dart';

class Inscription extends StatefulWidget {

  final Function basculation;
  Inscription({ this.basculation });

  @override
  _InscriptionState createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser courentUtil;

  //Collection Utilisateur depuis firestore
  final CollectionReference collectionUtil = Firestore.instance.collection('utilisateurs');

  String nomComplet = '';
  String email = '';
  String motDePass = '';
  String confimMdP = '';

  bool chargement = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    FirebaseAuth.instance.currentUser().then((FirebaseUser util){
      setState(() {
        this.courentUtil = util;
      });
    });

    String _idUtil(){
      if(courentUtil != null){
        return courentUtil.uid;
      }else{
        return "pas d'utilisateur courant";
      }
    }

    return chargement ? Chargement() : Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset('assets/logo.png', height: 100.0, width: 100.0),
                Center(
                  child: Text('Créer un compte Online Contacts',
                  style: Theme.of(context).textTheme.title),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    border: OutlineInputBorder()
                  ),
                  validator: (val) => val.isEmpty ? 'Entrez un nom' : null,
                  onChanged: (val) => nomComplet = val,
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder()
                  ),
                  validator: (val) => val.isEmpty ? 'Entrez un email' : null,
                  onChanged: (val) => email = val,
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      border: OutlineInputBorder()
                  ),
                  validator: (val) => val.length < 6 ? 'Entrez un mot de passe avec 6 ou plus'
                      'des caracteres' : null,
                  onChanged: (val) => motDePass = val,
                  obscureText: true,
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Confirmez le mot de passe',
                      border: OutlineInputBorder()
                  ),
                  onChanged: (val) => confimMdP = val,
                  validator: (val) => confimMdP != motDePass ? 'Mot de passe ne correspond pas' : null,
                  obscureText: true,
                ),
                FlatButton(
                  onPressed: () async {
                    if(_formKey.currentState.validate()){

                      setState(() => chargement = true);
                      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: motDePass);

                      await collectionUtil.document(_idUtil()).setData({
                        'idUtil' : _idUtil(),
                        'nomComplet' :  nomComplet,
                        'emailUtil' : email
                      });

                      if(result == null){
                        setState(() => chargement = true);
                      }
                    }
                  },
                  color: Colors.amber,
                  child: Text('S\'inscrire'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                ),
                OutlineButton(
                  onPressed: (){
                     setState(() {
                       widget.basculation();
                     });
                  },
                  borderSide: BorderSide(width: 1.0, color: Colors.black),
                  child: Text('Avez-vous déjà un compte ?'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
