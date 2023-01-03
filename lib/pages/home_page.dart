import 'package:flutter/material.dart';
import 'package:phonebook_flutter/helpers/contact_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  @override
  void initState() {
    super.initState();
    Contact c = Contact();
    c.name = 'Marcos';
    c.email = 'marcos.filho@antt.gov.br';
    c.phone = '993048292';
    c.img = 'image_test';

    helper.saveContact(c).then((c) => print(c.name));
    helper.getNumber().then((v) => print(v));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
