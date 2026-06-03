/// A curated, reusable prompt with an explanation of *why* it works —
/// the "exemplary prompts library" from the concept (§4.4).
class PromptTemplate {
  const PromptTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.prompt,
    required this.whyItWorks,
    this.isPro = false,
  });

  final String id;
  final String title;
  final String category;
  final String prompt;
  final String whyItWorks;
  final bool isPro;
}
