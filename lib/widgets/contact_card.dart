import 'dart:io';

import 'package:flutter/material.dart';

import '../helpers/contact_helper.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;

  const ContactCard({
    super.key,
    required this.contact,
  });

  _getImage() {
    dynamic img;

    final File file = File(contact.img!);
    if (file.existsSync()) {
      img = FileImage(file);
    } else {
      img = AssetImage('assets/images/person.png');
    }

    return img;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: _getImage()),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contact.email,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      contact.phone,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
