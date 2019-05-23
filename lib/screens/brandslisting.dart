import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:ofypets_mobile_app/utils/drawer_homescreen.dart';
import 'package:ofypets_mobile_app/utils/constants.dart';
import 'package:ofypets_mobile_app/models/brand.dart';
import 'package:ofypets_mobile_app/models/product.dart';
import 'package:ofypets_mobile_app/widgets/product_container.dart';

class BrandList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BrandListState();
  }
}

class _BrandListState extends State<BrandList> {
  Map<dynamic, dynamic> responseBody;
  List<Brand> brands = [];
  List<Product> productsByBrand = [];
  bool _isLoading = true;
  bool _isSelected = false;
  Size _deviceSize;
  String _brandName = '';
  String _heading = 'By Brand';
  @override
  void initState() {
    super.initState();
    getBrandsList();
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () => _canLeave(),
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(140.0),
              child: AppBar(
                  title: Text('Shop'),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.shopping_cart),
                      onPressed: () {},
                    )
                  ],
                  bottom: PreferredSize(
                      preferredSize: Size(_deviceSize.width, 40),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isSelected = false;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                    left: 70,
                                    bottom: 20,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _heading,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: _isSelected
                                            ? FontWeight.w200
                                            : FontWeight.bold),
                                  ),
                                )),
                            _isSelected
                                ? Container(
                                    margin: EdgeInsets.only(
                                      bottom: 20,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      ' > ',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w200),
                                    ),
                                  )
                                : Container(),
                            _isSelected
                                ? Container(
                                    margin: EdgeInsets.only(
                                      bottom: 20,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _brandName,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                        _isLoading ? LinearProgressIndicator() : Container()
                      ]))),
            ),
            drawer: HomeDrawer(),
            body: Scrollbar(
              child: _isLoading
                  ? Container(
                      height: _deviceSize.height,
                    )
                  : ListView.builder(
                      itemCount:
                          !_isSelected ? brands.length : productsByBrand.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (!_isSelected) {
                          return Container(
                              color: Colors.white,
                              child: Column(children: [
                                GestureDetector(
                                    onTap: () {
                                      productsByBrand = [];
                                      getBrandProducts(brands[index].id);
                                      setState(() {
                                        _isSelected = true;
                                        _isLoading = true;
                                        _brandName = brands[index].name;
                                      });
                                    },
                                    child: Container(
                                        color: Colors.white,
                                        width: _deviceSize.width,
                                        alignment: Alignment.centerLeft,
                                        margin: EdgeInsets.all(10),
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          brands[index].name,
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ))),
                                Divider()
                              ]));
                        } else {
                          return GestureDetector(
                              onTap: () {},
                              child: productContainer(productsByBrand[index], context));
                        }
                      },
                    ),
            )));
  }

  getBrandsList() {
    http
        .get(Settings.SERVER_URL + 'api/v1/taxonomies?q[name_cont]=Brands&set=nested')
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['taxonomies'][0]['root']['taxons'].forEach((brandObj) {
        setState(() {
          brands.add(Brand(name: brandObj['name'], id: brandObj['id']));
        });
      });
      setState(() {
        _isLoading = false;
      });
    });
  }

  getBrandProducts(int id) {
    http
        .get(Settings.SERVER_URL +
            'api/v1/taxons/products?id=$id&per_page=20&data_set=small')
        .then((response) {
      responseBody = json.decode(response.body);
      responseBody['products'].forEach((product) {
        setState(() {
          productsByBrand.add(Product(
              name: product['name'],
              displayPrice: product['display_price'],
              avgRating: double.parse(product['avg_rating']),
              reviewsCount: product['reviews_count'].toString(),
              image: product['master']['images'][0]['product_url']));
        });
      });
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<bool> _canLeave() {
    if (!_isSelected) {
      return Future<bool>.value(true);
    } else {
      setState(() {
        _isSelected = false;
      });
      return Future<bool>.value(false);
    }
  }
}