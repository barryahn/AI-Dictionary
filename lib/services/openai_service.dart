import 'dart:async';

import 'package:openai_dart/openai_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

typedef ChatDeltaCallback = void Function(String delta);
typedef ChatCompleteCallback = void Function();
typedef ChatErrorCallback = void Function(Object error);

class OpenAIService {
  static bool _isInitialized = false;
  static StreamSubscription? _subscription;
  static final String _proModel = "gpt-4.1-mini";
  static final String _freeModel = "gpt-4o-mini";
  static String get proModel => _proModel;
  static String get freeModel => _freeModel;

  static late OpenAIClient client;

  static void dispose() {
    _subscription?.cancel();
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null) {
      throw Exception('OPENAI_API_KEY가 설정되지 않았습니다.');
    }

    _isInitialized = true;

    client = OpenAIClient(apiKey: apiKey);
  }

  /*===============================================
  L1과 L2가 같을 때 단어 정의 생성
  ===============================================*/

  static void getL1EqualsToL2WordDefinition(
    String word,
    String l1,
    ChatDeltaCallback onDelta,
    ChatCompleteCallback onComplete,
    ChatErrorCallback onError, {
    bool usingProModel = false,
  }) async {
    try {
      // 언어 설정 확인을 위한 로그
      print('=== OpenAI 서비스 언어 설정 ===');
      print('검색 단어: $word');
      print('출발 언어: $l1');
      print('도착 언어: $l1');
      print('==============================');

      final prompt =
          '''
단어 '$word'에 대해서 자세히 알고 싶어요. 아래 예시와 같은 NDJSON 형식으로 출력해주세요.
단, 모든 설명은 $l1로 해주세요.

[출력 형식 규칙]
1. NDJSON은 반드시 아래의 형식으로 출력한다.
2. "단어"에 '$word'를 넣는다. 단, '$word'에 오타가 있으면 오타를 수정해서 "단어"에 표기한다.
3. 만약 검색 결과가 없다면 아래 규칙을 모두 무시하고 "No result"라는 문자열만 출력할 것. 다른 문자열은 출력하지 않는다.
5. "대화_예시"는 총 2세트.
6. "비슷한_표현"은 총 최대 4개.
7. "비슷한_표현"에서 중국어가 있을 경우 改变 (gǎibiàn)처럼 한어병음을 함께 표기한다.

{"단어": "$word"}
{"단어_뜻": "이 표현을 언제 쓰는지, 어떤 느낌이 있는지 다른 단어들과 비교해서 자세하게 $l1로 설명"}
{"대화_예시": {"대화": [{"speaker": "A", "line": "($l1 대화)"}, {"speaker": "B", "line": "($l1 대화)"}]}}
{"대화_예시": {"대화": [{"speaker": "A", "line": "($l1 대화)"}, {"speaker": "B", "line": "($l1 대화)"}]}}
{"비슷한_표현": {"단어": "($l1 단어)", "뜻": "($l1 뜻)"}}
{"비슷한_표현": {"단어": "($l1 단어)", "뜻": "($l1 뜻)"}}
(만약 다른 비슷한 표현이 있다면 최대 4개까지만 추가)

''';

      // 생성된 프롬프트 확인
      print('=== 생성된 프롬프트 ===');
      print(prompt);
      print('======================');

      // developer message
      final developerMessage = ChatCompletionMessage.developer(
        content: ChatCompletionDeveloperMessageContent.text(
          '\'$word\'가 $l1로 뭔지 궁금해요. $l1로 친절하게 설명해주세요.',
        ),
        role: ChatCompletionMessageRole.developer,
      );

      // user message
      final userMessage = ChatCompletionMessage.user(
        content: ChatCompletionUserMessageContent.string(prompt),
        role: ChatCompletionMessageRole.user,
      );

      // 이전 진행 중인 스트림이 있다면 즉시 취소하여 지연을 방지
      _subscription?.cancel();

      final stream = usingProModel
          // 프로 모델에서는 serviceTier을 설정해서 속도를 높임
          ? client.createChatCompletionStream(
              request: CreateChatCompletionRequest(
                model: ChatCompletionModel.modelId(_proModel),
                messages: [developerMessage, userMessage],
                serviceTier: CreateChatCompletionRequestServiceTier.auto,
              ),
            )
          : client.createChatCompletionStream(
              request: CreateChatCompletionRequest(
                model: ChatCompletionModel.modelId(_freeModel),
                messages: [developerMessage, userMessage],
              ),
            );

      _subscription = stream.listen(
        (event) {
          final deltaText = event.choices!.first.delta?.content ?? '';
          if (deltaText != '') onDelta(deltaText.toString());
        },
        onDone: onComplete,
        onError: onError,
      );
    } catch (e) {
      print('OpenAI API 호출 오류: $e');
    }
  }

  /*===============================================
  L1 단어 정의 생성
  ===============================================*/

  static void getL1WordDefinition(
    String word,
    String l1,
    String l2,
    ChatDeltaCallback onDelta,
    ChatCompleteCallback onComplete,
    ChatErrorCallback onError, {
    bool usingProModel = false,
  }) async {
    try {
      // 언어 설정 확인을 위한 로그
      print('=== OpenAI 서비스 언어 설정 ===');
      print('검색 단어: $word');
      print('출발 언어: $l1');
      print('도착 언어: $l2');
      print('==============================');

      final prompt =
          '''
단어 '$word'를 $l2로 알고 싶어요. 아래 예시와 같은 NDJSON 형식으로 출력해주세요.
단, 모든 설명은 $l1로 해주세요.

[출력 형식 규칙]
1. NDJSON은 반드시 아래의 형식으로 출력한다.
2. "단어"에 '$word'를 넣는다. 단, '$word'에 오타가 있으면 오타를 수정해서 "단어"에 표기한다.
3. 만약 검색 결과가 없다면 아래 규칙을 모두 무시하고 "No result"라는 문자열만 출력할 것. 다른 문자열은 출력하지 않는다.
4. "품사", "뉘앙스" 항목은 반드시 $l1로 작성한다. "번역단어"는 반드시 $l2로 작성한다.
5. "대화_예시"는 총 2세트. 하나의 세트는 $l2 대화와 번역된 $l1 대화로 구성. 순서는 $l2 대화부터.
6. "비슷한_표현"은 총 최대 4개. $l2 단어를 작성하고 그 뜻은 $l1로 작성한다.
7. "번역단어"와 "비슷한_표현"에서 중국어가 있을 경우 改变 (gǎibiàn)처럼 한어병음을 함께 표기한다.

아래는 영어 단어 'change'를 검색하고 중국어로 설명한 예시입니다. 형식만 참고해서 출력해주세요.

{"단어": "change"}
{"단어_뜻": {"품사": "($l1로 작성)", "번역": {"번역단어": "($l2로 작성)", "뉘앙스": "($word의 뉘앙스와 사용하는 상황을 $l1로 친절하게 설명)"}}}
(다른 뜻이 있거나, 다른 품사의 단어가 있다면 추가)
{"대화_예시": {"대화1": [{"speaker": "A", "line": "($l2 대화)"}, {"speaker": "B", "line": "($l2 대화)"}], "대화2": [{"speaker": "A", "line": "($l1 대화)"}, {"speaker": "B", "line": "($l1 대화)"}]}}
{"대화_예시": {"대화1": [{"speaker": "A", "line": "($l2 대화)"}, {"speaker": "B", "line": "($l2 대화)"}], "대화2": [{"speaker": "A", "line": "($l1 대화)"}, {"speaker": "B", "line": "($l1 대화)"}]}}
{"비슷한_표현": {"단어": "($l2 단어)", "뜻": "($l1 뜻)"}}
{"비슷한_표현": {"단어": "($l2 단어)", "뜻": "($l1 뜻)"}}
(만약 다른 비슷한 표현이 있다면 최대 4개까지만 추가)

''';

      // 생성된 프롬프트 확인
      print('=== 생성된 프롬프트 ===');
      print(prompt);
      print('======================');

      // developer message
      final developerMessage = ChatCompletionMessage.developer(
        content: ChatCompletionDeveloperMessageContent.text(
          '\'$word\'가 $l2로 뭔지 궁금해요. $l1로 친절하게 설명해주세요.',
        ),
        role: ChatCompletionMessageRole.developer,
      );

      // user message
      final userMessage = ChatCompletionMessage.user(
        content: ChatCompletionUserMessageContent.string(prompt),
        role: ChatCompletionMessageRole.user,
      );

      // 이전 진행 중인 스트림이 있다면 즉시 취소하여 지연을 방지
      _subscription?.cancel();

      final stream = usingProModel
          // 프로 모델에서는 serviceTier을 설정해서 속도를 높임
          ? client.createChatCompletionStream(
              request: CreateChatCompletionRequest(
                model: ChatCompletionModel.modelId(_proModel),
                messages: [developerMessage, userMessage],
                serviceTier: CreateChatCompletionRequestServiceTier.auto,
              ),
            )
          : client.createChatCompletionStream(
              request: CreateChatCompletionRequest(
                model: ChatCompletionModel.modelId(_freeModel),
                messages: [developerMessage, userMessage],
              ),
            );

      _subscription = stream.listen(
        (event) {
          final deltaText = event.choices!.first.delta?.content ?? '';
          if (deltaText != '') onDelta(deltaText.toString());
        },
        onDone: onComplete,
        onError: onError,
      );
    } catch (e) {
      print('OpenAI API 호출 오류: $e');
    }
  }

  /*===============================================
  L2 단어 정의 생성
  ===============================================*/

  static void getL2WordDefinition(
    String word,
    String l1,
    String l2,
    ChatDeltaCallback onDelta,
    ChatCompleteCallback onComplete,
    ChatErrorCallback onError, {
    bool usingProModel = false,
  }) async {
    try {
      // 언어 설정 확인을 위한 로그
      print('=== OpenAI 서비스 언어 설정 ===');
      print('검색 단어: $word');
      print('출발 언어: $l1');
      print('도착 언어: $l2');
      print('==============================');

      final prompt =
          '''
단어 '$word'의 $l1 뜻을 알고 싶어요. 아래 예시와 같은 NDJSON 형식으로 출력해주세요.
단, 모든 설명은 $l1로 해주세요.

[출력 형식 규칙]
1. NDJSON은 반드시 아래의 형식으로 출력한다.
2. 검색 단어에 오타가 있으면 오타를 수정해서 "단어"에 표기한다.
3. 만약 검색 결과가 없다면 아래 규칙을 모두 무시하고 "No result"라는 문자열만 출력할 것. 다른 문자열은 출력하지 않는다.
4. "품사", "뉘앙스", "번역단어" 항목은 반드시 $l1로 작성한다.
5. "대화_예시"는 총 2세트. 하나의 세트는 $l2 대화와 번역된 $l1 대화로 구성. 순서는 $l2 대화부터.
6. "비슷한_표현"은 총 최대 4개. $l2 단어를 작성하고 그 뜻은 $l1로 작성한다.
7. "번역단어"와 "비슷한_표현"에서 중국어가 있을 경우 改变 (gǎibiàn)처럼 한어병음을 함께 표기한다.

{"단어": "$word"}
{"단어_뜻": {"품사": "($l1로 작성)", "번역": {"번역단어": "($l1로 작성)", "뉘앙스": "(이 경우 '$word'를 언제 쓰는지 $l1로 친절하게 설명)"}}}
(다른 뜻이 있거나, 다른 품사의 단어가 있다면 추가)
{"대화_예시": {"대화1": [{"speaker": "A", "line": "($l2 대화)"}, {"speaker": "B", "line": "($l2 대화)"}], "대화2": [{"speaker": "A", "line": "($l1 대화)"}, {"speaker": "B", "line": "($l1 대화)"}]}}
{"대화_예시": {"대화1": [{"speaker": "A", "line": "($l2 대화)"}, {"speaker": "B", "line": "($l2 대화)"}], "대화2": [{"speaker": "A", "line": "($l1 대화)"}, {"speaker": "B", "line": "($l1 대화)"}]}}
{"비슷한_표현": {"단어": "($l2 단어)", "뜻": "($l1 뜻)"}}
{"비슷한_표현": {"단어": "($l2 단어)", "뜻": "($l1 뜻)"}}
(만약 다른 비슷한 표현이 있다면 최대 4개까지만 추가)

''';

      // 생성된 프롬프트 확인
      print('=== 생성된 프롬프트 ===');
      print(prompt);
      print('======================');

      // developer message
      final developerMessage = ChatCompletionMessage.developer(
        content: ChatCompletionDeveloperMessageContent.text(
          '\'$word\'가 무슨 뜻인지 궁금해요. $l1로 친절하게 설명해주세요.',
        ),
        role: ChatCompletionMessageRole.developer,
      );

      // user message
      final userMessage = ChatCompletionMessage.user(
        content: ChatCompletionUserMessageContent.string(prompt),
        role: ChatCompletionMessageRole.user,
      );

      // 이전 진행 중인 스트림이 있다면 즉시 취소하여 지연을 방지
      _subscription?.cancel();

      final stream = usingProModel
          // 프로 모델에서는 serviceTier을 설정해서 속도를 높임
          ? client.createChatCompletionStream(
              request: CreateChatCompletionRequest(
                model: ChatCompletionModel.modelId(_proModel),
                messages: [developerMessage, userMessage],
                serviceTier: CreateChatCompletionRequestServiceTier.auto,
              ),
            )
          : client.createChatCompletionStream(
              request: CreateChatCompletionRequest(
                model: ChatCompletionModel.modelId(_freeModel),
                messages: [developerMessage, userMessage],
              ),
            );

      _subscription = stream.listen(
        (event) {
          final deltaText = event.choices!.first.delta?.content ?? '';
          if (deltaText != '') onDelta(deltaText.toString());
        },
        onDone: onComplete,
        onError: onError,
      );
    } catch (e) {
      print('OpenAI API 호출 오류: $e');
    }
  }

  static Future<String> translateText(
    String text,
    String fromLanguage,
    String toLanguage,
    String toneInstruction,
    bool usingProModel,
  ) async {
    try {
      final prompt =
          '''
다음 텍스트를 $fromLanguage에서 $toLanguage로 번역해주세요.
$toneInstruction

번역할 텍스트: "$text"

번역 결과만 출력하고 다른 설명은 포함하지 마세요.
''';

      final developerMessage = ChatCompletionMessage.developer(
        content: ChatCompletionDeveloperMessageContent.text(
          "You are a professional translator. Translate the given text accurately according to the specified tone and style. Respond only with the translated text without any additional comments or explanations.",
        ),
        role: ChatCompletionMessageRole.developer,
      );
      final userMessage = ChatCompletionMessage.user(
        content: ChatCompletionUserMessageContent.string(prompt),
        role: ChatCompletionMessageRole.user,
      );

      // the actual request.
      final res = usingProModel
          ? await client.createChatCompletion(
              request: CreateChatCompletionRequest(
                model: ChatCompletionModel.modelId(_proModel),
                messages: [developerMessage, userMessage],
              ),
            )
          : await client.createChatCompletion(
              request: CreateChatCompletionRequest(
                model: ChatCompletionModel.modelId(_freeModel),
                messages: [developerMessage, userMessage],
              ),
            );

      return res.choices.first.message.content != null
          ? res.choices.first.message.content.toString()
          : '번역을 생성할 수 없습니다.';
    } catch (e) {
      print('OpenAI API 호출 오류: $e');
      return '죄송합니다. 현재 번역 서비스를 이용할 수 없습니다. 잠시 후 다시 시도해주세요.';
    }
  }
}
