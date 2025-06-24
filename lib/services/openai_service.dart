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

  static Future<String> getWordDefinitionSimple(
    String word,
    String fromLanguage,
    String toLanguage,
  ) async {
    try {
      await initialize();

      final prompt =
          '''
다음 단어 "$word"에 대해 무조건 JSON 형식으로 아래 예시처럼 답변해주세요.
만약 단어가 틀렸다면 올바른 단어로 수정해서 답변해주세요.
단어는 무조건 $fromLanguage로 변경해주세요.
설명은 무조건 $toLanguage로 답변해주세요.

  "단어": "light",
  "사전적_뜻": [
    {
      "품사": "명사",
      "뜻": [
        "(해, 전등 등의) 빛, 광선, 빛살",
        "(특정한 색깔, 특질을 지닌) 빛",
        "발광체, (특히 전깃)불, (전)등"
      ]
    },
    {
      "품사": "형용사",
      "뜻": [
        "(날이) 밝은, (빛이) 밝은",
        "(색깔이) 연한",
        "가벼운, 무겁지 않은"
      ]
    },
    {
      "품사": "동사",
      "뜻": [
        "불을 붙이다",
        "(불이) 붙다",
        "(빛을) 비추다"
      ]
    }
  ],
  "뉘앙스": "이 단어의 뉘앙스를 간단히 설명",
  "회화에서의_사용": "실제로 회화에서 많이 쓰는 단어인지, 어떤 상황에서 쓰는지 설명",
  "대화_예시": [
  {
    "en": [
      {"speaker": "A", "line": "Hi, can you turn on the light?"},
      {"speaker": "B", "line": "Sure, it's a bit dark here."}
    ],
    "ko": [
      {"speaker": "A", "line": "안녕, 불 좀 켜줄래?"},
      {"speaker": "B", "line": "물론이지, 여기 좀 어둡네."}
    ]
  },
  {
    "en": [
      {"speaker": "A", "line": "I love the morning light."},
      {"speaker": "B", "line": "Yeah, it makes everything feel fresh."}
    ],
    "ko": [
      {"speaker": "A", "line": "나는 아침 햇살이 정말 좋아."},
      {"speaker": "B", "line": "맞아, 모든 게 상쾌하게 느껴져."}
    ]
  }
],
  "비슷한_표현": [
    {"단어": "단어1", "뜻": "뜻1"},
    {"단어": "단어2", "뜻": "뜻2"},
    {"단어": "단어3", "뜻": "뜻3"}
  ]

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
            maxTokens: 600,
          );

      return chatCompletion.choices.first.message.haveContent
          ? chatCompletion.choices.first.message.content![0].text.toString()
          : '응답을 생성할 수 없습니다.';
    } catch (e) {
      print('OpenAI API 호출 오류: $e');
      return '죄송합니다. 현재 서비스를 이용할 수 없습니다. 잠시 후 다시 시도해주세요.';
    }
  }
}
