import '../../domain/entities/exercise.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/prompt_template.dart';
import '../../domain/entities/rubric.dart';
import '../../domain/entities/skill_module.dart';

/// Hard-coded curriculum + library content used by the fake repositories.
///
/// This stands in for content that a real backend / Drift seed would provide.
/// TODO: replace with remote content sync (versioned modules, see risk §8).
abstract final class SampleData {
  static const Rubric _clearInstructionRubric = Rubric(
    criteria: [
      RubricCriterion(
        id: 'clarity',
        label: 'Clarity',
        description: 'The task is stated unambiguously.',
        weight: 0.4,
        keywords: ['write', 'create', 'list', 'summarize', 'explain', 'draft'],
      ),
      RubricCriterion(
        id: 'role',
        label: 'Role / tone',
        description: 'A role or tone steers the model.',
        weight: 0.3,
        keywords: ['act as', 'you are', 'tone', 'polite', 'formal', 'friendly'],
      ),
      RubricCriterion(
        id: 'audience',
        label: 'Audience / length',
        description: 'Audience or length is specified.',
        weight: 0.3,
        keywords: ['sentences', 'words', 'for', 'audience', 'beginner', 'short'],
      ),
    ],
  );

  static const Rubric _contextRubric = Rubric(
    criteria: [
      RubricCriterion(
        id: 'context',
        label: 'Context provided',
        description: 'Relevant background/data is supplied.',
        weight: 0.5,
        keywords: ['context', 'given', 'here is', 'based on', 'using the'],
      ),
      RubricCriterion(
        id: 'scope',
        label: 'Scope limited',
        description: 'The model is told what to focus on or ignore.',
        weight: 0.25,
        keywords: ['only', 'focus', 'ignore', 'do not', "don't", 'limit'],
      ),
      RubricCriterion(
        id: 'task',
        label: 'Clear ask',
        description: 'There is a clear instruction.',
        weight: 0.25,
        keywords: ['summarize', 'extract', 'answer', 'write', 'rewrite'],
      ),
    ],
  );

  static const Rubric _structureRubric = Rubric(
    criteria: [
      RubricCriterion(
        id: 'format',
        label: 'Output format',
        description: 'An explicit format is requested.',
        weight: 0.5,
        keywords: ['json', 'table', 'bullet', 'list', 'markdown', 'format'],
      ),
      RubricCriterion(
        id: 'fields',
        label: 'Fields / schema',
        description: 'The expected fields or columns are named.',
        weight: 0.3,
        keywords: ['field', 'key', 'column', 'name', 'value', 'schema'],
      ),
      RubricCriterion(
        id: 'constraint',
        label: 'Constraints',
        description: 'Length/limits/no-extra-text constraints are set.',
        weight: 0.2,
        keywords: ['only', 'no', 'exactly', 'maximum', 'valid'],
      ),
    ],
  );

  static const Rubric _fewShotRubric = Rubric(
    criteria: [
      RubricCriterion(
        id: 'examples',
        label: 'Examples given',
        description: 'At least one input→output example is shown.',
        weight: 0.5,
        keywords: ['example', 'e.g.', 'input', 'output', '->', '=>', ':'],
      ),
      RubricCriterion(
        id: 'pattern',
        label: 'Consistent pattern',
        description: 'Examples follow a consistent, copyable pattern.',
        weight: 0.3,
        keywords: ['like', 'follow', 'same', 'pattern', 'format'],
      ),
      RubricCriterion(
        id: 'task',
        label: 'Final task',
        description: 'The new item to transform is provided.',
        weight: 0.2,
        keywords: ['now', 'do', 'transform', 'classify', 'apply'],
      ),
    ],
  );

  /// The full skill tree. First four modules are the MVP (§7.1); the last two
  /// are Pro/advanced to demonstrate locking.
  static List<SkillModule> modules() => [
        SkillModule(
          id: 'm_basics',
          title: 'Prompt Basics',
          description: 'Clear instructions, role, tone, length, audience.',
          icon: ModuleIcon.basics,
          order: 0,
          lessons: [
            Lesson(
              id: 'l_basics_1',
              moduleId: 'm_basics',
              title: 'A clear instruction',
              subtitle: 'Say exactly what you want',
              xpReward: 20,
              exercises: const [
                TheoryExercise(
                  id: 'e1',
                  prompt: 'Why clarity wins',
                  body:
                      'Models do best when the task is explicit. Vague prompts '
                      'force the model to guess. Name the action (write, list, '
                      'summarize), the subject, and any constraints.',
                  example:
                      'Write a 3-sentence apology email to a client for a '
                      'late delivery, in a warm but professional tone.',
                ),
                MultipleChoiceExercise(
                  id: 'e2',
                  prompt: 'Which prompt is clearest?',
                  options: [
                    'Tell me about emails.',
                    'Write a short, friendly email reminding a teammate about '
                        'tomorrow’s 10am standup.',
                    'Email stuff, make it good.',
                  ],
                  correctIndex: 1,
                  explanation:
                      'It names the action, audience, tone and the key detail '
                      '(the 10am standup).',
                ),
                PromptTaskExercise(
                  id: 'e3',
                  prompt: 'Write your first prompt',
                  scenario:
                      'You want the AI to produce a polite refusal to a meeting '
                      'invite you cannot attend.',
                  rubric: _clearInstructionRubric,
                  hint:
                      'Name the action, set a tone (polite), and add a length '
                      '(e.g. three sentences).',
                  starterPrompt: '',
                ),
              ],
            ),
            Lesson(
              id: 'l_basics_2',
              moduleId: 'm_basics',
              title: 'Role & tone',
              subtitle: 'Give the model a persona',
              xpReward: 20,
              exercises: const [
                TheoryExercise(
                  id: 'e1',
                  prompt: 'Roles steer style',
                  body:
                      'Starting with "You are a…" sets vocabulary, depth and '
                      'tone. Pair the role with the audience for best results.',
                  example:
                      'You are a friendly nutrition coach. Explain protein to '
                      'a curious beginner in under 80 words.',
                ),
                PromptTaskExercise(
                  id: 'e2',
                  prompt: 'Use a role',
                  scenario:
                      'Explain what an API is to a non-technical manager.',
                  rubric: _clearInstructionRubric,
                  hint: 'Open with a role ("You are…") and name the audience.',
                ),
              ],
            ),
          ],
        ),
        SkillModule(
          id: 'm_context',
          title: 'Context & Data',
          description: 'Provide context, cite sources, limit the topic.',
          icon: ModuleIcon.context,
          order: 1,
          lessons: [
            Lesson(
              id: 'l_context_1',
              moduleId: 'm_context',
              title: 'Feed the model context',
              subtitle: 'Don’t make it guess',
              xpReward: 25,
              exercises: const [
                TheoryExercise(
                  id: 'e1',
                  prompt: 'Context beats cleverness',
                  body:
                      'The model only knows what you tell it. Paste the source '
                      'text, then ask your question about it, and tell it to '
                      'rely only on that text.',
                ),
                PromptTaskExercise(
                  id: 'e2',
                  prompt: 'Ground the answer',
                  scenario:
                      'You pasted a product return policy and want a one-line '
                      'answer to "Can I return opened items?" using only it.',
                  rubric: _contextRubric,
                  hint:
                      'Reference the provided text and tell the model to use '
                      'only that context.',
                  starterPrompt: 'Using the policy below, ',
                ),
              ],
            ),
          ],
        ),
        SkillModule(
          id: 'm_fewshot',
          title: 'Examples (Few-shot)',
          description: 'Teach by pattern: good vs. bad examples.',
          icon: ModuleIcon.fewShot,
          order: 2,
          lessons: [
            Lesson(
              id: 'l_fewshot_1',
              moduleId: 'm_fewshot',
              title: 'Show, don’t tell',
              subtitle: 'Examples set the pattern',
              xpReward: 25,
              exercises: const [
                TheoryExercise(
                  id: 'e1',
                  prompt: 'Few-shot prompting',
                  body:
                      'Give the model 1–3 input→output examples. It will copy '
                      'the pattern for your new input. Keep examples consistent.',
                  example:
                      'Review: "Loved it!" -> Positive\n'
                      'Review: "Waste of money" -> Negative\n'
                      'Review: "It was okay" ->',
                ),
                PromptTaskExercise(
                  id: 'e2',
                  prompt: 'Build a few-shot prompt',
                  scenario:
                      'Classify support messages as Billing, Technical, or '
                      'Other. Show the model the pattern, then give it a new one.',
                  rubric: _fewShotRubric,
                  hint: 'Provide 2 labelled examples, then the new message.',
                ),
              ],
            ),
          ],
        ),
        SkillModule(
          id: 'm_structure',
          title: 'Response Structure',
          description: 'Force a format: lists, tables, JSON, tags.',
          icon: ModuleIcon.structure,
          order: 3,
          lessons: [
            Lesson(
              id: 'l_structure_1',
              moduleId: 'm_structure',
              title: 'Demand a format',
              subtitle: 'Make output machine-ready',
              xpReward: 30,
              exercises: const [
                TheoryExercise(
                  id: 'e1',
                  prompt: 'Structured output',
                  body:
                      'When you need to parse or reuse output, ask for a strict '
                      'format (e.g. JSON with named keys) and forbid extra text.',
                  example:
                      'Return ONLY valid JSON: {"title": string, "tags": '
                      'string[]}. No prose.',
                ),
                PromptTaskExercise(
                  id: 'e2',
                  prompt: 'Get clean JSON',
                  scenario:
                      'Extract name, email and topic from an enquiry into JSON '
                      'your app can parse.',
                  rubric: _structureRubric,
                  hint: 'Name the format (JSON), the keys, and forbid extra text.',
                  starterPrompt:
                      'Extract the following fields and return only JSON: ',
                ),
              ],
            ),
          ],
        ),
        // --- Advanced / Pro (Phase 2) — present but locked. ---
        SkillModule(
          id: 'm_reasoning',
          title: 'Step-by-step Reasoning',
          description: 'Guide the model through complex tasks.',
          icon: ModuleIcon.reasoning,
          order: 4,
          isPro: true,
          lessons: [
            Lesson(
              id: 'l_reasoning_1',
              moduleId: 'm_reasoning',
              title: 'Think in steps',
              subtitle: 'Decompose hard problems',
              xpReward: 35,
              isPro: true,
              exercises: const [
                TheoryExercise(
                  id: 'e1',
                  prompt: 'Chain the steps',
                  body:
                      'Asking the model to plan before answering improves '
                      'accuracy on multi-step tasks.',
                ),
              ],
            ),
          ],
        ),
        SkillModule(
          id: 'm_verify',
          title: 'Verification & Ethics',
          description: 'Spot hallucinations, fact-check, respect privacy.',
          icon: ModuleIcon.verification,
          order: 5,
          isPro: true,
          lessons: [
            Lesson(
              id: 'l_verify_1',
              moduleId: 'm_verify',
              title: 'Trust, but verify',
              subtitle: 'Catch confident mistakes',
              xpReward: 35,
              isPro: true,
              exercises: const [
                TheoryExercise(
                  id: 'e1',
                  prompt: 'Hallucinations',
                  body:
                      'Models can state false things confidently. Ask for '
                      'sources and verify claims independently.',
                ),
              ],
            ),
          ],
        ),
      ];

  static List<PromptTemplate> templates() => const [
        PromptTemplate(
          id: 't1',
          title: 'The role + audience opener',
          category: 'Basics',
          prompt:
              'You are a senior {role}. Explain {topic} to {audience} in under '
              '{n} words, using one concrete example.',
          whyItWorks:
              'Sets expertise, audience and length up front, so the model '
              'calibrates depth and tone before writing.',
        ),
        PromptTemplate(
          id: 't2',
          title: 'Grounded Q&A',
          category: 'Context',
          prompt:
              'Using ONLY the text below, answer the question. If the answer '
              'is not present, say "Not stated".\n\nTEXT:\n{paste}\n\nQ: {q}',
          whyItWorks:
              'Constrains the model to provided context and gives a safe '
              'fallback, which sharply reduces hallucination.',
        ),
        PromptTemplate(
          id: 't3',
          title: 'Strict JSON extractor',
          category: 'Structure',
          prompt:
              'Extract fields and return ONLY valid JSON matching: '
              '{"name": string, "email": string, "topic": string}. No prose.\n\n'
              'INPUT: {paste}',
          whyItWorks:
              'A named schema plus "ONLY JSON, no prose" makes the output '
              'reliably parseable by your app.',
        ),
        PromptTemplate(
          id: 't4',
          title: 'Few-shot classifier',
          category: 'Few-shot',
          prompt:
              'Classify each message as Billing / Technical / Other.\n'
              '"My card was charged twice" -> Billing\n'
              '"The app crashes on login" -> Technical\n'
              '"{paste}" ->',
          whyItWorks:
              'Two consistent labelled examples teach the pattern far better '
              'than a description of the categories.',
          isPro: true,
        ),
        PromptTemplate(
          id: 't5',
          title: 'Before/after rewriter',
          category: 'Iteration',
          prompt:
              'Improve this prompt for clarity, context and format. Return the '
              'improved prompt only:\n\n{paste}',
          whyItWorks:
              'Turns the model into a prompt coach — useful for iterating on '
              'weak prompts quickly.',
          isPro: true,
        ),
      ];
}
