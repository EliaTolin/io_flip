// ignore_for_file: avoid_print

import 'dart:io';

import 'package:data_loader/data_loader.dart';
import 'package:db_client/db_client.dart';
import 'package:prompt_repository/prompt_repository.dart';

void main(List<String> args) async {
  if (args.length == 2) {
    final projectId = args.first;
    final csv = args.last;

    final csvFile = File(csv);

    final dbClient = DbClient.initialize(projectId);
    final promptRepository = PromptRepository(
      // With the new structure, we can remove this configuration
      // as we will a collection with the terms instead of having
      // all of them in the same collection.
      // TODO(erickzanardo): remove this configuration once the
      // new structure is merged.
      whitelistDocumentId: '',
      dbClient: dbClient,
    );

    final dataLoader = DataLoader(
      promptRepository: promptRepository,
      csv: csvFile,
    );

    await dataLoader.load((current, total) {
      print('Progress: ($current of $total)');
    });
  } else {
    print('Usage: dart data_loader.dart <projectId> <csv>');
  }
}