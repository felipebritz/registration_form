class User {
  int id;
  String name;
  String email;
  String cpf;
  String cep;
  String street;
  int number;
  String district;
  String city;
  String state;
  String country;
  String image;

  User({
    this.id,
    this.name,
    this.email,
    this.cpf,
    this.cep,
    this.street,
    this.number,
    this.district,
    this.city,
    this.state,
    this.country,
    this.image,
  });

  User.fromMap(Map<String, dynamic> user) {
    id = user['id'];
    name = user['name'];
    email = user['email'];
    cpf = user['cpf'];
    cep = user['cep'];
    street = user['street'];
    number = user['number'];
    district = user['district'];
    city = user['city'];
    state = user['state'];
    country = user['country'];
    image = user['image'];
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'cpf': cpf,
        'cep': cep,
        'street': street,
        'number': number,
        'district': district,
        'city': city,
        'state': state,
        'country': country,
        'image': image
      };

  @override
  String toString() {
    return '$name, $email, $cpf, $cep, $street, $number, $district, $city, $state, $country, $image';
  }
}
