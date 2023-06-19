import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/home_screen.dart';
import 'data_product_model.dart';
import 'package:http/http.dart' as http;

class ModelProvider with ChangeNotifier {
  List selectedProduct = [];
  List selectedProductOrders = [];

  //List productsList = [];
  dynamic productPrice = 0;

  add(DataProductModel product) {
    selectedProduct.add(product);

    productPrice += product.productPrice.round();

    notifyListeners();
  }

  remove(DataProductModel product) {
    selectedProduct.remove(product);

    productPrice -= product.productPrice.round();

    notifyListeners();
  }

  get itemModelLength {
    return selectedProduct.length;
  }

  addOrder(DataProductModel productOrder) {
    selectedProductOrders.add(productOrder);

    notifyListeners();
  }

// moveToOrderScreen it is temporary
  void moveToOrderScreen() {
    for (var product in selectedProduct) {
      addOrder(product);
    }
    notifyListeners();
  }

  removeItemOfList() {
    selectedProduct.clear();
    productPrice = 0;
    notifyListeners();
  }

  int _randomNumber = 0;

  int get productOrderId => _randomNumber;

  int generateRandomNumber() {
    final random = Random();
    _randomNumber = random.nextInt(12587800);
    return _randomNumber;
    notifyListeners();
  }

// Login Method:
  final loginFormKey = GlobalKey<FormState>();

  final String loginApi = 'http://185.132.55.54:8000/login/';
  final TextEditingController emailLoginController = TextEditingController();
  final TextEditingController passwordLoginController = TextEditingController();

  Future<void> loginUser(BuildContext context) async {
    final url = Uri.parse('http://185.132.55.54:8000/login/');

    try {
      final response = await http.post(
        url,
        body: {
          'email': Provider.of<ModelProvider>(context, listen: false)
              .emailLoginController
              .text,
          'password': Provider.of<ModelProvider>(context, listen: false)
              .passwordLoginController
              .text,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful')),
        );

        loginFormKey.currentState?.reset();

        Navigator.pushNamedAndRemoveUntil(
          context,
          HomeScreen.homeScreenRoute,
          (route) => false,
        );
      } else if (response.statusCode == 404) {
        // Email or password incorrect
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid email or password')),
        );
      } else {
        // Other error occurred
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed')),
        );
      }
    } catch (e) {
      // Error occurred
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

// Register Method:
  final registerFormKey = GlobalKey<FormState>();

  final String registerApi = 'http://185.132.55.54:8000/register/';
  final TextEditingController firstNameRegisterController =
      TextEditingController();
  final TextEditingController lastNameRegisterController =
      TextEditingController();
  final TextEditingController emailRegisterController = TextEditingController();
  final TextEditingController phoneNumberRegisterController =
      TextEditingController();
  final TextEditingController addressRegisterController =
      TextEditingController();
  final TextEditingController passwordRegisterController =
      TextEditingController();

  Future<void> registerUser(BuildContext context) async {
    final url = Uri.parse('http://185.132.55.54:8000/register/');

    try {
      final response = await http.post(
        url,
        body: {
          'first_name': Provider.of<ModelProvider>(context, listen: false)
              .firstNameRegisterController
              .text,
          'last_name': Provider.of<ModelProvider>(context, listen: false)
              .lastNameRegisterController
              .text,
          'email': Provider.of<ModelProvider>(context, listen: false)
              .emailRegisterController
              .text,
          'phone_number': Provider.of<ModelProvider>(context, listen: false)
              .phoneNumberRegisterController
              .text,
          'address': Provider.of<ModelProvider>(context, listen: false)
              .addressRegisterController
              .text,
          'password': Provider.of<ModelProvider>(context, listen: false)
              .passwordRegisterController
              .text,
        },
      );

      if (response.statusCode == 201) {
        print('Registration successful');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful')),
        );
        registerFormKey.currentState?.reset();
      } else {
        print('Registration failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // method show data in information screen:
  Map<String, dynamic>? _userData;

  Map<String, dynamic>? getUserData() => _userData;

  Future<void> sendPostRequest(BuildContext context) async {
    if (loginFormKey.currentState!.validate()) {
      Map<String, dynamic> data = {
        'email': emailLoginController.text,
        'password': passwordLoginController.text,
      };
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };
      var response = await http.post(Uri.parse(loginApi),
          headers: headers, body: jsonEncode(data));
      if (response.statusCode == 200) {
        // Success
        var responseBody = jsonDecode(response.body);
        Provider.of<ModelProvider>(context, listen: false)
            .userDataMethod(responseBody);
      } else {
        // Error
        print('Error: ${response.reasonPhrase}');
      }
    }
  }

  void userDataMethod(Map<String, dynamic>? userData) {
    _userData = userData;
    notifyListeners();
  }

  // log out method:
  Future<void> logoutApi() async {
    var response =
        await http.get(Uri.parse('http://185.132.55.54:8000/logout/'));
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      print('Successful logout');
      // Successful logout
    } else {
      print('Logout failed');
    }
  }

  // override to all controller:
  @override
  void dispose() {
    emailLoginController.dispose();
    passwordLoginController.dispose();
    emailRegisterController.dispose();
    passwordRegisterController.dispose();
    firstNameRegisterController.dispose();
    lastNameRegisterController.dispose();
    phoneNumberRegisterController.dispose();
    addressRegisterController.dispose();
    // super.dispose();
  }
}

/*
var responseBody = jsonDecode(response.body);
classInstance.user = User.fromJson(responseBody);

setState(() {

  userInformation: classInstance.user?.firstName ?? 'empty',
});
 */

/*
  Future<List<DataProductModel>> getAllProducts() async {
    List<dynamic> data =
        await ApiHelper().get(url: 'https://fakestoreapi.com/products');
    List<DataProductModel> productsList = [];
    for (var i = 0; i < data.length; i++) {
      productsList.add(DataProductModel.fromJson(data[i]));
    }
    return productsList;
  }
  */

/*

import 'package:flutter/foundation.dart';
import '../helper/api_helper.dart';
import 'data_product_model.dart';

class ModelProvider with ChangeNotifier {
  List selectedProduct = [];
  List selectedProductOrders = [];
  int productPrice = 0;

  add(DataProductModel product) {
    selectedProduct.add(product);

    //productPrice += product.productPrice.round();

    notifyListeners();
  }

  remove(DataProductModel product) {
    selectedProduct.remove(product);

    //productPrice -= product.productPrice.round();

    notifyListeners();
  }

  get itemModelLength {
    return selectedProduct.length;
  }

  addOrder(DataProductModel productOrder) {
    selectedProductOrders.add(productOrder);

    notifyListeners();
  }
// moveToOrderScreen it is temporary
  void moveToOrderScreen() {
    for (var product in selectedProduct) {
      addOrder(product);
    }
    notifyListeners();
  }

  removeItemOfList() {
    selectedProduct.clear();
    productPrice = 0;
    notifyListeners();
  }

  Future<List<DataProductModel>> getAllProducts() async {
    List<dynamic> data = await ApiHelper()
        .get(url: 'https://fakestoreapi.com/products');
    List<DataProductModel> productsList = [];
    for (var i = 0; i < data.length; i++) {
      productsList.add(DataProductModel.fromJson(data[i]));
    }
    return productsList;
  }
}

*/
