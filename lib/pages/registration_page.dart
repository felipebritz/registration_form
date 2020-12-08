import 'dart:convert';
import 'package:cnpj_cpf_helper/cnpj_cpf_helper.dart';
import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:registration_form/models/user_model.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  var user = User();

  void searchCep() async {
    try {
      Response response = await Dio()
          .get("http://viacep.com.br/ws/${_cepController.text}/json/");
      var json = jsonDecode(response.toString());
      print(json);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.red,
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
                        onSaved: (value) => user.name = value,
                      ),
                      SizedBox(height: 10),
                      customTextFormFieldEmail(
                        'Email',
                        onSaved: (value) => user.email = value,
                      ),
                      SizedBox(height: 10),
                      customTextFormFieldCFP(
                        'CPF',
                        onSaved: (value) => user.cpf = value,
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
                              onSaved: (value) => user.cep = value,
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
                              onSaved: (value) => user.street = value,
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: customTextFormField(
                              'Número',
                              keyboardType: TextInputType.number,
                              onSaved: (value) => user.number = value,
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
                              onSaved: (value) => user.district = value,
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: customTextFormField(
                              'Cidade',
                              controller: _cityController,
                              onSaved: (value) => user.city = value,
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
                              onSaved: (value) => user.state = value,
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: customTextFormField(
                              'País',
                              controller: _countryController,
                              onSaved: (value) => user.country = value,
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
                  child: Text('Cadastrar'),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      _showRegistry(ctx, user);
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

  String _isEmptyValidator(String value) {
    if (value.isEmpty) {
      return 'Campo obrigatório.';
    }
    return null;
  }

  Widget customTextFormField(String label,
      {TextInputType keyboardType = TextInputType.text,
      TextEditingController controller,
      Function(String) onSaved}) {
    return TextFormField(
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: _isEmptyValidator,
      onSaved: onSaved,
    );
  }

  Widget customTextFormFieldEmail(String label, {Function(String) onSaved}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (EmailValidator.validate(value)) {
          return null;
        }
        return 'Email inválido';
      },
      onSaved: onSaved,
    );
  }

  Widget customTextFormFieldCFP(String label, {Function(String) onSaved}) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (CnpjCpfBase.isCpfValid(value)) {
          return null;
        }
        return 'CPF inválido';
      },
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
        );
      },
    );
  }
}
