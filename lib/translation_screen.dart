import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/language_service.dart';
import 'services/openai_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => TranslationScreenState();
}

class TranslationScreenState extends State<TranslationScreen> {
  // 언어 선택을 위한 상태 변수들
  String selectedFromLanguage = '영어';
  String selectedToLanguage = '한국어';
  StreamSubscription? _languageSubscription;

  // 번역 분위기 설정
  double selectedToneLevel = 1.0; // 0: 친함, 1: 기본, 2: 공손, 3: 격식
  List<String> get toneLabels => [
    AppLocalizations.of(context).friendly,
    AppLocalizations.of(context).basic,
    AppLocalizations.of(context).polite,
    AppLocalizations.of(context).formal,
  ];
  bool isTonePickerExpanded = false;

  // 번역 관련 변수들
  final TextEditingController _inputController = TextEditingController();
  String _translatedText = '';
  bool _isLoading = false;
  final _scrollController = ScrollController();

  // 동적 높이 관리를 위한 변수들
  double _inputFieldHeight = 200.0;
  double _resultFieldHeight = 200.0;
  static const double _minFieldHeight = 200.0;
  static const double _maxFieldHeight = 400.0;

  @override
  void initState() {
    super.initState();
    // LanguageService에서 저장된 언어 설정 불러오기
    selectedFromLanguage = LanguageService.fromLanguage;
    selectedToLanguage = LanguageService.toLanguage;

    // 언어 변경 스트림 구독
    _languageSubscription = LanguageService.languageStream.listen((languages) {
      setState(() {
        selectedFromLanguage = languages['fromLanguage']!;
        selectedToLanguage = languages['toLanguage']!;
      });
    });

    // Language Detector 초기화
    initLanguageDetector();

    // 텍스트 변경 리스너 추가
    _inputController.addListener(_updateInputFieldHeight);
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
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
  void _updateInputFieldHeight() {
    final text = _inputController.text;
    if (text.isEmpty) {
      setState(() {
        _inputFieldHeight = 200.0;
      });
      return;
    }

    // 텍스트의 예상 높이 계산
    final textStyle = TextStyle(fontSize: 16, height: 1.4);
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    textPainter.layout(
      maxWidth: MediaQuery.of(context).size.width - 80,
    ); // 패딩 고려

    final textHeight = textPainter.height;
    final headerHeight = 60.0; // 헤더 영역 높이
    final padding = 32.0; // 상하 패딩
    final totalRequiredHeight = textHeight + headerHeight + padding;

    setState(() {
      _inputFieldHeight = totalRequiredHeight.clamp(
        _minFieldHeight,
        _maxFieldHeight,
      );
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
    textPainter.layout(
      maxWidth: MediaQuery.of(context).size.width - 80,
    ); // 패딩 고려

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
    // LanguageService에 저장
    LanguageService.setTranslationLanguages(fromLang, toLang);
  }

  // 텍스트 복사 함수
  void _copyToClipboard(String text, String message) {
    final themeService = context.read<ThemeService>();
    final colors = themeService.colors;

    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: colors.primary,
      textColor: colors.text,
    );
  }

  Future<void> _translateText() async {
    if (_inputController.text.trim().isEmpty) return;

    final temp = langdetect.detect(_inputController.text.trim());

    String detectedLanguageByLangDetect = temp == 'zh-ch' ? 'zh' : temp;
    detectedLanguageByLangDetect = temp == 'zh-tw' ? 'zh-TW' : temp;

    final selectedLanguageCode = LanguageService.getLanguageCode(
      selectedFromLanguage,
    );

    if (detectedLanguageByLangDetect != selectedLanguageCode) {
      // 언어 확인 팝업 띄우기
      final themeService = context.read<ThemeService>();
      final colors = themeService.colors;

      bool? shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: AppLocalizations.of(context).selected_input_language,
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: selectedFromLanguage,
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          content: Text(
            AppLocalizations.of(context).is_this_language_correct,
            style: TextStyle(fontSize: 14),
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
          toneInstruction = '친근하고 편안한 톤으로 번역해주세요. 반말로 친구 사이에 사용하는 표현을 사용해주세요.';
          break;
        case 1: // 기본
          toneInstruction = '기본적이고 중립적인 톤으로 존대말로 번역해주세요.';
          break;
        case 2: // 공손
          toneInstruction = '공손하고 예의 바른 톤으로 번역해주세요.';
          break;
        case 3: // 격식
          toneInstruction = '격식 있고 공식적인 톤으로 번역해주세요.';
          break;
      }

      final translatedText = await OpenAIService.translateText(
        _inputController.text.trim(),
        selectedFromLanguage,
        selectedToLanguage,
        toneInstruction,
      );

      setState(() {
        _translatedText = translatedText;
      });

      // 번역 결과가 업데이트되면 결과 필드 높이도 업데이트
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateResultFieldHeight();
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              _buildLanguageSelector(colors),
              const SizedBox(height: 20),
              _buildTonePicker(colors),
              const SizedBox(height: 20),
              _buildTranslationArea(colors),
            ],
          ),
        ),
      ),
    );
  }

  // 언어 선택 영역
  Widget _buildLanguageSelector(CustomColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildFromLanguageDropdown(colors),
        const SizedBox(width: 20),
        _buildLanguageSwapButton(colors),
        const SizedBox(width: 20),
        _buildToLanguageDropdown(colors),
      ],
    );
  }

  // 출발 언어 선택 드롭다운
  Widget _buildFromLanguageDropdown(CustomColors colors) {
    return SizedBox(
      width: 140,
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
                      child: Text(
                        item['name']!,
                        style: TextStyle(fontSize: 20, color: colors.text),
                      ),
                    ),
                  )
                  .toList(),
          value: selectedFromLanguage,
          onChanged: (String? newValue) {
            if (newValue == null) return;
            _updateLanguages(newValue, selectedToLanguage);
          },
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            width: 140,
          ),
          menuItemStyleData: const MenuItemStyleData(height: 40),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: colors.light,
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
      child: Icon(Icons.arrow_forward_ios, color: colors.text),
    );
  }

  // 도착 언어 선택 드롭다운
  Widget _buildToLanguageDropdown(CustomColors colors) {
    return SizedBox(
      width: 140,
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
                      child: Text(
                        item['name']!,
                        style: TextStyle(fontSize: 20, color: colors.text),
                      ),
                    ),
                  )
                  .toList(),
          value: selectedToLanguage,
          onChanged: (String? newValue) {
            if (newValue == null) return;
            _updateLanguages(selectedFromLanguage, newValue);
          },
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            width: 140,
          ),
          menuItemStyleData: const MenuItemStyleData(height: 40),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: colors.light,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  // 번역 분위기 설정 슬라이더
  Widget _buildTonePicker(CustomColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.light,
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
              padding: const EdgeInsets.all(20),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                                  fontSize: 14,
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
                                  size: 16,
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
                      inactiveTrackColor: colors.light,
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
                                color: isSelected ? colors.text : colors.dark,
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
                                    ? colors.text
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
    );
  }

  // 번역 영역 (입력창, 버튼, 결과창)
  Widget _buildTranslationArea(CustomColors colors) {
    return Column(
      children: [
        _buildInputField(colors),
        const SizedBox(height: 20),
        _buildTranslateButton(colors),
        const SizedBox(height: 20),
        _buildResultField(colors),
      ],
    );
  }

  // 입력창
  Widget _buildInputField(CustomColors colors) {
    return Container(
      height: _inputFieldHeight,
      decoration: BoxDecoration(
        color: colors.light,
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
                    Icon(Icons.edit, color: colors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).input_text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textLight,
                      ),
                    ),
                  ],
                ),
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
          ),
          Expanded(
            child: TextField(
              controller: _inputController,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).input_text_hint,
                hintStyle: TextStyle(color: colors.textLight, fontSize: 16),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              ),
              style: TextStyle(color: colors.text, fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // 번역 버튼
  Widget _buildTranslateButton(CustomColors colors) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [colors.primary, colors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _translateText,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(colors.text),
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.translate, color: colors.text, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context).translate_button,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
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
        color: colors.light,
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
                        fontSize: 14,
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
                GestureDetector(
                  onTap: () {
                    if (_translatedText.isNotEmpty &&
                        _translatedText !=
                            AppLocalizations.of(
                              context,
                            ).translation_result_hint) {
                      _copyToClipboard(
                        _translatedText,
                        AppLocalizations.of(context).translation_result_copied,
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
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SingleChildScrollView(
                child: Text(
                  _translatedText.isEmpty
                      ? AppLocalizations.of(context).translation_result_hint
                      : _translatedText,
                  style: TextStyle(
                    color: _translatedText.isEmpty
                        ? colors.textLight
                        : colors.text,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
