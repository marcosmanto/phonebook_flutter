import 'package:flutter/material.dart';
import 'package:phonebook_flutter/helpers/contact_helper.dart';
import 'package:phonebook_flutter/pages/contact_page.dart';
import 'package:phonebook_flutter/widgets/contact_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ContactHelper helper = ContactHelper();

  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Contatos'),
        actions: [],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: contacts.length,
        itemBuilder: (context, index) => ContactCard(
          contact: contacts[index],
          onClick: _showOptions,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactPage(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showOptions([Contact? contact]) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 180,
          decoration: BoxDecoration(
            color: Color.fromARGB(226, 255, 255, 255),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  launchUrlString('tel:${contact?.phone}');
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Ligar',
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showContactPage(contact);
                },
                child: Text(
                  'Editar',
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  helper.deleteContact(contact!.id!);
                  setState(
                    () => contacts.removeWhere((item) => item.id == contact.id),
                  );
                },
                child: Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showContactPage([Contact? contact]) async {
    final recContact = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactPage(contact: contact),
      ),
    );
    if (recContact != null) {
      // We passed a contact so thismis a edit process
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) => setState(() => contacts = list));
  }
}
