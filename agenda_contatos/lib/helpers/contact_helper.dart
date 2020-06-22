import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//Definindo colunas da tabela do banco de dados.
final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

//Classe de gerencia do banco
class ContactHelper {
  //objeto único da classe
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;
  //Construtor
  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      //caso o banco não esteja criado é inicializado com a função abaixo
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path =
        join(databasesPath, "contacts.db"); //caminho pro banco de dados

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

  //Função para salvar contato no banco, tem que esperar um Future pois é async.
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db; //obter banco de dados
    //na tabela de contatos insiro e obetenho o id
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;// retorno o contato
  }

  //Pegar dados do contato atracés do id
  Future<Contact> getContact(int id) async {
    Database dbContact = await db; //obter banco de dados
    List<Map> maps = await dbContact.query(contactTable, columns://query para buscar os dados no banco
      [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],//Colunas para retirar os dados
      where: "$idColumn = ?",//Condição para a que possa ser encontrado os dados, utilizando a referência do id do user
      whereArgs: [id]//id passado como argumento do parametro para ser referenciado ao user do BD.
    );
    //Condição para verificar se o Id indicado é igual o do user
    if(maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }
  //Função para deletar um contato
  Future<int> deleteContact(int id) async {
    Database dbContact = await db; //obter banco de dados
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);//deletar de acordo com o id informado
  }
  //Função para atualizar as informações de um contato
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db; //obter banco de dados
    return await dbContact.update(
      contactTable, 
      contact.toMap(),
      where: "$idColumn = ?",
      whereArgs: [contact.id]
    );
  }
  //Função que lista todos os contatos salvos
  Future<List> getAllContacts() async {
    Database dbContact = await db; //obter banco de dados
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");//SQL para pegar todos os itens da tabela
    List<Contact> listContact = List();//Declarando lista vazia de contatos
    for(Map m in listMap) {//Varrendo a lista de contatos do banco 
      listContact.add(Contact.fromMap(m));//Adicionando na nova lista os contatos encontrados no banco
    }
    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db; //obter banco de dados
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db; //obter banco de dados
    dbContact.close();//Fechando o BD
  }
}

//Classe com os construtores do Contato que contém os atributos da tabela do BD
class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;


  Contact();
  //Armazenar os dados na tabela em formato de mapa para construir o contato
  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  //Função que trasnforma os contatos em um mapa
  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
