import 'dart:io';

import 'package:flutter/material.dart';
import 'package:registration_form/infra/db_sqlite.dart';
import 'package:registration_form/models/user.dart';
import 'package:registration_form/pages/registration_page.dart';
import 'package:registration_form/repositories/user_repository.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<User> listUsers = <User>[];

  var repository = UserRepository(DBSQLite());

  @override
  void initState() {
    super.initState();
    repository.users.then((value) {
      setState(() {
        listUsers = value;
      });
    });
  }

  Future<bool> _confirmDismiss(int index) async {
    var deleteConfirmation = await _deleteConfirmationDialog(listUsers[index]);
    if (deleteConfirmation) {
      var deleted = await repository.delete(listUsers[index]);
      if (deleted) {
        listUsers.removeAt(index);
      }
      return deleted;
    }
    return false;
  }

  Future<bool> _deleteConfirmationDialog(User user) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmação de exclusão'),
          content: Text('Deseja excluir o usuário ${user.name}?'),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Sim'),
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Não'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de usuários'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: listUsers.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(listUsers[index].id.toString()),
            direction: DismissDirection.startToEnd,
            background: Container(
              color: Colors.red,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Deletar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            confirmDismiss: (_) {
              return _confirmDismiss(index);
            },
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                    backgroundImage: listUsers[index].image != null
                        ? FileImage(File(listUsers[index].image))
                        : null,
                    backgroundColor: listUsers[index].image == null
                        ? Colors.grey[300]
                        : null,
                    child: listUsers[index].image == null
                        ? Icon(
                            Icons.person,
                            color: Colors.grey,
                          )
                        : null),
                title: Text(listUsers[index].name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CPF: ${listUsers[index].cpf}'),
                    Text('E-mail: ${listUsers[index].email}'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistrationPage(
                        user: listUsers[index],
                      ),
                    ),
                  ).then((value) {
                    setState(() {});
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistrationPage(
                user: User(),
              ),
            ),
          ).then(
            (value) {
              if (value != null) {
                setState(() {
                  listUsers.add(value);
                });
              }
            },
          );
        },
      ),
    );
  }
}
