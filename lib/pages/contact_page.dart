import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phonebook_flutter/helpers/contact_helper.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;
  const ContactPage({super.key, this.contact});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final ImagePicker _picker = ImagePicker();
  late final Contact _editedContact;
  bool _userEdited = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // duplicate received contact or create a new one if null
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      // a contact was passed prepare a copy for edition
      _editedContact = Contact.fromMap(widget.contact!.toMap());
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  _getImage() {
    dynamic img;

    if (_editedContact.img != null) {
      final File file = File(_editedContact.img!);
      if (file.existsSync()) {
        return img = FileImage(file);
      }
    }
    img = AssetImage('assets/images/person.png');

    return img;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            _editedContact.id != null ? _editedContact.name : 'Novo contato',
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  _picker.pickImage(source: ImageSource.camera).then(
                    (file) {
                      if (file == null) return;
                      setState(() => _editedContact.img = file.path);
                    },
                  );
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _getImage(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: 'Nome'),
                onChanged: (text) {
                  setState(() {
                    _userEdited = true;
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.email = text;
                },
              ),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Telefone'),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.phone = text;
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            try {
              if (_editedContact.name.isNotEmpty) {
                Navigator.of(context).pop(_editedContact);
              } else {
                _nameFocus.requestFocus();
              }
            } catch (_) {
              _nameFocus.requestFocus();
            }
          },
          child: Icon(Icons.save),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Descartar alterações?'),
          content: Text('Se confirmar as alterações serão perdidas.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Sim')),
          ],
        ),
      );
      return Future.value(false);
    } else {
      // Record not edited, leave de page immediately
      return Future.value(true);
    }
  }
}
