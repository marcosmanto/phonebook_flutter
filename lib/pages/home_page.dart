import 'package:flutter/material.dart';
import 'package:phonebook_flutter/helpers/contact_helper.dart';
import 'package:phonebook_flutter/pages/contact_page.dart';
import 'package:phonebook_flutter/widgets/contact_card.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum OrderOptions { orderAZ, orderZA }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ContactHelper _helper = ContactHelper();

  OrderOptions _sort = OrderOptions.orderAZ;

  List<Contact> _contacts = [];

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
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 8),
            onPressed: () => _toggleSort(),
            icon: Icon(Icons.sort),
          )
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: _contacts.length,
        itemBuilder: (context, index) => ContactCard(
          contact: _contacts[index],
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
                  _helper.deleteContact(contact!.id!);
                  setState(
                    () =>
                        _contacts.removeWhere((item) => item.id == contact.id),
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
        await _helper.updateContact(recContact);
      } else {
        await _helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    _helper.getAllContacts().then(
      (list) {
        List<Contact> sortedList = _sortList(_sort, list: list);
        setState(() => _contacts = sortedList);
      },
    );
  }

  void _toggleSort() {
    setState(() {
      _sort = _sort == OrderOptions.orderAZ
          ? OrderOptions.orderZA
          : OrderOptions.orderAZ;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Text ordenado de ${_sort == OrderOptions.orderAZ ? 'A-Z' : 'Z-A'}'),
      ),
    );

    _sortList(_sort);
  }

  List<Contact> _sortList(OrderOptions order, {List<Contact>? list}) {
    list = list ?? _contacts;
    int Function(Contact, Contact)? sortFunction = _sort == OrderOptions.orderAZ
        ? (Contact a, Contact b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase())
        : (Contact a, Contact b) =>
            b.name.toLowerCase().compareTo(a.name.toLowerCase());

    return list..sort(sortFunction);
  }
}
