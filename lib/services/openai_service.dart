import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null) {
      throw Exception('OPENAI_API_KEY가 설정되지 않았습니다.');
    }

    OpenAI.apiKey = apiKey;
    _isInitialized = true;
  }

  static Future<String> getWordDefinition(
    String word,
    String fromLanguage,
    String toLanguage,
  ) async {
    try {
      await initialize();

      final prompt =
          '''
다음 단어에 대해 $fromLanguage로 답변해주세요. 
단어: "$word"

다음 5가지 항목을 포함해서 답변해주세요:

1. **사전적 뜻**: 단어의 기본적인 의미
2. **실제 뉘앙스**: 일상에서 사용할 때의 미묘한 차이와 뉘앙스
3. **사용 상황**: 어떤 상황에서 이 단어를 사용하는지 구체적인 예시
4. **예문**: 실제 사용할 수 있는 예문 3개 (원문과 $toLanguage 번역 포함)
5. **비슷한 표현**: 의미가 비슷하거나 관련된 다른 단어나 표현들

답변은 깔끔하고 이해하기 쉽게 작성해주세요.
''';

      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            '당신은 언어 학습을 돕는 언어 전문가입니다. 명확하고 실용적인 설명을 제공해주세요.',
          ),
        ],
        role: OpenAIChatMessageRole.system,
      );

      // the user message that will be sent to the request.
      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
        ],
        role: OpenAIChatMessageRole.user,
      );

      // all messages to be sent.
      final requestMessages = [systemMessage, userMessage];

      // the actual request.
      OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat
          .create(
            model: "gpt-4.1-nano",
            messages: requestMessages,
            temperature: 0.2,
            maxTokens: 200,
          );

      return chatCompletion.choices.first.message.haveContent
          ? chatCompletion.choices.first.message.content.toString()
          : '응답을 생성할 수 없습니다.';
    } catch (e) {
      print('OpenAI API 호출 오류: $e');
      return '죄송합니다. 현재 서비스를 이용할 수 없습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  static Future<String> getWordDefinitionSimple(String word) async {
    try {
      await initialize();

      final prompt =
          '''
"$word"라는 단어에 대해 다음 형식으로 답변해주세요:

**사전적 뜻:**
[단어의 기본적인 의미]

**실제 뉘앙스:**
[일상에서 사용할 때의 미묘한 차이]

**사용 상황:**
[어떤 상황에서 사용하는지 설명]

**예문:**
1. [예문 1] - [한국어 번역]
2. [예문 2] - [한국어 번역]
3. [예문 3] - [한국어 번역]

**비슷한 표현:**
[관련된 다른 단어나 표현들]
''';

      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            '당신은 언어 학습을 돕는 언어 전문가입니다. 명확하고 실용적인 설명을 제공해주세요.',
          ),
        ],
        role: OpenAIChatMessageRole.system,
      );

      // the user message that will be sent to the request.
      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
        ],
        role: OpenAIChatMessageRole.user,
      );

      // all messages to be sent.
      final requestMessages = [systemMessage, userMessage];

      // the actual request.
      OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat
          .create(
            model: "gpt-4.1-nano",
            messages: requestMessages,
            temperature: 0.2,
            maxTokens: 200,
          );

      return chatCompletion.choices.first.message.haveContent
          ? chatCompletion.choices.first.message.content.toString()
          : '응답을 생성할 수 없습니다.';
    } catch (e) {
      print('OpenAI API 호출 오류: $e');
      return '죄송합니다. 현재 서비스를 이용할 수 없습니다. 잠시 후 다시 시도해주세요.';
    }
  }
}
