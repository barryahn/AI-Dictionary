import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'services/language_service.dart';
import 'services/openai_service.dart';
import 'theme/beige_colors.dart';
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
  final List<String> toneLabels = ['친구', '기본', '공손', '격식'];

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
  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: BeigeColors.primary,
      textColor: Colors.white,
    );
  }

  Future<void> _translateText() async {
    if (_inputController.text.trim().isEmpty) return;

    final detectedLanguage = langdetect.detect(_inputController.text.trim());
    if (detectedLanguage != selectedFromLanguage) {
      // 언어 변경 팝업 띄우기
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('언어 변경'),
          content: Text(
            '입력 언어가 변경되었습니다. $detectedLanguage와 $selectedFromLanguage 중 하나를 선택해주세요. 확인 버튼을 누르면 자동으로 변경됩니다.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        ),
      );
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
        _translatedText = '번역 중 오류가 발생했습니다.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeigeColors.background,
      appBar: AppBar(
        title: Text(
          '번역',
          style: TextStyle(
            color: BeigeColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: BeigeColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              _buildLanguageSelector(),
              const SizedBox(height: 20),
              _buildTonePicker(),
              const SizedBox(height: 20),
              _buildTranslationArea(),
            ],
          ),
        ),
      ),
    );
  }

  // 언어 선택 영역
  Widget _buildLanguageSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildFromLanguageDropdown(),
        const SizedBox(width: 20),
        _buildLanguageSwapButton(),
        const SizedBox(width: 20),
        _buildToLanguageDropdown(),
      ],
    );
  }

  // 출발 언어 선택 드롭다운
  Widget _buildFromLanguageDropdown() {
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
                        style: const TextStyle(
                          fontSize: 20,
                          color: BeigeColors.text,
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
              color: BeigeColors.light,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  // 언어 교환 버튼
  Widget _buildLanguageSwapButton() {
    return GestureDetector(
      onTap: () {
        _updateLanguages(selectedToLanguage, selectedFromLanguage);
      },
      child: Icon(Icons.arrow_forward_ios, color: BeigeColors.text),
    );
  }

  // 도착 언어 선택 드롭다운
  Widget _buildToLanguageDropdown() {
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
                        style: const TextStyle(
                          fontSize: 20,
                          color: BeigeColors.text,
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
              color: BeigeColors.light,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  // 번역 분위기 설정 슬라이더
  Widget _buildTonePicker() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.tune, color: BeigeColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '번역 분위기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: BeigeColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 슬라이더
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: BeigeColors.primary,
              inactiveTrackColor: BeigeColors.light,
              thumbColor: BeigeColors.primary,
              overlayColor: BeigeColors.primary.withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
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
          const SizedBox(height: 16),
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
                            ? BeigeColors.primary
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
                            ? BeigeColors.primary
                            : BeigeColors.textLight,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 번역 영역 (입력창, 버튼, 결과창)
  Widget _buildTranslationArea() {
    return Column(
      children: [
        _buildInputField(),
        const SizedBox(height: 20),
        _buildTranslateButton(),
        const SizedBox(height: 20),
        _buildResultField(),
      ],
    );
  }

  // 입력창
  Widget _buildInputField() {
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
                    Icon(Icons.edit, color: BeigeColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '입력 텍스트',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: BeigeColors.textLight,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    if (_inputController.text.isNotEmpty) {
                      _copyToClipboard(
                        _inputController.text,
                        '입력 텍스트가 복사되었습니다.',
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _inputController.text.isNotEmpty
                          ? BeigeColors.primary.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.copy,
                      size: 16,
                      color: _inputController.text.isNotEmpty
                          ? BeigeColors.text
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
                hintText: '번역할 텍스트를 입력하세요.',
                hintStyle: TextStyle(
                  color: BeigeColors.textLight,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              ),
              style: TextStyle(
                color: BeigeColors.text,
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
  Widget _buildTranslateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            BeigeColors.primary,
            BeigeColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: BeigeColors.primary.withValues(alpha: 0.3),
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
                      const Text(
                        '번역하기',
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
  Widget _buildResultField() {
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
                          ? BeigeColors.textLight
                          : BeigeColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '번역 결과',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _translatedText.isEmpty
                            ? BeigeColors.textLight
                            : BeigeColors.text,
                      ),
                    ),
                    if (_isLoading) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            BeigeColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    if (_translatedText.isNotEmpty &&
                        _translatedText != '번역 결과가 여기에 표시됩니다.') {
                      _copyToClipboard(_translatedText, '번역 결과가 복사되었습니다.');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color:
                          (_translatedText.isNotEmpty &&
                              _translatedText != '번역 결과가 여기에 표시됩니다.')
                          ? BeigeColors.primary.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.copy,
                      size: 16,
                      color:
                          (_translatedText.isNotEmpty &&
                              _translatedText != '번역 결과가 여기에 표시됩니다.')
                          ? BeigeColors.text
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
                      ? '번역 결과가 여기에 표시됩니다.'
                      : _translatedText,
                  style: TextStyle(
                    color: _translatedText.isEmpty
                        ? BeigeColors.textLight
                        : BeigeColors.text,
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
