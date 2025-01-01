import 'package:appwrite/appwrite.dart';
import 'package:blog/data/sources/appwrite/appwrite_constants.dart';

class Appwrite {
  late final Client client;
  late final Account account;
  late final Databases databases;

  Appwrite() {
    client = Client()
      ..setEndpoint(AppwriteConstants.appwriteEndpoint)
      ..setProject(AppwriteConstants.appwriteProjectId)
      ..setSelfSigned(status: true); // Remove in production

    account = Account(client);
    databases = Databases(client);
  }

  Account get accountInstance => account;
  Databases get databasesInstance => databases;
}
