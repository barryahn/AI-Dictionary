import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:async';
import 'services/language_service.dart';
import 'services/openai_service.dart';
import 'theme/beige_colors.dart';
import 'l10n/app_localizations.dart';

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
  String selectedTone = '일상 대화';
  final List<String> toneOptions = ['일상 대화', '공식 문서'];

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
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateLanguages(String fromLang, String toLang) {
    setState(() {
      selectedFromLanguage = fromLang;
      selectedToLanguage = toLang;
    });
    // LanguageService에 저장
    LanguageService.setTranslationLanguages(fromLang, toLang);
  }

  Future<void> _translateText() async {
    if (_inputController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String toneInstruction = '';
      if (selectedTone == '일상 대화') {
        toneInstruction = '일상 대화에 적합한 자연스러운 톤으로 번역해주세요.';
      } else if (selectedTone == '공식 문서') {
        toneInstruction = '공식 문서에 적합한 격식 있는 톤으로 번역해주세요.';
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

  // 번역 분위기 설정 Horizontal Picker
  Widget _buildTonePicker() {
    return Column(
      children: [
        Text(
          '번역 분위기',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: BeigeColors.text,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: BeigeColors.light,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: toneOptions.map((tone) {
              bool isSelected = selectedTone == tone;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTone = tone;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? BeigeColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tone,
                    style: TextStyle(
                      color: isSelected ? Colors.white : BeigeColors.text,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
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
        color: BeigeColors.light,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _inputController,
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          hintText: '번역할 텍스트를 입력하세요...',
          hintStyle: TextStyle(color: BeigeColors.textLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: TextStyle(color: BeigeColors.text, fontSize: 16),
      ),
    );
  }

  // 번역 버튼
  Widget _buildTranslateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _translateText,
        style: ElevatedButton.styleFrom(
          backgroundColor: BeigeColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Text(
                '번역하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        color: BeigeColors.light,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            _translatedText.isEmpty ? '번역 결과가 여기에 표시됩니다.' : _translatedText,
            style: TextStyle(
              color: _translatedText.isEmpty
                  ? BeigeColors.textLight
                  : BeigeColors.text,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
