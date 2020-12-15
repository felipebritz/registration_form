import 'dart:convert';
import 'package:cnpj_cpf_helper/cnpj_cpf_helper.dart';
import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:registration_form/intra/db_sqlite.dart';
import 'package:registration_form/models/user.dart';
import 'package:registration_form/repositories/user_repository.dart';

class RegistrationPage extends StatefulWidget {
  final User user;
  const RegistrationPage({Key key, this.user}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  var repository = UserRepository(DBSQLite());

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void initState() {
    _cepController.text = widget.user.cep;
    _streetController.text = widget.user.street;
    _districtController.text = widget.user.district;
    _cityController.text = widget.user.city;
    _stateController.text = widget.user.state;
    _countryController.text = widget.user.country;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Formulário de cadastro'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      customTextFormField(
                        'Nome completo',
                        initialValue: widget.user.name,
                        validator: _isEmptyValidator,
                        onSaved: (value) => widget.user.name = value,
                      ),
                      SizedBox(height: 10),
                      customTextFormField(
                        'E-mail',
                        initialValue: widget.user.email,
                        validator: _isEmailValidator,
                        onSaved: (value) => widget.user.email = value,
                      ),
                      SizedBox(height: 10),
                      customTextFormField(
                        'CPF',
                        initialValue: widget.user.cpf,
                        keyboardType: TextInputType.number,
                        validator: _isCpfValidator,
                        onSaved: (value) => widget.user.cpf = value,
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: customTextFormField(
                              'CEP',
                              controller: _cepController,
                              keyboardType: TextInputType.number,
                              validator: _isEmptyValidator,
                              onSaved: (value) => widget.user.cep = value,
                            ),
                          ),
                          SizedBox(width: 10),
                          FlatButton.icon(
                            onPressed: searchCep,
                            icon: Icon(Icons.search),
                            label: Text('Buscar CEP'),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: customTextFormField(
                              'Rua',
                              controller: _streetController,
                              validator: _isEmptyValidator,
                              onSaved: (value) => widget.user.street = value,
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: customTextFormField(
                              'Número',
                              initialValue: widget.user.number?.toString(),
                              keyboardType: TextInputType.number,
                              validator: _isEmptyValidator,
                              onSaved: (value) =>
                                  widget.user.number = int.tryParse(value),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: customTextFormField(
                              'Bairro',
                              controller: _districtController,
                              validator: _isEmptyValidator,
                              onSaved: (value) => widget.user.district = value,
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: customTextFormField(
                              'Cidade',
                              controller: _cityController,
                              validator: _isEmptyValidator,
                              onSaved: (value) => widget.user.city = value,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: customTextFormField(
                              'UF',
                              controller: _stateController,
                              validator: _isEmptyValidator,
                              onSaved: (value) => widget.user.state = value,
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: customTextFormField(
                              'País',
                              controller: _countryController,
                              validator: _isEmptyValidator,
                              onSaved: (value) => widget.user.country = value,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Builder(
            builder: (ctx) {
              return Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                child: OutlineButton(
                  borderSide: BorderSide(color: Colors.red),
                  textColor: Colors.red,
                  child: Text('Salvar'),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      repository
                          .saveUser(widget.user)
                          .then((value) => widget.user.id ??= value);
                      _showRegistry(ctx, widget.user);
                    } else {
                      Scaffold.of(ctx).showSnackBar(
                          SnackBar(content: Text('Formulário Inválido')));
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget customTextFormField(String label,
      {TextInputType keyboardType = TextInputType.text,
      TextEditingController controller,
      String initialValue,
      String Function(String) validator,
      Function(String) onSaved}) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Future<void> _showRegistry(BuildContext context, User user) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cadastro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nome completo: ${user.name}'),
              Text('Email: ${user.email}'),
              Text('CPF: ${CnpjCpfBase.maskCpf(user.cpf)}'),
              Text('CEP: ${user.cep}'),
              Text('Rua: ${user.street}'),
              Text('Número: ${user.number}'),
              Text('Bairro: ${user.district}'),
              Text('Cidade: ${user.city}'),
              Text('UF: ${user.state}'),
              Text('País: ${user.country}'),
            ],
          ),
          actions: [
            FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Voltar')),
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(user);
                },
                child: Text('Concluir')),
          ],
        );
      },
    );
  }

  String _isEmptyValidator(String value) {
    if (value.isEmpty) {
      return 'Campo obrigatório.';
    }
    return null;
  }

  String _isCpfValidator(String value) {
    if (CnpjCpfBase.isCpfValid(value)) {
      return null;
    }
    return 'CPF inválido';
  }

  String _isEmailValidator(String value) {
    if (EmailValidator.validate(value)) {
      return null;
    }
    return 'Email inválido';
  }

  void searchCep() async {
    try {
      Response response = await Dio()
          .get("http://viacep.com.br/ws/${_cepController.text}/json/");
      var json = jsonDecode(response.toString());
      _streetController.text = json['logradouro'];
      _districtController.text = json['bairro'];
      _cityController.text = json['localidade'];
      _stateController.text = json['uf'];
      _countryController.text = 'BR';
    } catch (e) {
      _streetController.text = '';
      _districtController.text = '';
      _cityController.text = '';
      _stateController.text = '';
      _countryController.text = '';
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('CEP Inválido'),
        ),
      );
    }
  }
}
