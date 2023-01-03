import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String contactTable = 'contactTable';
const String idColumn = 'idColumn';
const String nameColumn = 'nameColumn';
const String emailColumn = 'emailColumn';
const String phoneColumn = 'phoneColumn';
const String imgColumn = 'imgColumn';

class ContactHelper {
  static final ContactHelper _instance = ContactHelper._internal();

  factory ContactHelper() => _instance;

  ContactHelper._internal();

  late final Future<Database> _db = _initDb();

  Future<Database> get db async {
    return await _db;
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'contacts.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''CREATE TABLE $contactTable (
          $idColumn INTEGER PRIMARY KEY,
          $nameColumn TEXT,
          $emailColumn TEXT,
          $phoneColumn TEXT,
          $imgColumn TEXT
        );
      ''');
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    // Datase insert returns the ID of created record in the database
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact?> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(
      contactTable,
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
      where: '$idColumn = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(
      contactTable,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(
      contactTable,
      contact.toMap(),
      where: '$idColumn = ?',
      whereArgs: [contact.id],
    );
  }

  Future<List<Contact>> getAllContacts() async {
    Database dbContact = await db;

    List listMap = await dbContact.rawQuery('SELECT * FROM $contactTable');
    List<Contact> listContact = [];
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
      await dbContact.rawQuery('SELECT COUNT(*) FROM $contactTable'),
    );
  }

  Future<void> close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  int? id;
  late String name;
  late String email;
  late String phone;
  late String img;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };

    if (id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() =>
      'Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)';
}
