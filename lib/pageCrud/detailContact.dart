import 'package:flutter/material.dart';
import 'package:online_contacts/pageCrud/modifierContact.dart';
import 'package:online_contacts/pageCrud/photoView.dart';
import 'package:random_color/random_color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_contacts/constants/chargement.dart';

class DetailContact extends StatefulWidget {

  final String nomContact, postNomContact, numTel, emailContact, urlImage;
  DetailContact ({ this.nomContact, this.postNomContact, this.numTel,
    this.emailContact, this.urlImage});

  @override
  _DetailContactState createState() => _DetailContactState();
}

class _DetailContactState extends State<DetailContact> {

  FirebaseUser currentUser;
  bool chargement = false;

  static RandomColor _randomColor = RandomColor();

  Color _color = _randomColor.randomColor(
      colorBrightness: ColorBrightness.light
  );

  var lettreInitial;

  Widget affichageImage(){
    if(widget.urlImage.length > 0){
      lettreInitial = "";
      return GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => PhotoViewUrl(urlImage: widget.urlImage)
          ));
        },
        child: CircleAvatar(
          radius: 70.0,
          backgroundImage: NetworkImage('${widget.urlImage}'),
        ),
      );
    }else{
      lettreInitial = widget.nomContact[0];
      return CircleAvatar(
        radius: 70.0,
        backgroundColor: _color,
        child: Text(
          lettreInitial,
          style: Theme.of(context).textTheme.display4,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {

    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      setState(() { // call setState to rebuild the view
        this.currentUser = user;
      });
    });

    String _idUtil(){
      if(currentUser != null){
        return currentUser.uid;
      }else{
        return 'pas id';
      }
    }

     void _panneauDeSupression(){
      showModalBottomSheet(context: context, builder: (context){
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: Column(
            children: <Widget>[
              Icon(Icons.ac_unit, color: Colors.red, size: 50.0),
              SizedBox(height: 10.0),
              Text('Voulez-vous supprimer ${widget.nomContact} ${widget.postNomContact}',
              style: Theme.of(context).textTheme.title),
              SizedBox(height: 10.0),
              FlatButton.icon(
                color: Colors.red,
                icon: Icon(Icons.delete, color: Colors.white,),
                label: Text('Supprimer', style: TextStyle(color: Colors.white),),
                onPressed: () async {

                  setState(() {
                    Navigator.pop(context);
                  });

                  setState(() => chargement = true);

                  await Firestore.instance.collection('utilisateurs').document(_idUtil())
                      .collection('contacts').document(widget.numTel).delete();

                  Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.nomContact} ${widget.postNomContact}'
                            'supprimé(e) avec succès'),
                      )
                  );

                  setState(() {
                    Navigator.pop(context);
                  });
                },
              )
            ],
          ),
        );
      });
     }

    _lancerLAppel() async {
      String url = 'tel:${widget.numTel}';
      if(await canLaunch(url)){
        await launch(url);
      }else{
        throw 'Impossible d\'appeller $url';
      }
    }

    _lancerSMS() async {
      String url = 'sms:${widget.numTel}';
      if(await canLaunch(url)){
        await launch(url);
      }else{
        throw 'Impossible de texter $url';
      }
    }

    _lancerGmail() async {
      String url = 'mailto:${widget.emailContact}';
      if(await canLaunch(url)){
        await launch(url);
      }else{
        throw 'Impossible d\'envoyer le mail à $url';
      }
    }

    return chargement ? Chargement() : Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('${widget.nomContact} ${widget.postNomContact}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _panneauDeSupression()),
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 10.0),
          affichageImage(),
          Divider(
            height: 20.0,
            color: Colors.grey[800],
          ),
          Text('${widget.nomContact} ${widget.postNomContact}',
          style: Theme.of(context).textTheme.display1),
          Divider(
            height: 20.0,
            color: Colors.grey[800],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              GestureDetector(
                onTap: _lancerLAppel,
                child: Column(
                  children: <Widget>[
                    Icon(Icons.phone, color : Colors.amber),
                    Text('Appel', style: TextStyle(color: Colors.amber),)
                  ],
                ),
              ),
              GestureDetector(
                onTap: _lancerSMS,
                child: Column(
                  children: <Widget>[
                    Icon(Icons.sms, color : Colors.amber),
                    Text('SMS', style: TextStyle(color: Colors.amber),)
                  ],
                ),
              ),
              GestureDetector(
                onTap: _lancerGmail,
                child: Column(
                  children: <Widget>[
                    Icon(Icons.email, color : Colors.amber),
                    Text('Email', style: TextStyle(color: Colors.amber),)
                  ],
                ),
              )
            ],
          ),
          Divider(
            height: 20.0,
            color: Colors.grey[800],
          ),
          Row(
            children: <Widget>[
              SizedBox(width: 10.0,),
              Icon(Icons.phone),
              SizedBox(width: 10.0,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.numTel,
                    style: Theme.of(context).textTheme.title,
                  ),
                  SizedBox(height: 5.0,),
                  Text(
                    'Mobil',
                    style: Theme.of(context).textTheme.title,
                  ),
                ],
              )
            ],
          ),
          Divider(
            height: 20.0,
            color: Colors.grey[800],
          ),
          Row(
            children: <Widget>[
              SizedBox(width: 10.0,),
              Icon(Icons.mail),
              SizedBox(width: 10.0,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.emailContact,
                    style: Theme.of(context).textTheme.title,
                  ),
                  SizedBox(height: 5.0,),
                  Text(
                    'Email',
                    style: Theme.of(context).textTheme.title,
                  ),
                ],
              )
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => ModifierContact(), settings: RouteSettings(
            arguments: {
              'urlImage' : widget.urlImage,
              'nomContact' : widget.nomContact,
              'postNomContact' : widget.postNomContact,
              'emailContact' : widget.emailContact,
              'numTel' : widget.numTel,
            }
          )
          ));
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}
