import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'services/language_service.dart';
import 'services/openai_service.dart';
import 'services/theme_service.dart';
import 'services/pro_service.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import 'services/tutorial_service.dart';
import 'package:lpinyin/lpinyin.dart';

final GlobalKey _langSelectorKey = GlobalKey();
final GlobalKey _tonePickerKey = GlobalKey();

// 무료 버전에서는 일정 길이 이상 입력 시 잘라냅니다.
final int maxInputLengthInFreeVersion = 500;

// 번역 화면의 진입 위젯. 상태를 가지는 화면으로 입력/번역/결과 UI를 포함합니다.
class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => TranslationScreenState();
}

class TranslationScreenState extends State<TranslationScreen> {
  // 언어 선택을 위한 상태 변수들 (드롭다운과 연동)
  String selectedFromLanguage = '영어';
  String selectedToLanguage = '한국어';

  // 번역 분위기 설정
  double selectedToneLevel = 1.0; // 0: 친함, 1: 기본, 2: 공손, 3: 격식
  List<String> get toneLabels => [
    AppLocalizations.of(context).friendly,
    AppLocalizations.of(context).basic,
    AppLocalizations.of(context).polite,
    AppLocalizations.of(context).formal,
  ];
  bool isTonePickerExpanded = false;

  // 번역 관련 변수들 (입력 컨트롤러, 로딩 상태, 스크롤 제어)
  final TextEditingController _inputController = TextEditingController();
  String _translatedText = '';
  bool _isLoading = false;
  final _scrollController = ScrollController();

  // ShowCase 빌더 컨텍스트 보관
  BuildContext? _showcaseContext;

  // 입력/결과 영역 높이 관리 변수들
  // 요구사항에 따라 입력창은 고정 높이를 사용합니다(_minFieldHeight).
  double _inputFieldHeight = 200.0;
  double _resultFieldHeight = 200.0;
  static const double _minFieldHeight = 200.0;
  static const double _maxFieldHeight = 400.0;

  // 실행취소를 위한 변수들
  String? _lastInputText;
  String? _lastResultText;
  bool _inputCleared = false;
  bool _resultCleared = false;

  @override
  void initState() {
    super.initState();
    // 번역 화면 전용 언어 설정 불러오기 (전역 from/to와 분리)
    _loadTranslationScreenLanguages();

    // 언어 감지 라이브러리 초기화 (입력 언어 확인용)
    initLanguageDetector();

    // 입력 텍스트 변경 시 높이 업데이트 (고정 높이 유지)
    _inputController.addListener(_updateInputFieldHeight);

    // 번역 쇼케이스 노티파이어 구독 (탭 전환 등 런타임 트리거 대응)
    TutorialService.translationShowcaseNotifier.addListener(
      _onTranslationShowcaseEvent,
    );
  }

  void _onTranslationShowcaseEvent() {
    _maybeStartTranslationShowcase();
  }

  void _maybeStartTranslationShowcase() {
    if (!mounted) return;
    if (_showcaseContext == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final alreadyShown = await TutorialService.wasTranslationShowcaseShown();
      if (alreadyShown) return;
      if (TutorialService.consumeTranslationShowcaseTrigger()) {
        ShowCaseWidget.of(
          _showcaseContext!,
        ).startShowCase([_langSelectorKey, _tonePickerKey]);
        await TutorialService.markTranslationShowcaseShown();
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    TutorialService.translationShowcaseNotifier.removeListener(
      _onTranslationShowcaseEvent,
    );
    super.dispose();
  }

  Future<void> initLanguageDetector() async {
    try {
      await langdetect.initLangDetect();
    } catch (e) {
      print(e);
    }
  }

  // 입력 필드 높이 업데이트 함수
  // 고정 높이 정책에 따라 항상 _minFieldHeight로 설정합니다.
  void _updateInputFieldHeight() {
    setState(() {
      _inputFieldHeight = _minFieldHeight;
    });
  }

  // 결과 필드 높이 업데이트 함수
  void _updateResultFieldHeight() {
    if (_translatedText.isEmpty) {
      setState(() {
        _resultFieldHeight = 200.0;
      });
      return;
    }

    // 텍스트의 예상 높이 계산
    final textStyle = TextStyle(fontSize: 16, height: 1.4);
    final textSpan = TextSpan(text: _translatedText, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    textPainter.layout(maxWidth: 300); // 패딩 고려

    final textHeight = textPainter.height;
    final headerHeight = 60.0; // 헤더 영역 높이
    final padding = 32.0; // 상하 패딩
    final totalRequiredHeight = textHeight + headerHeight + padding;

    setState(() {
      _resultFieldHeight = totalRequiredHeight.clamp(
        _minFieldHeight,
        _maxFieldHeight,
      );
    });
  }

  void _updateLanguages(String fromLang, String toLang) {
    setState(() {
      selectedFromLanguage = fromLang;
      selectedToLanguage = toLang;
    });
    // 번역 화면 전용 저장소에 저장 (전역 from/to와 분리)
    LanguageService.setTranslationScreenLanguages(fromLang, toLang);
  }

  // 번역 화면 전용 언어 설정 로딩
  Future<void> _loadTranslationScreenLanguages() async {
    final from = await LanguageService.getTranslationScreenFromLanguage();
    final to = await LanguageService.getTranslationScreenToLanguage();
    if (!mounted) return;
    setState(() {
      selectedFromLanguage = from;
      selectedToLanguage = to;
    });
  }

  // 드롭다운 아이템 길이에 따라 폰트 크기를 조정합니다.
  double _getDropdownFontSize(String text, {bool isSelected = false}) {
    final int length = text.length;
    if (isSelected) {
      if (length > 18) return 14.0;
      if (length > 12) return 14.0;
      if (length > 5) return 15.0;
      return 18.0;
    } else {
      if (length > 18) return 12.0;
      if (length > 12) return 14.0;
      if (length > 5) return 15.0;
      return 16.0;
    }
  }

  // 텍스트 복사 함수
  // 공용 복사 함수: 텍스트를 클립보드에 복사하고 토스트 메시지를 표시합니다.
  void _copyToClipboard(String text, String message) {
    final themeService = context.read<ThemeService>();
    final colors = themeService.colors;

    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: colors.light,
      textColor: colors.text,
    );
  }

  Future<void> _translateText() async {
    if (_inputController.text.trim().isEmpty) return;

    // 키보드 숨기기: 번역 중 불필요한 포커스 방지
    FocusScope.of(context).unfocus();

    final temp = langdetect.detect(_inputController.text.trim());

    String detectedLanguageByLangDetect = temp == 'zh-ch' ? 'zh' : temp;
    detectedLanguageByLangDetect = temp == 'zh-tw' ? 'zh-TW' : temp;

    final selectedLanguageCode = LanguageService.getLanguageCode(
      selectedFromLanguage,
    );

    if (detectedLanguageByLangDetect != selectedLanguageCode) {
      // 언어 확인 팝업 띄우기 (감지 언어와 선택 언어가 다를 때 사용자 확인)
      final themeService = context.read<ThemeService>();
      final colors = themeService.colors;

      bool? shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).selected_input_language,
                style: TextStyle(
                  fontSize: 16,
                  color: colors.text,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                LanguageService.getLocalizedTranslationLanguages(
                  AppLocalizations.of(context),
                ).firstWhere(
                  (item) => item['code'] == selectedFromLanguage,
                )['name']!,
                style: TextStyle(
                  fontSize: 18,
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context).is_this_language_correct,
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context).no),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context).yes),
            ),
          ],
        ),
      );

      // '아니요'를 선택했거나 다이얼로그를 닫았으면 번역 취소
      if (shouldContinue != true) {
        // 다이얼로그가 닫힌 후에도 입력창에 포커스가 가지 않도록
        // 약간 딜레이를 주고 unfocus를 한 번 더 호출합니다.
        FocusScope.of(context).unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          FocusScope.of(context).unfocus();
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String toneInstruction = '';
      int toneIndex = selectedToneLevel.round();

      switch (toneIndex) {
        case 0: // 친구
          toneInstruction = '친구에게 말하듯이 친근하고 편안한 말투로 번역해주세요.';
          break;
        case 1: // 기본
          toneInstruction = '기본적이고 중립적인 톤으로 존대말로 번역해주세요.';
          break;
        case 2: // 공손
          toneInstruction = '공적인 자리에서 사용할 수 있도록 공손하고 예의 바른 톤으로 번역해주세요.';
          break;
        case 3: // 격식
          toneInstruction = '문서에서 사용하려고 합니다. 격식 있고 공식적인 톤으로 번역해주세요.';
          break;
      }

      // PRO 사용자는 프로 모델 사용
      final bool usingProModel = context.read<ProService>().isPro;

      final translatedText = await OpenAIService.translateText(
        _inputController.text.trim(),
        selectedFromLanguage,
        selectedToLanguage,
        toneInstruction,
        usingProModel,
      );

      setState(() {
        _translatedText = translatedText;
      });

      // 번역 결과가 업데이트되면 결과 필드 높이 업데이트 후 맨 밑으로 스크롤합니다.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateResultFieldHeight();
        // 맨 밑으로 스크롤
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _translatedText = AppLocalizations.of(context).translation_error;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final colors = themeService.colors;

    return ShowCaseWidget(
      builder: (ctx) {
        _showcaseContext = ctx;
        // 초기 진입 시에도 한 번 체크
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          final alreadyShown =
              await TutorialService.wasTranslationShowcaseShown();
          if (alreadyShown) return;
          if (TutorialService.consumeTranslationShowcaseTrigger()) {
            ShowCaseWidget.of(
              ctx,
            ).startShowCase([_langSelectorKey, _tonePickerKey]);
            await TutorialService.markTranslationShowcaseShown();
          }
        });
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context).translation,
              style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
            ),
            backgroundColor: colors.background,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  _buildLanguageSelector(colors),
                  const SizedBox(height: 20),
                  _buildTonePicker(colors),
                  const SizedBox(height: 10),
                  _buildTranslationArea(colors),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 언어 선택 영역
  Widget _buildLanguageSelector(CustomColors colors) {
    return Showcase(
      key: _langSelectorKey,
      title: AppLocalizations.of(
        context,
      ).tutorial_translate_language_selector_title,
      description:
          AppLocalizations.of(
            context,
          ).tutorial_translate_language_selector_desc +
          "ㅤ",
      titleTextAlign: TextAlign.center,
      titleTextStyle: TextStyle(
        color: colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titlePadding: EdgeInsets.only(top: 8),
      descTextStyle: TextStyle(color: colors.white, fontSize: 13),
      descriptionPadding: EdgeInsets.only(top: 4),
      descriptionTextAlign: TextAlign.center,
      tooltipBackgroundColor: colors.primary,
      disableMovingAnimation: true,
      targetPadding: EdgeInsets.all(10),
      tooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          name: 'Skip All',
          textStyle: TextStyle(color: colors.white.withValues(alpha: 0.5)),
          backgroundColor: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          padding: EdgeInsets.only(top: 3, right: 8),
          name: '1/2',
          textStyle: TextStyle(
            color: colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
          backgroundColor: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          padding: EdgeInsets.only(left: 10, right: 14, top: 2, bottom: 2),
          name: 'Next',
          textStyle: TextStyle(color: colors.white),
          backgroundColor: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
      tooltipActionConfig: const TooltipActionConfig(
        alignment: MainAxisAlignment.spaceBetween,
        gapBetweenContentAndAction: 10,
        position: TooltipActionPosition.outside,
      ),

      child: Row(
        children: <Widget>[
          Expanded(flex: 5, child: _buildFromLanguageDropdown(colors)),
          Expanded(
            flex: 2,
            child: Center(child: _buildLanguageSwapButton(colors)),
          ),
          Expanded(flex: 5, child: _buildToLanguageDropdown(colors)),
        ],
      ),
    );
  }

  // 출발 언어 선택 드롭다운
  Widget _buildFromLanguageDropdown(CustomColors colors) {
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Select Item',
            style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
          ),
          items:
              LanguageService.getLocalizedTranslationLanguages(
                    AppLocalizations.of(context),
                  )
                  .map(
                    (Map<String, String> item) => DropdownMenuItem<String>(
                      value: item['code']!,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['name']!,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: _getDropdownFontSize(item['name']!),
                                color: colors.text,
                                height: 1.1,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          if (item['code'] == selectedFromLanguage)
                            Icon(Icons.check, size: 16, color: colors.primary),
                        ],
                      ),
                    ),
                  )
                  .toList(),
          selectedItemBuilder: (context) {
            final items = LanguageService.getLocalizedTranslationLanguages(
              AppLocalizations.of(context),
            );
            return items
                .map(
                  (item) => Center(
                    child: Text(
                      item['name']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _getDropdownFontSize(
                          item['name']!,
                          isSelected: true,
                        ),
                        color: colors.text,
                        height: 1.1,
                      ),
                    ),
                  ),
                )
                .toList();
          },
          iconStyleData: IconStyleData(
            icon: SizedBox(
              width: 14,
              child: Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: colors.textLight,
              ),
            ),
            openMenuIcon: SizedBox(
              width: 14,
              child: Icon(
                Icons.arrow_drop_up,
                size: 18,
                color: colors.textLight,
              ),
            ),
            iconSize: 18,
          ),
          value: selectedFromLanguage,
          onChanged: (String? newValue) {
            if (newValue == null) return;
            // 동일 언어 선택 시 스왑 처리하여 from/to가 같지 않도록 보장
            if (newValue == selectedToLanguage) {
              _updateLanguages(selectedToLanguage, selectedFromLanguage);
            } else {
              _updateLanguages(newValue, selectedToLanguage);
            }
          },
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 40,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.primary)),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(height: 46),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  // 언어 교환 버튼
  Widget _buildLanguageSwapButton(CustomColors colors) {
    return GestureDetector(
      onTap: () {
        _updateLanguages(selectedToLanguage, selectedFromLanguage);
      },
      child: Container(
        width: 36,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: colors.primary,
          shape: BoxShape.rectangle,
        ),
        child: Center(
          child: Icon(Icons.arrow_forward_ios, color: colors.white, size: 16),
        ),
      ),
    );
  }

  // 도착 언어 선택 드롭다운
  Widget _buildToLanguageDropdown(CustomColors colors) {
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Select Item',
            style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
          ),
          items:
              LanguageService.getLocalizedTranslationLanguages(
                    AppLocalizations.of(context),
                  )
                  .map(
                    (Map<String, String> item) => DropdownMenuItem<String>(
                      value: item['code']!,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['name']!,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: _getDropdownFontSize(item['name']!),
                                color: colors.text,
                                height: 1.1,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          if (item['code'] == selectedToLanguage)
                            Icon(Icons.check, size: 16, color: colors.primary),
                        ],
                      ),
                    ),
                  )
                  .toList(),
          selectedItemBuilder: (context) {
            final items = LanguageService.getLocalizedTranslationLanguages(
              AppLocalizations.of(context),
            );
            return items
                .map(
                  (item) => Center(
                    child: Text(
                      item['name']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _getDropdownFontSize(
                          item['name']!,
                          isSelected: true,
                        ),
                        color: colors.text,
                        height: 1.1,
                      ),
                    ),
                  ),
                )
                .toList();
          },
          iconStyleData: IconStyleData(
            icon: SizedBox(
              width: 14,
              child: Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: colors.textLight,
              ),
            ),
            openMenuIcon: SizedBox(
              width: 14,
              child: Icon(
                Icons.arrow_drop_up,
                size: 18,
                color: colors.textLight,
              ),
            ),
            iconSize: 18,
          ),
          value: selectedToLanguage,
          onChanged: (String? newValue) {
            if (newValue == null) return;
            // 동일 언어 선택 시 스왑 처리하여 from/to가 같지 않도록 보장
            if (newValue == selectedFromLanguage) {
              _updateLanguages(selectedToLanguage, selectedFromLanguage);
            } else {
              _updateLanguages(selectedFromLanguage, newValue);
            }
          },
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 40,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.primary)),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(height: 46),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  // 번역 분위기 설정 슬라이더
  Widget _buildTonePicker(CustomColors colors) {
    return Showcase(
      key: _tonePickerKey,
      title: AppLocalizations.of(context).tutorial_translate_tone_picker_title,
      description:
          AppLocalizations.of(context).tutorial_translate_tone_picker_desc +
          "ㅤ",
      titleTextAlign: TextAlign.center,
      titleTextStyle: TextStyle(
        color: colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titlePadding: EdgeInsets.only(top: 8),
      descTextStyle: TextStyle(color: colors.white, fontSize: 13),
      descriptionPadding: EdgeInsets.only(top: 4),
      descriptionTextAlign: TextAlign.center,
      tooltipBackgroundColor: colors.primary,
      disableMovingAnimation: true,
      targetPadding: EdgeInsets.all(10),
      tooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          name: 'Skip All',
          textStyle: TextStyle(color: colors.white.withValues(alpha: 0.5)),
          backgroundColor: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          padding: EdgeInsets.only(top: 3, right: 8),
          name: '2/2',
          textStyle: TextStyle(
            color: colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
          backgroundColor: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          padding: EdgeInsets.only(left: 10, right: 14, top: 2, bottom: 2),
          name: 'Next',
          textStyle: TextStyle(color: colors.white),
          backgroundColor: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
      tooltipActionConfig: const TooltipActionConfig(
        alignment: MainAxisAlignment.spaceBetween,
        gapBetweenContentAndAction: 10,
        position: TooltipActionPosition.outside,
      ),

      child: Container(
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  isTonePickerExpanded = !isTonePickerExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 14,
                  bottom: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune, color: colors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context).translation_tone,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                        if (!isTonePickerExpanded) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  toneLabels[selectedToneLevel.round()],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textLight,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Container(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: colors.textLight,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isTonePickerExpanded = !isTonePickerExpanded;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isTonePickerExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: colors.text,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isTonePickerExpanded)
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  children: [
                    // 슬라이더
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: colors.textLight,
                        inactiveTrackColor: colors.background,
                        thumbColor: colors.textLight,
                        overlayColor: colors.primary.withValues(alpha: 0.2),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
                      ),
                      child: Slider(
                        value: selectedToneLevel,
                        min: 0,
                        max: 3,
                        divisions: 3,
                        onChanged: (value) {
                          setState(() {
                            selectedToneLevel = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 라벨 표시
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: toneLabels.asMap().entries.map((entry) {
                        int index = entry.key;
                        String label = entry.value;
                        bool isSelected = selectedToneLevel.round() == index;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedToneLevel = index.toDouble();
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.textLight,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? colors.primary
                                      : colors.textLight,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 번역 영역 (입력창, 버튼, 결과창)
  Widget _buildTranslationArea(CustomColors colors) {
    return Column(
      children: [
        _buildInputField(colors),
        const SizedBox(height: 14),
        _buildTranslateButton(colors),
        const SizedBox(height: 14),
        _buildResultField(colors),
      ],
    );
  }

  // 입력창
  // 높이는 고정(_inputFieldHeight)이며, 실제 입력은 전체 화면 에디터에서 수행합니다.
  Widget _buildInputField(CustomColors colors) {
    return Container(
      height: _inputFieldHeight,
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: _inputController.text.isNotEmpty
                          ? colors.primary
                          : colors.textLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).input_text,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // 클리어/실행취소 버튼
                    GestureDetector(
                      onTap: () {
                        if (_inputCleared) {
                          // 실행취소: 원래 텍스트 복원
                          if (_lastInputText != null) {
                            _inputController.text = _lastInputText!;
                            _updateInputFieldHeight();
                          }
                          setState(() {
                            _inputCleared = false;
                            _lastInputText = null;
                          });
                        } else {
                          // 클리어: 현재 텍스트 저장 후 클리어
                          if (_inputController.text.isNotEmpty) {
                            _lastInputText = _inputController.text;
                            _inputController.clear();
                            _updateInputFieldHeight();
                            setState(() {
                              _inputCleared = true;
                            });
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _inputCleared
                              ? colors.primary.withValues(alpha: 0.1)
                              : (_inputController.text.isNotEmpty
                                    ? colors.error.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _inputCleared ? Icons.undo : Icons.clear,
                          size: 16,
                          color: _inputCleared
                              ? colors.text
                              : (_inputController.text.isNotEmpty
                                    ? colors.error
                                    : Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // 복사 버튼
                    GestureDetector(
                      onTap: () {
                        if (_inputController.text.isNotEmpty) {
                          _copyToClipboard(
                            _inputController.text,
                            AppLocalizations.of(context).input_text_copied,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _inputController.text.isNotEmpty
                              ? colors.primary.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.copy,
                          size: 16,
                          color: _inputController.text.isNotEmpty
                              ? colors.text
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 읽기 전용 입력창: 탭하면 전체 화면 에디터를 엽니다.
          Expanded(
            child: TextField(
              controller: _inputController,
              readOnly: true,
              showCursor: false,
              onTap: _openFullScreenEditor,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).input_text_hint,
                hintStyle: TextStyle(color: colors.textLight, fontSize: 15),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              ),
              style: TextStyle(color: colors.text, fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // 전체 화면 에디터로 이동하여 텍스트를 작성/수정하고
  // 결과 문자열을 받아 현재 입력창 컨트롤러에 반영합니다.
  Future<void> _openFullScreenEditor() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const _InputFullScreenEditor(),
        settings: RouteSettings(arguments: _inputController.text),
      ),
    );
    if (result != null) {
      // 무료 버전에서는 일정 길이 이상 입력 시 잘라냅니다.
      final limited = result.length > maxInputLengthInFreeVersion
          ? result.substring(0, maxInputLengthInFreeVersion)
          : result;
      setState(() {
        _inputController.text = limited;
      });
      _updateInputFieldHeight();
    }
  }

  // 번역 버튼
  Widget _buildTranslateButton(CustomColors colors) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        /* color: colors.primary, */
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.9),
            colors.secondary.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.transparent, width: 10),
          color: colors.white,
        ),
        margin: const EdgeInsets.all(3),
        child: InkWell(
          onTap: _isLoading ? null : _translateText,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.translate,
                        color: colors.primary,
                        size: 20,
                        weight: 800,
                      ),
                      const SizedBox(width: 8),
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [colors.primary, colors.secondary],
                          ).createShader(bounds);
                        },
                        child: Text(
                          AppLocalizations.of(context).translate_button,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white, // 반드시 있어야 gradient가 적용됨
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // 번역 결과 영역
  Widget _buildResultField(CustomColors colors) {
    return Container(
      height: _resultFieldHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.translate,
                      color: _translatedText.isEmpty
                          ? colors.textLight
                          : colors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).translation_result,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _translatedText.isEmpty
                            ? colors.textLight
                            : colors.text,
                      ),
                    ),
                    if (_isLoading) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    // 클리어/실행취소 버튼
                    GestureDetector(
                      onTap: () {
                        if (_resultCleared) {
                          // 실행취소: 원래 텍스트 복원
                          if (_lastResultText != null) {
                            setState(() {
                              _translatedText = _lastResultText!;
                              _resultCleared = false;
                              _lastResultText = null;
                            });
                            _updateResultFieldHeight();
                          }
                        } else {
                          // 클리어: 현재 텍스트 저장 후 클리어
                          if (_translatedText.isNotEmpty &&
                              _translatedText !=
                                  AppLocalizations.of(
                                    context,
                                  ).translation_result_hint) {
                            _lastResultText = _translatedText;
                            setState(() {
                              _translatedText = '';
                              _resultCleared = true;
                            });
                            _updateResultFieldHeight();
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _resultCleared
                              ? colors.primary.withValues(alpha: 0.1)
                              : ((_translatedText.isNotEmpty &&
                                        _translatedText !=
                                            AppLocalizations.of(
                                              context,
                                            ).translation_result_hint)
                                    ? colors.error.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _resultCleared ? Icons.undo : Icons.clear,
                          size: 16,
                          color: _resultCleared
                              ? colors.text
                              : ((_translatedText.isNotEmpty &&
                                        _translatedText !=
                                            AppLocalizations.of(
                                              context,
                                            ).translation_result_hint)
                                    ? colors.error
                                    : Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // 복사 버튼
                    GestureDetector(
                      onTap: () {
                        if (_translatedText.isNotEmpty &&
                            _translatedText !=
                                AppLocalizations.of(
                                  context,
                                ).translation_result_hint) {
                          _copyToClipboard(
                            _translatedText,
                            AppLocalizations.of(
                              context,
                            ).translation_result_copied,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              (_translatedText.isNotEmpty &&
                                  _translatedText !=
                                      AppLocalizations.of(
                                        context,
                                      ).translation_result_hint)
                              ? colors.primary.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.copy,
                          size: 16,
                          color:
                              (_translatedText.isNotEmpty &&
                                  _translatedText !=
                                      AppLocalizations.of(
                                        context,
                                      ).translation_result_hint)
                              ? colors.text
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_translatedText.isNotEmpty &&
                    _translatedText !=
                        AppLocalizations.of(context).translation_result_hint) {
                  _openFullScreenResultViewer();
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        _translatedText.isEmpty
                            ? AppLocalizations.of(
                                context,
                              ).translation_result_hint
                            : _translatedText,
                        style: TextStyle(
                          color: _translatedText.isEmpty
                              ? colors.textLight
                              : colors.text,
                          fontSize: 15,
                          height: 1.4,
                        ),
                        onTap: () {
                          if (_translatedText.isNotEmpty &&
                              _translatedText !=
                                  AppLocalizations.of(
                                    context,
                                  ).translation_result_hint) {
                            _openFullScreenResultViewer();
                          }
                        },
                      ),
                      if (RegExp(
                            r'[\u3400-\u9FFF]',
                          ).hasMatch(_translatedText) &&
                          (selectedToLanguage == '중국어' ||
                              selectedToLanguage == '대만 중국어')) ...[
                        const SizedBox(height: 8),
                        Divider(
                          height: 16,
                          color: colors.textLight.withValues(alpha: 0.4),
                          indent: 10,
                          endIndent: 10,
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          PinyinHelper.getPinyin(
                            _translatedText,
                            format: PinyinFormat.WITH_TONE_MARK,
                          ),
                          style: TextStyle(
                            color: colors.textLight,
                            fontSize: 15,
                            height: 1.4,
                          ),
                          onTap: () {
                            if (_translatedText.isNotEmpty) {
                              _openFullScreenResultViewer();
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreenResultViewer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ResultFullScreenViewer(
          text: _translatedText,
          showPinyin:
              RegExp(r'[\u3400-\u9FFF]').hasMatch(_translatedText) &&
              (selectedToLanguage == '중국어' || selectedToLanguage == '대만 중국어'),
        ),
      ),
    );
  }
}

class _InputFullScreenEditor extends StatefulWidget {
  const _InputFullScreenEditor();

  @override
  State<_InputFullScreenEditor> createState() => _InputFullScreenEditorState();
}

class _InputFullScreenEditorState extends State<_InputFullScreenEditor> {
  late final TextEditingController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // 라우트 인자로 넘어온 초기 텍스트를 에디터 컨트롤러에 세팅합니다.
      final args = ModalRoute.of(context)?.settings.arguments;
      final initialText = args is String ? args : '';
      _controller.text = initialText;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  Future<bool> _handleWillPop() async {
    // 뒤로가기 시 현재 작성한 텍스트를 호출자에게 반환합니다.
    // 무료 버전에서는 일정 길이 이상 입력 시 잘라냅니다.
    final text = _controller.text;
    final limited = text.length > maxInputLengthInFreeVersion
        ? text.substring(0, maxInputLengthInFreeVersion)
        : text;
    Navigator.of(context).pop<String>(limited);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final colors = themeService.colors;
    return PopScope(
      canPop: false, // 직접 제어하므로 false
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // 이미 pop 된 경우 추가 처리 X

        final shouldPop = await _handleWillPop();
        if (shouldPop) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: Text(AppLocalizations.of(context).input_text)),
        body: Stack(
          children: [
            // 전체 화면 텍스트 에디터 영역
            Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(bottom: 64),
              color: colors.white,
              child: SingleChildScrollView(
                child: TextField(
                  style: TextStyle(color: colors.text, fontSize: 15),
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  maxLines: null,

                  // 무료 버전에서는 일정 길이 이상 입력 시 잘라냅니다.
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      maxInputLengthInFreeVersion,
                    ),
                  ],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: AppLocalizations.of(context).input_text_hint,
                    filled: true,
                    fillColor: colors.white,
                    contentPadding: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                  ),
                ),
              ),
            ),
            // 하단바 영역: search_result_screen.dart의 초기 하단바 디자인을 참고
            // 키보드가 올라오면 자동으로 키보드 위로 배치되도록 Stack + Positioned 사용
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: false,
                child: BottomAppBar(
                  color: colors.background,
                  height: 64,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          "${_controller.text.length} / $maxInputLengthInFreeVersion",
                          style: TextStyle(
                            color:
                                _controller.text.length >=
                                    maxInputLengthInFreeVersion
                                ? colors.error
                                : colors.text,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // 체크 버튼: 원형 버튼 스타일, 누르면 작성한 텍스트를 반환하고 닫습니다.
                      ElevatedButton(
                        onPressed: () {
                          // 무료 버전에서는 일정 길이 이상 입력 시 잘라냅니다.
                          final text = _controller.text;
                          final limited =
                              text.length > maxInputLengthInFreeVersion
                              ? text.substring(0, maxInputLengthInFreeVersion)
                              : text;
                          Navigator.of(context).pop<String>(limited);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(2),
                          backgroundColor: colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Icon(
                            Icons.check,
                            color: colors.text,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultFullScreenViewer extends StatelessWidget {
  final String text;
  final bool showPinyin;

  const _ResultFullScreenViewer({required this.text, required this.showPinyin});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final colors = themeService.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translation_result),
      ),
      body: Stack(
        children: [
          Container(
            color: colors.white,
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    text.isEmpty
                        ? AppLocalizations.of(context).translation_result_hint
                        : text,
                    style: TextStyle(
                      color: text.isEmpty ? colors.textLight : colors.text,
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),
                  if (showPinyin &&
                      RegExp(r'[\u3400-\u9FFF]').hasMatch(text)) ...[
                    const SizedBox(height: 12),
                    Divider(
                      height: 20,
                      color: colors.textLight.withValues(alpha: 0.4),
                      indent: 10,
                      endIndent: 10,
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      PinyinHelper.getPinyin(
                        text,
                        format: PinyinFormat.WITH_TONE_MARK,
                      ),
                      style: TextStyle(
                        color: colors.textLight,
                        height: 1.6,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),

          // 하단바 영역: search_result_screen.dart의 초기 하단바 디자인을 참고
          // 키보드가 올라오면 자동으로 키보드 위로 배치되도록 Stack + Positioned 사용
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: false,
              child: BottomAppBar(
                color: colors.background,
                height: 64,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        "${text.length}",
                        style: TextStyle(color: colors.text, fontSize: 14),
                      ),
                    ),
                    const Spacer(),
                    // 복사 버튼: 원형 버튼 스타일, 누르면 텍스트가 전체 복사됩니다.
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: text));
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(context).input_text_copied,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(2),
                        backgroundColor: colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Icon(Icons.copy, color: colors.text, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
