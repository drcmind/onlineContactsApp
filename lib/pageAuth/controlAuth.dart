import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_contacts/constants/chargement.dart';
import 'package:online_contacts/pageAuth/liaisonAuth.dart';
import 'package:online_contacts/pageCrud/accueil.dart';
import 'package:provider/provider.dart';

class Utilisateur {
  String idUtil;

  Utilisateur({ this.idUtil });
}

class DonneesUtil {

  String email;
  String nomComplet;

  DonneesUtil({ this.email, this.nomComplet });
}

class StreamProviderAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //creation d'un obj utilisateur provenant de la classe firebaseUser
  Utilisateur _utilisateurDeFirebaseUser(FirebaseUser user){
    return user != null ? Utilisateur(idUtil: user.uid) : null;
  }

  //la difussion de l'auth de l'utilisateur

  Stream<Utilisateur> get utilisateur {
      return _auth.onAuthStateChanged.map(_utilisateurDeFirebaseUser);
  }
}

class Passerelle extends StatefulWidget {
  @override
  _PasserelleState createState() => _PasserelleState();
}

class _PasserelleState extends State<Passerelle> {
  @override
  Widget build(BuildContext context) {
    final utilisateur = Provider.of<Utilisateur>(context);

    if (utilisateur == null) {
      return LiaisonPageAuth();
    } else {
      return Accueil();
    }
  }
}

class GetCurrentUserData {
  String idUtil;
  GetCurrentUserData({ this.idUtil });

  //la reference de la collection utilisateur
  final CollectionReference collectionUtil = Firestore.instance.collection('utilisateurs');

  DonneesUtil _donneesUtilDeSnapshot(DocumentSnapshot snapshot){
    return DonneesUtil(
      nomComplet: snapshot['nomComplet'],
      email: snapshot['emailUtil'],
    );
  }

  //obtention doc util en Stream
Stream<DonneesUtil> get donneesUtil {
    return collectionUtil.document(idUtil).snapshots()
        .map(_donneesUtilDeSnapshot);
}

}
