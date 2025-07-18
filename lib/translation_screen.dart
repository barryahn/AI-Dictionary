import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/language_service.dart';
import 'services/openai_service.dart';
import 'services/theme_service.dart';
import 'l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

import 'theme/app_colors.dart';

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

  void _updateLanguages(String fromLang, String toLang) {
    setState(() {
      selectedFromLanguage = fromLang;
      selectedToLanguage = toLang;
    });
    // LanguageService에 저장
    LanguageService.setTranslationLanguages(fromLang, toLang);
  }

  // 텍스트 복사 함수
  void _copyToClipboard(String text, String message, AppColors currentTheme) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: currentTheme.primary,
      textColor: Colors.white,
    );
  }

  Future<void> _translateText(AppColors currentTheme) async {
    if (_inputController.text.trim().isEmpty) return;

    final temp = langdetect.detect(_inputController.text.trim());

    String detectedLanguageByLangDetect = temp == 'zh-ch' ? 'zh' : temp;
    detectedLanguageByLangDetect = temp == 'zh-tw' ? 'zh-TW' : temp;

    final selectedLanguageCode = LanguageService.getLanguageCode(
      selectedFromLanguage,
    );

    if (detectedLanguageByLangDetect != selectedLanguageCode) {
      // 언어 확인 팝업 띄우기
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
                    color: currentTheme.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: selectedFromLanguage,
                  style: TextStyle(
                    fontSize: 16,
                    color: currentTheme.error,
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
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final currentTheme = themeService.currentTheme;
        return Scaffold(
          backgroundColor: currentTheme.background,
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context).translation,
              style: TextStyle(
                color: currentTheme.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: currentTheme.background,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  _buildLanguageSelector(currentTheme),
                  const SizedBox(height: 20),
                  _buildTonePicker(currentTheme),
                  const SizedBox(height: 20),
                  _buildTranslationArea(currentTheme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 언어 선택 영역
  Widget _buildLanguageSelector(AppColors currentTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildFromLanguageDropdown(currentTheme),
        const SizedBox(width: 20),
        _buildLanguageSwapButton(currentTheme),
        const SizedBox(width: 20),
        _buildToLanguageDropdown(currentTheme),
      ],
    );
  }

  // 출발 언어 선택 드롭다운
  Widget _buildFromLanguageDropdown(AppColors currentTheme) {
    return SizedBox(
      width: 140,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Select Item',
            style: TextStyle(fontSize: 14, color: currentTheme.textLight),
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
                        style: TextStyle(
                          fontSize: 20,
                          color: currentTheme.text,
                        ),
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
              color: currentTheme.light,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  // 언어 교환 버튼
  Widget _buildLanguageSwapButton(AppColors currentTheme) {
    return GestureDetector(
      onTap: () {
        _updateLanguages(selectedToLanguage, selectedFromLanguage);
      },
      child: Icon(Icons.arrow_forward_ios, color: currentTheme.text),
    );
  }

  // 도착 언어 선택 드롭다운
  Widget _buildToLanguageDropdown(AppColors currentTheme) {
    return SizedBox(
      width: 140,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Select Item',
            style: TextStyle(fontSize: 14, color: currentTheme.textLight),
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
                        style: TextStyle(
                          fontSize: 20,
                          color: currentTheme.text,
                        ),
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
              color: currentTheme.light,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  // 번역 분위기 설정 슬라이더
  Widget _buildTonePicker(AppColors currentTheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                      Icon(Icons.tune, color: currentTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context).translation_tone,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: currentTheme.text,
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
                                  color: currentTheme.textLight,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Container(
                                padding: const EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.check_circle,
                                  color: currentTheme.primary,
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
                        color: currentTheme.text,
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
                      activeTrackColor: currentTheme.primary,
                      inactiveTrackColor: currentTheme.light,
                      thumbColor: currentTheme.primary,
                      overlayColor: currentTheme.primary.withValues(alpha: 0.2),
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
                                    ? currentTheme.primary
                                    : Colors.grey.withValues(alpha: 0.3),
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
                                    ? currentTheme.primary
                                    : currentTheme.textLight,
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
  Widget _buildTranslationArea(AppColors currentTheme) {
    return Column(
      children: [
        _buildInputField(currentTheme),
        const SizedBox(height: 20),
        _buildTranslateButton(currentTheme),
        const SizedBox(height: 20),
        _buildResultField(currentTheme),
      ],
    );
  }

  // 입력창
  Widget _buildInputField(AppColors currentTheme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
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
                    Icon(Icons.edit, color: currentTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).input_text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: currentTheme.textLight,
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
                        currentTheme,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _inputController.text.isNotEmpty
                          ? currentTheme.primary.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.copy,
                      size: 16,
                      color: _inputController.text.isNotEmpty
                          ? currentTheme.text
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
                hintStyle: TextStyle(
                  color: currentTheme.textLight,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              ),
              style: TextStyle(
                color: currentTheme.text,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 번역 버튼
  Widget _buildTranslateButton(AppColors currentTheme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            currentTheme.primary,
            currentTheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: currentTheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : () => _translateText(currentTheme),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.translate, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context).translate_button,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
  Widget _buildResultField(AppColors currentTheme) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
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
                          ? currentTheme.textLight
                          : currentTheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).translation_result,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _translatedText.isEmpty
                            ? currentTheme.textLight
                            : currentTheme.text,
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
                            currentTheme.primary,
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
                        currentTheme,
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
                          ? currentTheme.primary.withValues(alpha: 0.1)
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
                          ? currentTheme.text
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
                        ? currentTheme.textLight
                        : currentTheme.text,
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
