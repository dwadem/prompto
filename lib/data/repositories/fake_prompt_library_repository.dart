import '../../domain/entities/prompt_template.dart';
import '../../domain/repositories/prompt_library_repository.dart';
import '../sources/sample_data.dart';

/// In-memory prompt-template library backed by [SampleData].
class FakePromptLibraryRepository implements PromptLibraryRepository {
  @override
  Future<List<PromptTemplate>> getTemplates() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return SampleData.templates();
  }
}
