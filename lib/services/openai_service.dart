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
    String l1,
    String l2,
  ) async {
    try {
      await initialize();

      // 언어 설정 확인을 위한 로그
      print('=== OpenAI 서비스 언어 설정 ===');
      print('검색 단어: $word');
      print('출발 언어: $l1');
      print('도착 언어: $l2');
      print('==============================');

      final prompt =
          '''
다음 정보를 바탕으로 AI 언어사전 항목을 아래 예시와 같은 JSON 형식으로 생성해 주세요.
나는 l1 언어를 구사하는 사람이고 l2 언어를 공부하고 있습니다.

- 사용자의 모국어 (l1): $l1
- 사용자의 공부할 언어 (l2): $l2
- 사용자 검색어: "$word"
- isTheWordFromL2 변수: 검색어가 $l2인지 여부

[출력 형식 규칙]

1. JSON은 반드시 유효한 형식으로 출력할 것. 예시A 또는 예시B 중 하나를 출력해야 합니다. 절대 JSON 앞 뒤에 다른 문자열을 추가하지 말 것.
2. 검색어에 오타가 있으면 오타를 수정하고 검색 결과를 출력할 것.
3. 만약 적절한 검색 결과가 없다면 아래 규칙을 모두 무시하고 "적절한 검색 결과가 없습니다."라는 문자열만 출력할 것. 다른 문자열은 출력하지 말 것.
4. "사전적_뜻" 항목에서는 해당 단어가 다른 품사와 번역이 있다면 모두 포함할 것.
5-1. isTheWordFromL2가 true일 때, "뉘앙스" 항목은 $l2 단어 "$word"를 반드시 $l1로 간단히 설명.
5-2. isTheWordFromL2가 false일 때, "뉘앙스" 항목은 "사전적_뜻" 항목의 번역 단어들의 뉘앙스를 각각 설명.
6. "대화_예시"는 총 최대 2세트. 하나의 세트는 $l2 대화와 번역된 $l1 대화로 구성. 순서는 $l2 대화부터.
7. "비슷한_표현"은 총 최대 4개. $l2 단어와 그 뜻을 $l1로 작성.
8. 모든 설명은 $l1로 답변하세요.


**예시A: 아래는 l1가 영어이고 l2가 중국어일 때 중국어 단어 '照片'를 검색한 예시입니다.**

{
  "isTheWordFromL2": true, // 검색한 단어가 l2 단어인지 여부
  "단어": "照片",
  "사전적_뜻": [
    {
      "품사": "Noun", //품사는 모국어로 작성
      "번역": [
        "photograph",
        "photo",
        "picture (taken with a camera)"
      ]
    }
  ],
  "뉘앙스": "‘照片’ refers to a photo or picture taken with a camera, typically printed or digital. It is a neutral, standard word used for personal, professional, or casual contexts.",
  "대화_예시": [
    {
      "중국어": [
        {"speaker": "A", "line": "你旅行的时候拍了照片吗？"},
        {"speaker": "B", "line": "拍了，我拍了很多好看的照片！"}
      ],
      "영어": [
        {"speaker": "A", "line": "Did you take any photos on your trip?"},
        {"speaker": "B", "line": "Yes, I took a lot of great photos!"}
      ]
    },
    ... 총 최대 2세트의 대화 예시를 작성하세요.
  ],
  "비슷한_표현": [
    {"단어": "相片", "뜻": "photo (synonym; interchangeable in most contexts)"},
    {"단어": "影像", "뜻": "image; often used in technical or formal settings"},
    ... 총 최대 4개의 세트를 작성하세요.
  ]
}

**예시B: 아래는 l1가 영어이고 l2가 중국어일 때 영어 단어 'change'를 검색한 예시입니다.**

{
  "isTheWordFromL2": false, // 검색한 단어가 l2 단어인지 여부
  "단어": "change",
  "사전적_뜻": [
    {
      "품사": "Verb",
      "번역": [
        "改变 gǎibiàn",
        "更换 gēnghuàn",
        "换 huàn"
      ]
    },
    {
      "품사": "Noun",
      "번역": [
        "变化 biànhuà",
        "零钱 língqián"
      ]
    }
  ],
  "뉘앙스": "The word ‘change’ in Chinese can vary depending on context. '改变' and '变化' often refer to more abstract or general changes (e.g., behavior, weather), while '更换' and '换' are for replacing things. '零钱' specifically means small coins or bills—spare change.",
  "대화_예시": [
    {
      "중국어": [
        {"speaker": "A", "line": "我想换工作。"},
        {"speaker": "B", "line": "为什么？发生什么事了？"}
      ],
      "영어": [
        {"speaker": "A", "line": "I want to change my job."},
        {"speaker": "B", "line": "Why? What happened?"}
      ]
    },
    ... 총 최대 2세트의 대화 예시를 포함하세요.
  ],
  "비슷한_표현": [
    {"단어": "调整", "뜻": "adjust; used in situations involving fine-tuning or minor changes"},
    {"단어": "转变", "뜻": "shift or transformation, especially in perspective or roles"},
    ... 최소 2개, 최대 4개의 세트를 작성하세요.
  ]
}

''';

      // 생성된 프롬프트 확인
      print('=== 생성된 프롬프트 ===');
      print(prompt);
      print('======================');

      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            '당신은 $l1 사용자의 $l2 학습을 돕는 언어 전문가입니다. 명확하고 실용적인 설명을 제공해주세요. $l1가 모국어인 사람이 이해할 수 있도록 모든 설명은 $l1로 답변하세요.',
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
            model: "gpt-4.1-mini",
            messages: requestMessages,
            temperature: 0.1,
            maxTokens: 700,
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
