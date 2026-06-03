import '../entities/prompt_template.dart';

/// Read access to the curated prompt-template library.
abstract interface class PromptLibraryRepository {
  Future<List<PromptTemplate>> getTemplates();
}
