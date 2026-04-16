import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'summary.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ArticleView(),
    );
  }
}

class ArticleModel{
  Future<Summary> getRandomArticleSummary() async{
    final uri = Uri.https('en.wikipedia.org', '/api/rest_v1/page/random/summary');
    final response = await get(uri);

    if(response.statusCode != 200){
      throw HttpException('Failed to update resource');
    }

    return Summary.fromJson(jsonDecode(response.body));
  }
}

class ArticleViewModel extends ChangeNotifier{
  final ArticleModel model;
  Summary? summary;
  String? errorMessage;
  bool isLoading = false;

  ArticleViewModel(this.model){
    getRandomArticleSummary();
  }

  Future<void> getRandomArticleSummary() async{
    isLoading = true;
    notifyListeners();

    try{
      summary = await model.getRandomArticleSummary();
      print('Article Loaded ${summary!.titles.normalized}');
      errorMessage = null;
    } on HttpException catch (error){
      errorMessage = error.message;
      print('Error Message ${error.message}');
      summary = null;
    }

    isLoading = false;
    notifyListeners();
  }
}

class ArticleView extends StatelessWidget{
  ArticleView({super.key});

  final viewModel = ArticleViewModel(ArticleModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wikipedia flutter'),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          return switch((
            viewModel.isLoading,
            viewModel.summary,
            viewModel.errorMessage
          )){
            (true, _, _) => CircularProgressIndicator(),
            (false, _, String message) => Center(child: Text(message)),
            (false, null, null) => Center(
              child: Text('An unknown error has occurred'),
            ),
            // The summary must be non-null in this switch case.
            (false, Summary summary, null) => ArticlePage(
              summary: summary,
              nextArticleCallback: viewModel.getRandomArticleSummary,
            ),
          };
        },
      ),
    );
  }
}

class ArticlePage extends StatelessWidget{
  const ArticlePage({
    super.key,
    required this.summary,
    required this.nextArticleCallback,
  });

  final Summary summary;
  final VoidCallback nextArticleCallback;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(child: Text('Article data here'));
  }
}
