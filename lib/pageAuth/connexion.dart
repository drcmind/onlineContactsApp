import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:online_contacts/constants/chargement.dart';

class Connexion extends StatefulWidget {

  final Function basculation;
  Connexion({ this.basculation });

  @override
  _ConnexionState createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {

  FirebaseAuth _auth = FirebaseAuth.instance;

  String email = '';
  String motDepass = '';

  bool chargement = false;

  final _keyForm = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return chargement ? Chargement() : Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 30.0),
          child: Form(
            key: _keyForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset('assets/logo.png', height: 100.0, width: 100.0),
                Center(
                  child : Text('Bienvenue sur Online Contacts',
                  style: Theme.of(context).textTheme.title)
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val.isEmpty ? 'Entrez un email' : null,
                  onChanged: (val) => email = val,
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (val) => val.length < 6 ? 'Mot de passe incorrect' : null,
                  onChanged: (val) => motDepass = val,
                ),
                SizedBox(height: 10.0),
                FlatButton(
                  onPressed: () async {
                    if(_keyForm.currentState.validate()){

                      setState(() => chargement = true);

                      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: motDepass);
                      if(result == null){
                        setState(() => chargement = false);
                      }

                    }
                  },
                  color: Colors.amber,
                  child: Text('Connexion'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                OutlineButton(
                  onPressed: (){
                    setState(() {
                      widget.basculation();
                    });
                  },
                  borderSide: BorderSide(width: 1.0, color: Colors.black),
                  child: Text('Besoin d\'un nouveau compte ?'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
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
