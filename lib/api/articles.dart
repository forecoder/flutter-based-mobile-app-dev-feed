import 'dart:async';

import 'package:awesome_dev/api/api.dart';

/*
    id: ID!
    date: String!
    title: String!
    description: String
    url: String!
    domain: String!
    tags: [String]
    screenshot: Screenshot
 */
class Article {
  final String id;

  final String date;

  final String title;

  final String description;

  final String url;

  final String domain;

  final List<String> tags;

  final ArticleLinkScreenshot screenshot;

  bool starred = false;

  Article(this.title, this.url,
      {this.id, this.date, this.description, this.domain, this.tags, this.screenshot});

  Article.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        date = json['date'],
        title = json['title'],
        url = json['url'],
        description = json['description'],
        domain = json['domain'],
        tags = json['tags'],
        screenshot = new ArticleLinkScreenshot.fromJson(json['screenshot']);

  String toSharedPreferencesString() => "{"
      "\"title\" : \"${this.title}\","
      "\"url\" : \"${this.url}\""
      "}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          url == other.url;

  @override
  int get hashCode => title.hashCode ^ url.hashCode;
}

/*
data: String
    height: Int
    width: Int
    mimeType: String
 */
class ArticleLinkScreenshot {
  final String mimeType;

  final int width;

  final int height;

  final String data;

  ArticleLinkScreenshot({this.data, this.width, this.height, this.mimeType});

  ArticleLinkScreenshot.fromJson(Map<String, dynamic> json)
      : data = json['data'],
        width = json['width'],
        height = json['height'],
        mimeType = json['mimeType'];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleLinkScreenshot &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

class ArticlesClient {

  Future<List<Article>> _getArticles(String graphqlQuery, String queryKey) async {
    var map = await issueGraphQLQuery(graphqlQuery);
    final dataMap = map["data"];
    var recentArticlesList = dataMap[queryKey];
    if (recentArticlesList == null) {
      throw new StateError('No content');
    }
    List<Article> result = [];
    for (var recentArticle in recentArticlesList) {
      result.add(new Article.fromJson(recentArticle));
    }
    return result;
  }

  Future<List<Article>> getRecentArticles() async {
    final String query = "query { \n "
        " recentArticles { \n "
        "   id \n "
        "   date \n "
        "   title \n "
        "   description \n "
        "   url \n "
        "   domain \n "
        "   tags \n "
        "   screenshot { \n "
        "       height \n "
        "       width \n "
        "       mimeType \n "
        "       data \n "
        "   } \n "
        " } \n "
        "}";
    return _getArticles(query, "recentArticles");
  }

  Future<List<Article>> getFavoriteArticles(List<Article> articlesToLookup) async {
    final titles = articlesToLookup.map((article) => "\"${article.title}\"").join(",");
    final urls = articlesToLookup.map((article) => "\"${article.url}\"").join(",");
    final String query = "query { \n "
        " articles(filter: {titles: [$titles], urls: [$urls]}) { \n "
        "   id \n "
        "   date \n "
        "   title \n "
        "   description \n "
        "   url \n "
        "   domain \n "
        "   tags \n "
        "   screenshot { \n "
        "       height \n "
        "       width \n "
        "       mimeType \n "
        "       data \n "
        "   } \n "
        " } \n "
        "}";
    return _getArticles(query, "articles");
  }

  Future<List<Article>> getAllButRecentArticles() async {
    final String query = "query { \n "
        " allButRecentArticles { \n "
        "   id \n "
        "   date \n "
        "   title \n "
        "   description \n "
        "   url \n "
        "   domain \n "
        "   tags \n "
        "   screenshot { \n "
        "       height \n "
        "       width \n "
        "       mimeType \n "
        "       data \n "
        "   } \n "
        " } \n "
        "}";
    return _getArticles(query, "allButRecentArticles");
  }
}
