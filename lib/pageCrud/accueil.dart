import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:online_contacts/pageAuth/controlAuth.dart';
import 'package:online_contacts/pageCrud/ajoutContact.dart';
import 'package:online_contacts/pageCrud/detailContact.dart';
import 'package:provider/provider.dart';
import 'package:random_color/random_color.dart';

class Accueil extends StatefulWidget {
  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {

  String nomUtil, emailUtil;

  Widget _boiteDeDialogue(BuildContext, String nom, String email){

    return SimpleDialog(
      contentPadding: EdgeInsets.zero,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text('$nom',
              style: Theme.of(context).textTheme.title),
              Text('$email',
                  style: Theme.of(context).textTheme.subtitle),
              SizedBox(height: 10.0),
              Wrap(
                children: <Widget>[
                  FlatButton(
                    child: Text('DECONNEXION'),
                    color: Colors.amber,
                    onPressed: () async {
                      FirebaseAuth _auth = FirebaseAuth.instance;
                      await _auth.signOut();
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                  ),
                  FlatButton(
                    child: Text('ANNULER'),
                  onPressed: (){
                      setState(() {
                        Navigator.pop(context);
                      });
                  })
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    final utilisateur = Provider.of<Utilisateur>(context);

    GetCurrentUserData(idUtil: utilisateur.idUtil).donneesUtil.forEach((snapshot){
      this.nomUtil = snapshot.nomComplet;
      this.emailUtil = snapshot.email;
    });

    Widget _buildListItem(DocumentSnapshot document){

      var lettreInitial;

      Widget affichageImage(){

        RandomColor _randomColor = RandomColor();

        Color _color = _randomColor.randomColor(
            colorBrightness: ColorBrightness.light
        );

        if(document['urlImage'].length > 0){
          lettreInitial = "";
          return CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage('${document['urlImage']}'),
          );
        }else{
          lettreInitial = document['nomContact'][0];
          return CircleAvatar(
            backgroundColor: _color,
            child: Text(lettreInitial, style: Theme.of(context).textTheme.display1),
          );
        }
      }

      return Dismissible(
        key: Key(UniqueKey().toString()),
        onDismissed: (direction){

          Firestore.instance.collection('utilisateurs')
              .document(utilisateur.idUtil).collection('contacts')
              .document(document['numTel']).delete();

          Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${document['nomContact']}'
                    ' ${document['postNomContact']} supprimé(e) avec succès'),
              )
          );
        },

        background: Container(
          color: Colors.red,
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.white),
            trailing: Icon(Icons.delete, color: Colors.white),
          ),
        ),

        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 32.0),
          child: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => DetailContact(
                    nomContact : document['nomContact'],
                    postNomContact : document['postNomContact'],
                    numTel : document['numTel'],
                    emailContact : document['emailContact'],
                    urlImage : document['urlImage']
                  )
                ));
              },
              leading: affichageImage(),
              title: Text('${document['nomContact']} ${document['postNomContact']}',
              style: Theme.of(context).textTheme.title),
            ),
          ),
        ),
      );
    }

    RandomColor _randomColor = RandomColor();

    Color _color = _randomColor.randomColor(
        colorBrightness: ColorBrightness.light
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Online Contacts'),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
            ),
            onPressed: (){},
          ),
          IconButton(
            icon: Icon(
              Icons.person,
            ),
            onPressed: () => showDialog(context: context, builder: (context)
            => _boiteDeDialogue(context, nomUtil, emailUtil)),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration : BoxDecoration(
                color: Colors.amberAccent,
              ),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: _color,
                    child: nomUtil != null ? Text(
                      '${nomUtil[0]}',
                      style: Theme.of(context).textTheme.display3,
                    ) : null,
                  ),
                  SizedBox(height: 10.0),
                  Text('$nomUtil', style: Theme.of(context).textTheme.title),
                  SizedBox(height: 10.0),
                  Text('$emailUtil', style: Theme.of(context).textTheme.subtitle)
                ],
              ),
            ),
            ListTile(
              onTap: (){
                setState(() {
                  Navigator.pop(context);
                });
              },
              leading: Icon(Icons.person),
              title: Text('Mes contacts',
              style: Theme.of(context).textTheme.title),
              trailing: Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: EdgeInsets.all(8.0),
                child: Text('10',
                  style: TextStyle(color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                try{
                  final PhoneContact contact = await FlutterContactPicker.pickPhoneContact();
                  print(contact);
                  setState(() {
                    PhoneContact _phoneContact = contact;
                  });
                }catch (error){
                  print(error);
                }
              },
              leading: Icon(Icons.person_add),
              title: Text('Importer un contact',
              style: Theme.of(context).textTheme.title),
            ),
            Divider(
              height: 20.0,
              color: Colors.grey[800],
            ),
            ListTile(
              onTap: (){},
              leading: Icon(Icons.settings),
              title: Text('Paramètres',
                  style: Theme.of(context).textTheme.title),
            ),
            ListTile(
              onTap: (){},
              leading: Icon(Icons.help),
              title: Text('Aide et commentaire',
                  style: Theme.of(context).textTheme.title),
            )
          ],
        ),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('utilisateurs').document(utilisateur.idUtil)
            .collection('contacts').orderBy('nomContact').snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData) return Center(
            child: Text('chargement..',
              style: Theme.of(context).textTheme.title),
          );
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) =>
            _buildListItem(snapshot.data.documents[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
        ),
        onPressed: (){
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AjoutContact()));
        },
      ),
    );
  }
}
