import 'package:flutter/material.dart';

/// 앱의 다국어 지원을 위한 로컬라이제이션 클래스
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // 앱 이름 상수
  static const String appName = 'WordVibe';
  static const String appVersion = '1.0.3';

  static const Map<String, Map<String, String>> _localizedValues = {
    'ko': {
      // 앱 제목
      'app_title': appName,

      // 네비게이션
      'home': '홈',
      'history': '기록',
      'explore': '탐색',
      'profile': '프로필',

      // 검색 관련
      'search_hint': '어떤 단어든 물어보세요',
      'search_button': '검색',
      'additional_search': '추가 검색하기',
      'searching': '검색 중...',
      'stop_search': '중단',
      'search_failed': '검색 결과를 가져오는데 실패했습니다.',
      'search_stopped': '검색이 중단되었습니다.',
      'no_search_result': '적절한 검색 결과가 없습니다.',
      'main_search_hint': '검색할 단어를 입력해보세요',

      // 언어 선택
      'from_language': '출발 언어',
      'to_language': '도착 언어',
      'language': '언어',
      'english': '영어',
      'korean': '한국어',
      'chinese': '중국어',
      'taiwanMandarin': '대만 중국어',
      'spanish': '스페인어',
      'french': '프랑스어',

      // 검색 결과
      'dictionary_meaning': '뜻',
      'nuance': '뉘앙스',
      'conversation_examples': '대화 예시',
      'similar_expressions': '비슷한 표현',
      'conversation': '대화',
      'word': '단어',

      // 검색 기록
      'search_history': '검색 기록',
      'no_history': '검색 기록이 없습니다',
      'history_description': '단어를 검색하면 여기에 기록됩니다',
      'searched_words': '검색한 단어',
      'delete_history': '검색 기록이 삭제되었습니다',
      'delete_failed': '삭제에 실패했습니다',
      'clear_all_history': '모든 기록 삭제',
      'clear_all_confirm': '모든 검색 기록을 삭제하시겠습니까?\n이 작업은 취소할 수 없습니다.',
      'cancel': '취소',
      'delete': '삭제',
      'close': '닫기',
      'all_history_deleted': '모든 검색 기록이 삭제되었습니다',

      // 프로필
      'profile_title': '프로필',
      'ai_dictionary_user': '$appName 사용자',
      'edit_profile': '프로필 편집',
      'app_language_setting': '앱 언어 설정',
      'notification_setting': '알림 설정',
      'notification_description': '학습 알림 받기',
      'dark_mode': '다크 모드',
      'dark_mode_description': '시스템 설정 따름',
      'storage': '저장 공간',
      'data': '데이터',
      'data_description': '데이터 관리',
      'theme': '테마',
      'recommended_theme': '추천',
      'light_theme': '라이트',
      'dark_theme': '다크',
      'pause_search_history': '검색 기록 저장 일시중지',
      'pause_search_history_description': '활성화하면 검색 기록 저장이 중지됩니다.',
      'search_history_paused': '현재 검색 기록 저장이 일시중지 상태입니다.',
      'delete_all_history': '모든 검색 기록 삭제',
      'delete_account': '계정 삭제',
      'delete_account_description': '계정을 영구적으로 삭제합니다',
      'delete_account_confirm':
          '정말 계정을 삭제하시겠습니까?\n\n이 작업은 취소할 수 없으며, 모든 데이터가 영구적으로 삭제됩니다.',
      'delete_account_success': '계정이 성공적으로 삭제되었습니다.',
      'delete_account_failed': '계정 삭제에 실패했습니다.',
      'password_required_for_delete': '계정 삭제를 위해 비밀번호를 입력해주세요.',
      'password_hint_for_delete': '현재 계정의 비밀번호를 입력하세요',
      'help': '도움말',
      'help_description': '사용법 및 FAQ',
      'terms_of_service': '이용 약관',
      'terms_of_service_description': '서비스 이용에 관한 약관',
      'app_info': '앱 정보',
      'app_version': '버전 $appVersion',
      'logout': '로그아웃',
      'logout_description': '계정에서 로그아웃',
      'logout_confirm': '정말 로그아웃하시겠습니까?',
      'logout_success': '로그아웃되었습니다.',
      'system': '시스템',
      'information': '정보',
      // Pro
      'pro_upgrade': 'Pro 업그레이드',
      'pro_upgrade_description': 'Pro 혜택 및 결제',
      // Pro upgrade screen
      'pro_headline': 'Pro로 업그레이드하세요.',
      'pro_thank_you': 'Pro를 구입해 주셔서 감사합니다.',
      'pro_subtitle': '더 빠르고, 더 정확하고, 더 편리하게.',
      'pro_subtitle_thanks': '오늘 하루도 행복하세요!',
      'pro_benefits_title': 'Pro 혜택',
      'pro_benefit_unlimited_title': '무제한 검색',
      'pro_benefit_unlimited_desc': '제한 없이 원하는 만큼 검색할 수 있어요.',
      'pro_benefit_better_model_title': '더 높은 AI 모델',
      'pro_benefit_better_model_desc': '3배 이상 높은 정확도와 자연스러움을 느껴보세요.',
      'pro_benefit_longer_text_title': '더 긴 텍스트 번역',
      'pro_benefit_longer_text_desc': '500자 제한이 3,000자로 확장돼요.',
      'pro_benefit_quality_title': '고급 번역 품질',
      'pro_benefit_quality_desc': '문맥과 뉘앙스를 더 잘 반영해요.',
      'pro_benefit_no_ads_title': '광고 제거',
      'pro_benefit_no_ads_desc': '깨끗하고 집중되는 화면을 제공해요.',
      'pro_benefit_extras_title': '추가 기능',
      'pro_benefit_extras_desc': '다가오는 업데이트 기능과 언어를 먼저 경험하세요.',
      'pro_monthly': '월간',
      'pro_yearly': '연간',
      'pro_upgrade_cta': 'Pro로 업그레이드',
      'pro_payment_coming_soon': '결제는 준비 중입니다.',
      'pro_monthly_price': '월 {currency}{price}',
      'pro_yearly_price': '연 {currency}{price}',
      'pro_model_quota_tooltip': 'Pro 모델 검색 남은 횟수\n내일 00:00에 다시 리셋됩니다',
      'pro_upgrade_overlay_message': 'Pro 버전을 구독해서\n더 많은 검색을 이어가 보세요.',

      // 게스트 사용자
      'guest_user': '게스트 사용자',
      'guest_description': '로그인하여 더 많은 기능을 이용하세요',

      // 로그인/회원가입
      'login': '로그인',
      'register': '회원가입',
      'login_subtitle': '$appName에 로그인하세요',
      'register_subtitle': '새 계정을 만들어보세요',
      'email': '이메일',
      'email_hint': '이메일을 입력하세요',
      'email_required': '이메일을 입력해주세요',
      'email_invalid': '올바른 이메일 형식을 입력해주세요',
      'password': '비밀번호',
      'password_hint': '비밀번호를 입력하세요',
      'password_required': '비밀번호를 입력해주세요',
      'password_too_short': '비밀번호는 6자 이상이어야 합니다',
      'forgot_password': '비밀번호 찾기',
      'forgot_password_description': '이메일로 비밀번호 재설정 링크를 보내드립니다',
      'forgot_password_description_check_spam_folder':
          '메일이 오지 않는 경우에는 스팸 메일함을 확인해주세요.',
      'reset_password_email_sent': '비밀번호 재설정 이메일이 전송되었습니다.',
      'reset_password_email_failed': '비밀번호 재설정 이메일 전송에 실패했습니다.',
      'no_account_register': '계정이 없으신가요? 회원가입',
      'have_account_login': '이미 계정이 있으신가요? 로그인',
      'login_failed': '로그인에 실패했습니다',
      'register_failed': '회원가입에 실패했습니다',
      'error_occurred': '오류가 발생했습니다',
      'google_login': 'Google로 로그인',
      'google_login_failed': 'Google 로그인에 실패했습니다',
      'or': '또는',

      // 다이얼로그
      'confirm': '확인',
      'language_changed': '앱 언어가 {language}로 변경되었습니다.',
      'feature_coming_soon': '기능은 준비 중입니다.',
      'app_name': appName,
      'version': '버전',
      'developer': '개발자',
      'ai_dictionary_team': '$appName Team',

      // 탐색 페이지
      'explore_title': '탐색',
      'word_of_day': '오늘의 추천 단어',
      'view_details': '자세히 보기',
      'popular_searches': '인기 검색어',
      'word_categories': '카테고리별 단어',
      'daily_life': '일상생활',
      'business': '비즈니스',
      'travel': '여행',
      'emotions': '감정',
      'learning': '학습',
      'hobby': '취미',
      'language_tips': '언어 학습 팁',
      'daily_learning': '매일 10분씩 학습하기',
      'daily_learning_desc': '짧은 시간이라도 꾸준히 학습하는 것이 중요합니다',
      'use_in_conversation': '실제 대화에서 사용하기',
      'use_in_conversation_desc': '배운 단어를 실제 상황에서 사용해보세요',
      'remember_in_sentence': '문장 속에서 기억하기',
      'remember_in_sentence_desc': '단어를 문장과 함께 기억하면 더 오래 기억됩니다',
      'practice_pronunciation': '발음 연습하기',
      'practice_pronunciation_desc': '소리 내어 따라하며 발음을 익혀보세요',
      'trending_words': '트렌드 단어',
      'learning_stats': '학습 통계',
      'today_learning': '오늘 학습',
      'this_week': '이번 주',
      'total_learning': '총 학습',
      'words': '단어',

      // 시간 관련
      'just_now': '방금 전',
      'minutes_ago': '{minutes}분 전',
      'hours_ago': '{hours}시간 전',
      'days_ago': '{days}일 전',

      // 검색 기록 관련
      'and_others': '외',
      'items': '개',
      'free_version_history_limit_tooltip': '무료 버전에서는 최대 20개 리스트만 저장됩니다.',

      // 번역 관련
      'translation': '번역',
      'translation_tone': '번역 분위기',
      'input_text': '입력 텍스트',
      'translation_result': '번역 결과',
      'translate_button': '번역하기',
      'input_text_hint': '번역할 텍스트를 입력하세요.',
      'translation_result_hint': '번역 결과가 여기에 표시됩니다.',
      'input_text_copied': '입력 텍스트가 복사되었습니다.',
      'translation_result_copied': '번역 결과가 복사되었습니다.',
      'translation_error': '번역 중 오류가 발생했습니다.',
      'language_change': '언어 변경',
      'selected_input_language': '선택한 입력 언어: ',
      'is_this_language_correct': '이 언어가 맞나요?',
      'yes': '네',
      'no': '아니요',
      'friendly': '친구',
      'basic': '기본',
      'polite': '공손',
      'formal': '격식',

      // 도움말 관련
      'welcome_tutorial': '앱 사용법 안내',
      'tutorial_welcome': '$appName에 오신 것을\n환영합니다!',
      'tutorial_welcome_desc': '앱의 주요 기능들을\n간단히 안내해드릴게요.',
      'tutorial_search_title': '단어 검색하기',
      'tutorial_search_desc': '의미나 뉘앙스가 헷갈리거나\n모르는 단어를 검색해보세요!',
      'tutorial_search_desc_detail': 'AI가 실제 원어민들이 사용하는 단어를 알려드려요.',
      'tutorial_search_desc_detail_2': '여기서도 언어를 바꿀 수 있어요.',
      'tutorial_language_title': '언어 선택하기',
      'tutorial_language_desc': '검색하기 전에 언어를 꼭 선택하세요!',
      'tutorial_language_desc_detail': '영어를 선택하면,\n영어 사전으로 사용이 가능합니다.',
      'tutorial_history_title': '검색 기록',
      'tutorial_history_desc': '검색한 단어들은 여기에 저장됩니다.',
      'tutorial_history_desc_detail': '로그인하면 앱을 재설치해도\n기록을 유지할 수 있어요.',
      'tutorial_translate_title': 'AI 번역',
      'tutorial_translate_desc': '번역 분위기를 선택하고 문장을 번역해보세요!',
      'tutorial_translate_language_selector_title': '번역할 언어 선택하기',
      'tutorial_translate_language_selector_desc': '어떤 언어에서 어떤 언어로 번역할지 선택하세요!',
      'tutorial_translate_desc_detail':
          '상황에 맞는 번역 분위기를 선택해서\n더 자연스러운 번역 결과를 얻어보세요.',
      'tutorial_translate_tone_picker_title': '번역 분위기',
      'tutorial_translate_tone_picker_desc': '번역 분위기를 선택해서 상황에 맞게 번역하세요!',
      'tutorial_next': '다음',
      'tutorial_skip': '건너뛰기',
      'tutorial_skip_all': '모두 건너뛰기',
      'tutorial_finish': '시작하기',
      'tutorial_dont_show_again': '다시 보지 않기',
      'tutorial_show_again': '다시 보기',
      'tutorial_show_again_desc': '설정에서 언제든지 다시 볼 수 있어요.',
      // 홈 화면 문구
      'which_language_question': '어떤 언어가 궁금하세요?',
      'which_language_part1': '어떤 언어',
      'which_language_part2': '가 궁금하세요?',
      // 리뷰 요청
      'review_thanks_first_search': '첫 검색을 해주셔서 감사합니다!',
      'review_like_app_question': 'WordVibe 앱이 마음에 드시나요?',
      'review_recommend_play_store': '플레이 스토어에서 평점을 남겨 다른 분들께 추천해주세요',
      'review_rate_now': '평가하기',
    },
    'en': {
      // App Title
      'app_title': appName,

      // Navigation
      'home': 'Home',
      'history': 'History',
      'explore': 'Explore',
      'profile': 'Profile',

      // Search Related
      'search_hint': 'Ask about any word',
      'search_button': 'Search',
      'additional_search': 'Search more',
      'searching': 'Searching...',
      'stop_search': 'Stop',
      'search_failed': 'Failed to get search results.',
      'search_stopped': 'Search was stopped.',
      'no_search_result': 'No appropriate search results found.',
      'main_search_hint': 'Enter a word to search',

      // Language Selection
      'from_language': 'From',
      'to_language': 'To',
      'language': 'Language',
      'english': 'English',
      'korean': 'Korean',
      'chinese': 'Chinese',
      'taiwanMandarin': 'Taiwan Mandarin',
      'spanish': 'Spanish',
      'french': 'French',

      // Search Results
      'dictionary_meaning': 'Meaning',
      'nuance': 'Nuance',
      'conversation_examples': 'Conversation Examples',
      'similar_expressions': 'Similar Expressions',
      'conversation': 'Conversation',
      'word': 'Word',

      // Search History
      'search_history': 'Search History',
      'no_history': 'No search history',
      'history_description': 'Search history will appear here',
      'searched_words': 'Searched words',
      'delete_history': 'Search history deleted',
      'delete_failed': 'Delete failed',
      'clear_all_history': 'Clear All History',
      'clear_all_confirm':
          'Delete all search history?\nThis action cannot be undone.',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'close': 'Close',
      'all_history_deleted': 'All search history deleted',

      // Profile
      'profile_title': 'Profile',
      'ai_dictionary_user': '$appName User',
      'edit_profile': 'Edit Profile',
      'app_language_setting': 'App Language',
      'notification_setting': 'Notifications',
      'notification_description': 'Receive learning notifications',
      'dark_mode': 'Dark Mode',
      'dark_mode_description': 'Follow system settings',
      'storage': 'Storage',
      'data': 'Data',
      'data_description': 'Data management',
      'theme': 'Theme',
      'recommended_theme': 'Recommended',
      'light_theme': 'Light',
      'dark_theme': 'Dark',
      'pause_search_history': 'Pause search history',
      'pause_search_history_description':
          'When activated, search history saving will be paused.',
      'search_history_paused': 'Search history saving is currently paused.',
      'delete_all_history': 'Delete all search history',
      'delete_account': 'Delete account',
      'delete_account_description': 'Permanently delete your account',
      'delete_account_confirm':
          'Are you sure you want to delete your account?\n\nThis action cannot be undone and all data will be permanently deleted.',
      'delete_account_success': 'Account successfully deleted.',
      'delete_account_failed': 'Failed to delete account.',
      'password_required_for_delete':
          'Please enter your password to delete your account.',
      'password_hint_for_delete': 'Enter your current account password',
      'help': 'Help',
      'help_description': 'Usage and FAQ',
      'terms_of_service': 'Terms of Service',
      'terms_of_service_description': 'Terms of service usage',
      'app_info': 'App Info',
      'app_version': 'Version $appVersion',
      'logout': 'Logout',
      'logout_description': 'Logout from account',
      'logout_confirm': 'Are you sure you want to logout?',
      'logout_success': 'Logged out successfully.',
      'system': 'System',
      'information': 'Information',
      // Pro
      'pro_upgrade': 'Upgrade to Pro',
      'pro_upgrade_description': 'Pro benefits and billing',
      // Pro upgrade screen
      'pro_headline': 'Upgrade to Pro.',
      'pro_thank_you': 'Thank you for purchasing Pro.',
      'pro_subtitle': 'Faster, more accurate, and more convenient.',
      'pro_subtitle_thanks': 'Have a wonderful day!',
      'pro_benefits_title': 'Pro Benefits',
      'pro_benefit_unlimited_title': 'Unlimited searches',
      'pro_benefit_unlimited_desc':
          'Search as much as you want without limits.',
      'pro_benefit_better_model_title': 'Higher AI model',
      'pro_benefit_better_model_desc':
          'Experience over 3x better accuracy and naturalness.',
      'pro_benefit_longer_text_title': 'Longer text translation',
      'pro_benefit_longer_text_desc':
          'Translate up to 3,000 characters instead of 500.',
      'pro_benefit_quality_title': 'Advanced translation quality',
      'pro_benefit_quality_desc': 'Better reflects context and nuance.',
      'pro_benefit_no_ads_title': 'No ads',
      'pro_benefit_no_ads_desc': 'Enjoy a clean and focused screen.',
      'pro_benefit_extras_title': 'Extra features',
      'pro_benefit_extras_desc': 'Try upcoming features and languages first.',
      'pro_monthly': 'Monthly',
      'pro_yearly': 'Yearly',
      'pro_upgrade_cta': 'Upgrade to Pro',
      'pro_payment_coming_soon': 'Payment is coming soon.',
      'pro_monthly_price': '{currency}{price} per month',
      'pro_yearly_price': '{currency}{price} per year',
      'pro_model_quota_tooltip':
          'Remaining Pro-model searches today\nReset at 00:00 tomorrow',
      'pro_upgrade_overlay_message':
          'Subscribe to Pro to continue more searches.',

      // Guest User
      'guest_user': 'Guest User',
      'guest_description': 'Login to access more features',

      // Login/Register
      'login': 'Login',
      'register': 'Register',
      'login_subtitle': 'Login to $appName',
      'register_subtitle': 'Create a new account',
      'email': 'Email',
      'email_hint': 'Enter your email',
      'email_required': 'Please enter your email',
      'email_invalid': 'Please enter a valid email format',
      'password': 'Password',
      'password_hint': 'Enter your password',
      'password_required': 'Please enter your password',
      'password_too_short': 'Password must be at least 6 characters',
      'forgot_password': 'Forgot Password',
      'forgot_password_description':
          'We\'ll send you a password reset link via email',
      'forgot_password_description_check_spam_folder':
          'If you don\'t receive the email, please check your spam folder.',
      'reset_password_email_sent': 'Password reset email has been sent.',
      'reset_password_email_failed': 'Failed to send password reset email.',
      'no_account_register': 'Don\'t have an account? Register',
      'have_account_login': 'Already have an account? Login',
      'login_failed': 'Login failed',
      'register_failed': 'Registration failed',
      'error_occurred': 'An error occurred',
      'google_login': 'Sign in with Google',
      'google_login_failed': 'Google sign in failed',
      'or': 'or',

      // Dialogs
      'confirm': 'Confirm',
      'language_changed': 'App language changed to {language}.',
      'feature_coming_soon': 'Feature coming soon.',
      'app_name': appName,
      'version': 'Version',
      'developer': 'Developer',
      'ai_dictionary_team': '$appName Team',

      // Explore Page
      'explore_title': 'Explore',
      'word_of_day': 'Word of the Day',
      'view_details': 'View Details',
      'popular_searches': 'Popular Searches',
      'word_categories': 'Word Categories',
      'daily_life': 'Daily Life',
      'business': 'Business',
      'travel': 'Travel',
      'emotions': 'Emotions',
      'learning': 'Learning',
      'hobby': 'Hobby',
      'language_tips': 'Language Learning Tips',
      'daily_learning': 'Learn 10 minutes daily',
      'daily_learning_desc':
          'Consistent learning is important even for short periods',
      'use_in_conversation': 'Use in real conversations',
      'use_in_conversation_desc': 'Try using learned words in real situations',
      'remember_in_sentence': 'Remember in sentences',
      'remember_in_sentence_desc':
          'Remembering words in context helps retention',
      'practice_pronunciation': 'Practice pronunciation',
      'practice_pronunciation_desc': 'Practice pronunciation by speaking aloud',
      'trending_words': 'Trending Words',
      'learning_stats': 'Learning Stats',
      'today_learning': 'Today',
      'this_week': 'This Week',
      'total_learning': 'Total',
      'words': 'words',

      // Time Related
      'just_now': 'Just now',
      'minutes_ago': '{minutes} minutes ago',
      'hours_ago': '{hours} hours ago',
      'days_ago': '{days} days ago',

      // Search History Related
      'and_others': 'and',
      'items': ' more',
      'free_version_history_limit_tooltip':
          'Free version saves up to 20 lists.',

      // Translation Related
      'translation': 'Translation',
      'translation_tone': 'Translation Tone',
      'input_text': 'Input Text',
      'translation_result': 'Translation Result',
      'translate_button': 'Translate',
      'input_text_hint': 'Enter text to translate.',
      'translation_result_hint': 'Translation result will appear here.',
      'input_text_copied': 'Input text copied.',
      'translation_result_copied': 'Translation result copied.',
      'translation_error': 'An error occurred during translation.',
      'language_change': 'Language Change',
      'selected_input_language': 'Selected input language: ',
      'is_this_language_correct': 'Is this language correct?',
      'yes': 'Yes',
      'no': 'No',
      'friendly': 'Friendly',
      'basic': 'Basic',
      'polite': 'Polite',
      'formal': 'Formal',

      // Help / Tutorial
      'welcome_tutorial': 'App Tutorial',
      'tutorial_welcome': 'Welcome to $appName!',
      'tutorial_welcome_desc':
          'We\'ll briefly guide you through the main features of the app.',
      'tutorial_search_title': 'Searching Words',
      'tutorial_search_desc':
          'If you\'re confused about a meaning or nuance,\ntry searching for the word!',
      'tutorial_search_desc_detail':
          'AI will show you how native speakers actually use the word.',
      'tutorial_search_desc_detail_2': 'You can also change the language here.',
      'tutorial_language_title': 'Choosing Languages',
      'tutorial_language_desc':
          'Be sure to select the source and target languages before searching!',
      'tutorial_language_desc_detail':
          'If you select Spanish,\nyou can use it as a Spanish dictionary.',
      'tutorial_history_title': 'Search History',
      'tutorial_history_desc': 'Words you search for will be saved here.',
      'tutorial_history_desc_detail':
          'If you log in, your history will be kept even after reinstalling the app.',
      'tutorial_translate_title': 'AI Translation',
      'tutorial_translate_desc':
          'Select a translation tone and try translating a sentence!',
      'tutorial_translate_language_selector_title':
          'Choose translation languages',
      'tutorial_translate_language_selector_desc':
          'Select the languages to translate from and to!',
      'tutorial_translate_desc_detail':
          'Choose the right tone for the situation\nto get more natural translation results.',
      'tutorial_translate_tone_picker_title': 'Translation Tone',
      'tutorial_translate_tone_picker_desc':
          'Choose a translation tone to suit the situation!',
      'tutorial_next': 'Next',
      'tutorial_skip': 'Skip',
      'tutorial_skip_all': 'Skip All',
      'tutorial_finish': 'Get Started',
      'tutorial_dont_show_again': 'Don\'t show again',
      'tutorial_show_again': 'Show again',
      'tutorial_show_again_desc':
          'You can view this tutorial again anytime in settings.',
      // Home screen phrase
      'which_language_question': 'Which language are you curious about?',
      'which_language_part1': 'Which language ',
      'which_language_part2': 'are you curious about?',
      // Review prompt
      'review_thanks_first_search': 'Thanks for your first search!',
      'review_like_app_question': 'Like using WordVibe app?',
      'review_recommend_play_store':
          'Recommend us to others by rating us on Play Store',
      'review_rate_now': 'RATE US',
    },
    'zh': {
      // 应用标题
      'app_title': appName,

      // 导航
      'home': '首页',
      'history': '历史',
      'explore': '探索',
      'profile': '个人',

      // 搜索相关
      'search_hint': '询问任何单词',
      'search_button': '搜索',
      'additional_search': '继续搜索',
      'searching': '搜索中...',
      'stop_search': '停止',
      'search_failed': '获取搜索结果失败。',
      'search_stopped': '搜索已停止。',
      'no_search_result': '没有找到合适的搜索结果。',
      'main_search_hint': '输入要搜索的单词',

      // 语言选择
      'from_language': '从',
      'to_language': '到',
      'language': '语言',
      'english': '英语',
      'korean': '韩语',
      'chinese': '中文',
      'taiwanMandarin': '中文 (台湾)',
      'spanish': '西班牙语',
      'french': '法语',

      // 搜索结果
      'dictionary_meaning': '含义',
      'nuance': '细微差别',
      'conversation_examples': '对话示例',
      'similar_expressions': '相似表达',
      'conversation': '对话',
      'word': '单词',

      // 搜索历史
      'search_history': '搜索历史',
      'no_history': '无搜索历史',
      'history_description': '搜索历史将显示在这里',
      'searched_words': '搜索的单词',
      'delete_history': '搜索历史已删除',
      'delete_failed': '删除失败',
      'clear_all_history': '清除所有历史',
      'clear_all_confirm': '删除所有搜索历史？\n此操作无法撤销。',
      'cancel': '取消',
      'delete': '删除',
      'close': '关闭',
      'all_history_deleted': '所有搜索历史已删除',

      // 个人资料
      'profile_title': '个人资料',
      'ai_dictionary_user': '$appName 用户',
      'edit_profile': '编辑资料',
      'app_language_setting': '应用语言',
      'notification_setting': '通知',
      'notification_description': '接收学习通知',
      'dark_mode': '深色模式',
      'dark_mode_description': '跟随系统设置',
      'storage': '存储',
      'data': '数据',
      'data_description': '数据管理',
      'theme': '主题',
      'recommended_theme': '推荐',
      'light_theme': '浅色',
      'dark_theme': '深色',
      'pause_search_history': '暂停搜索历史记录',
      'pause_search_history_description': '激活后，搜索历史记录保存将被暂停。',
      'search_history_paused': '当前搜索历史记录保存处于暂停状态。',
      'delete_all_history': '删除所有搜索历史记录',
      'delete_account': '删除账户',
      'delete_account_description': '永久删除您的账户',
      'delete_account_confirm': '确定要删除您的账户吗？\n\n此操作无法撤销，所有数据将被永久删除。',
      'delete_account_success': '账户已成功删除。',
      'delete_account_failed': '删除账户失败。',
      'password_required_for_delete': '请输入密码以删除您的账户。',
      'password_hint_for_delete': '请输入当前账户密码',
      'help': '帮助',
      'help_description': '使用方法和常见问题',
      'terms_of_service': '服务条款',
      'terms_of_service_description': '服务使用相关条款',
      'app_info': '应用信息',
      'app_version': '版本 $appVersion',
      'logout': '退出登录',
      'logout_description': '从账户退出',
      'logout_confirm': '确定要退出登录吗？',
      'logout_success': '已成功退出登录。',
      'system': '系统',
      'information': '信息',
      // Pro
      'pro_upgrade': '升级到 Pro',
      'pro_upgrade_description': 'Pro 权益与付款',
      // Pro upgrade screen
      'pro_headline': '升级到 Pro。',
      'pro_thank_you': '感谢您购买 Pro。',
      'pro_subtitle': '更快、更准确、更便捷。',
      'pro_subtitle_thanks': '祝您今天心情愉快！',
      'pro_benefits_title': 'Pro 权益',
      'pro_benefit_unlimited_title': '无限搜索',
      'pro_benefit_unlimited_desc': '想搜多少就搜多少。',
      'pro_benefit_better_model_title': '更高等级 AI 模型',
      'pro_benefit_better_model_desc': '体验超过 3 倍的准确度与自然度。',
      'pro_benefit_longer_text_title': '更长文本翻译',
      'pro_benefit_longer_text_desc': '从 500 字扩展到 3,000 字。',
      'pro_benefit_quality_title': '更高级的翻译质量',
      'pro_benefit_quality_desc': '更好地体现语境与细微差别。',
      'pro_benefit_no_ads_title': '移除广告',
      'pro_benefit_no_ads_desc': '更清爽、更专注的界面。',
      'pro_benefit_extras_title': '更多功能',
      'pro_benefit_extras_desc': '优先体验即将上线的功能与语言。',
      'pro_monthly': '月度',
      'pro_yearly': '年度',
      'pro_upgrade_cta': '升级到 Pro',
      'pro_payment_coming_soon': '支付功能即将上线。',
      'pro_monthly_price': '每月 {currency}{price}',
      'pro_yearly_price': '每年 {currency}{price}',
      'pro_model_quota_tooltip': '今日剩余 Pro 模型搜索次数\n将于明日 00:00 重置',
      'pro_upgrade_overlay_message': '订阅 Pro，继续进行更多搜索。',

      // 访客用户
      'guest_user': '访客用户',
      'guest_description': '登录以访问更多功能',

      // 登录/注册
      'login': '登录',
      'register': '注册',
      'login_subtitle': '登录$appName',
      'register_subtitle': '创建新账户',
      'email': '邮箱',
      'email_hint': '请输入邮箱',
      'email_required': '请输入邮箱',
      'email_invalid': '请输入有效的邮箱格式',
      'password': '密码',
      'password_hint': '请输入密码',
      'password_required': '请输入密码',
      'password_too_short': '密码至少需要6个字符',
      'forgot_password': '忘记密码',
      'forgot_password_description': '我们将通过电子邮件发送密码重置链接',
      'forgot_password_description_check_spam_folder': '如果您没有收到邮件，请检查垃圾邮件文件夹。',
      'reset_password_email_sent': '密码重置电子邮件已发送。',
      'reset_password_email_failed': '发送密码重置电子邮件失败。',
      'no_account_register': '没有账户？注册',
      'have_account_login': '已有账户？登录',
      'login_failed': '登录失败',
      'register_failed': '注册失败',
      'error_occurred': '发生错误',
      'google_login': '使用Google登录',
      'google_login_failed': 'Google登录失败',
      'or': '或',

      // 对话框
      'confirm': '确认',
      'language_changed': '应用语言已更改为{language}。',
      'feature_coming_soon': '功能即将推出。',
      'app_name': appName,
      'version': '版本',
      'developer': '开发者',
      'ai_dictionary_team': '$appName团队',

      // 探索页面
      'explore_title': '探索',
      'word_of_day': '今日推荐单词',
      'view_details': '查看详情',
      'popular_searches': '热门搜索',
      'word_categories': '单词分类',
      'daily_life': '日常生活',
      'business': '商务',
      'travel': '旅行',
      'emotions': '情感',
      'learning': '学习',
      'hobby': '爱好',
      'language_tips': '语言学习技巧',
      'daily_learning': '每天学习10分钟',
      'daily_learning_desc': '即使时间短，持续学习也很重要',
      'use_in_conversation': '在实际对话中使用',
      'use_in_conversation_desc': '尝试在实际情况中使用学到的单词',
      'remember_in_sentence': '在句子中记忆',
      'remember_in_sentence_desc': '在上下文中记忆单词有助于保持记忆',
      'practice_pronunciation': '练习发音',
      'practice_pronunciation_desc': '通过大声说话练习发音',
      'trending_words': '热门单词',
      'learning_stats': '学习统计',
      'today_learning': '今天',
      'this_week': '本周',
      'total_learning': '总计',
      'words': '单词',

      // 时间相关
      'just_now': '刚刚',
      'minutes_ago': '{minutes}分钟前',
      'hours_ago': '{hours}小时前',
      'days_ago': '{days}天前',

      // 搜索历史相关
      'and_others': '和另外',
      'items': '个',
      'free_version_history_limit_tooltip': '免费版最多可保存 20 个列表。',

      // 翻译相关
      'translation': '翻译',
      'translation_tone': '翻译语气',
      'input_text': '输入文本',
      'translation_result': '翻译结果',
      'translate_button': '翻译',
      'input_text_hint': '请输入要翻译的文本。',
      'translation_result_hint': '翻译结果将显示在这里。',
      'input_text_copied': '输入文本已复制。',
      'translation_result_copied': '翻译结果已复制。',
      'translation_error': '翻译过程中发生错误。',
      'language_change': '语言更改',
      'selected_input_language': '选择的输入语言：',
      'is_this_language_correct': '这个语言正确吗？',
      'yes': '是',
      'no': '否',
      'friendly': '友好',
      'basic': '基本',
      'polite': '礼貌',
      'formal': '正式',

      // 帮助 / 教程
      'welcome_tutorial': '应用使用教程',
      'tutorial_welcome': '欢迎来到$appName！',
      'tutorial_welcome_desc': '我们将简要介绍应用的主要功能。',
      'tutorial_search_title': '单词搜索',
      'tutorial_search_desc': '如果对含义或语感感到困惑，\n请尝试搜索单词！',
      'tutorial_search_desc_detail': 'AI会告诉你母语者实际如何使用这个单词。',
      'tutorial_search_desc_detail_2': '你也可以在这里更改语言。',
      'tutorial_language_title': '选择语言',
      'tutorial_language_desc': '搜索前请务必选择源语言和目标语言！',
      'tutorial_language_desc_detail': '如果选择英语，\n就可以作为英语词典使用。',
      'tutorial_history_title': '搜索历史',
      'tutorial_history_desc': '你搜索过的单词会保存在这里。',
      'tutorial_history_desc_detail': '登录后，即使重新安装应用也能保留历史记录。',
      'tutorial_translate_title': 'AI翻译',
      'tutorial_translate_desc': '选择翻译语气，\n尝试翻译句子！',
      'tutorial_translate_language_selector_title': '选择翻译语言',
      'tutorial_translate_language_selector_desc': '选择从哪种语言翻译到哪种语言！',
      'tutorial_translate_desc_detail': '根据场景选择合适的语气，\n获得更自然的翻译结果。',
      'tutorial_translate_tone_picker_title': '翻译语气',
      'tutorial_translate_tone_picker_desc': '选择合适的翻译语气以匹配场景！',
      'tutorial_next': '下一步',
      'tutorial_skip': '跳过',
      'tutorial_skip_all': '全部跳过',
      'tutorial_finish': '开始使用',
      'tutorial_dont_show_again': '不再显示',
      'tutorial_show_again': '再次查看',
      'tutorial_show_again_desc': '你可以随时在设置中再次查看本教程。',
      // 首页文案
      'which_language_question': '您对哪种语言感兴趣？',
      'which_language_part1': '您对哪种语言',
      'which_language_part2': '感兴趣？',
      // 评价提示
      'review_thanks_first_search': '感谢您的首次搜索！',
      'review_like_app_question': '喜欢使用 WordVibe 应用吗？',
      'review_recommend_play_store': '请在 Play 商店给我们评分并推荐给他人',
      'review_rate_now': '去评分',
    },
    'zh-TW': {
      // 應用標題
      'app_title': appName,

      // 導航
      'home': '首頁',
      'history': '歷史',
      'explore': '探索',
      'profile': '個人',

      // 搜尋相關
      'search_hint': '詢問任何單字',
      'search_button': '搜尋',
      'additional_search': '繼續搜尋',
      'searching': '搜尋中...',
      'stop_search': '停止',
      'search_failed': '獲取搜尋結果失敗。',
      'search_stopped': '搜尋已停止。',
      'no_search_result': '沒有找到合適的搜尋結果。',
      'main_search_hint': '輸入要搜尋的單字',

      // 語言選擇
      'from_language': '從',
      'to_language': '到',
      'language': '語言',
      'english': '英語',
      'korean': '韓語',
      'chinese': '簡體中文',
      'taiwanMandarin': '中文 (台灣)',
      'spanish': '西班牙語',
      'french': '法語',

      // 搜尋結果
      'dictionary_meaning': '含義',
      'nuance': '細微差別',
      'conversation_examples': '對話範例',
      'similar_expressions': '相似表達',
      'conversation': '對話',
      'word': '單字',

      // 搜尋歷史
      'search_history': '搜尋歷史',
      'no_history': '無搜尋歷史',
      'history_description': '搜尋歷史將顯示在這裡',
      'searched_words': '搜尋的單字',
      'delete_history': '搜尋歷史已刪除',
      'delete_failed': '刪除失敗',
      'clear_all_history': '清除所有歷史',
      'clear_all_confirm': '刪除所有搜尋歷史？\n此操作無法撤銷。',
      'cancel': '取消',
      'delete': '刪除',
      'close': '關閉',
      'all_history_deleted': '所有搜尋歷史已刪除',

      // 個人資料
      'profile_title': '個人資料',
      'ai_dictionary_user': '$appName 使用者',
      'edit_profile': '編輯資料',
      'app_language_setting': '應用語言',
      'notification_setting': '通知',
      'notification_description': '接收學習通知',
      'dark_mode': '深色模式',
      'dark_mode_description': '跟隨系統設定',
      'storage': '儲存',
      'data': '資料',
      'data_description': '資料管理',
      'theme': '主題',
      'recommended_theme': '推薦',
      'light_theme': '淺色',
      'dark_theme': '深色',
      'pause_search_history': '暫停搜尋歷史記錄',
      'pause_search_history_description': '啟用後，搜尋歷史記錄儲存將被暫停。',
      'search_history_paused': '目前搜尋歷史記錄儲存為暫停狀態。',
      'delete_all_history': '刪除所有搜尋歷史記錄',
      'delete_account': '刪除帳戶',
      'delete_account_description': '永久刪除您的帳戶',
      'delete_account_confirm': '確定要刪除您的帳戶嗎？\n\n此操作無法撤銷，所有資料將被永久刪除。',
      'delete_account_success': '帳戶已成功刪除。',
      'delete_account_failed': '刪除帳戶失敗。',
      'password_required_for_delete': '請輸入密碼以刪除您的帳戶。',
      'password_hint_for_delete': '請輸入當前帳戶密碼',
      'help': '幫助',
      'help_description': '使用方法和常見問題',
      'terms_of_service': '服務條款',
      'terms_of_service_description': '服務使用相關條款',
      'app_info': '應用資訊',
      'app_version': '版本 $appVersion',
      'logout': '登出',
      'logout_description': '從帳戶登出',
      'logout_confirm': '確定要登出嗎？',
      'logout_success': '已成功登出。',
      'system': '系統',
      'information': '資訊',
      // Pro
      'pro_upgrade': '升級至 Pro',
      'pro_upgrade_description': 'Pro 權益與付款',
      // Pro upgrade screen
      'pro_headline': '升級至 Pro。',
      'pro_thank_you': '感謝您購買 Pro。',
      'pro_subtitle': '更快、更準確、更方便。',
      'pro_subtitle_thanks': '祝您有美好的一天！',
      'pro_benefits_title': 'Pro 權益',
      'pro_benefit_unlimited_title': '無限搜尋',
      'pro_benefit_unlimited_desc': '想搜多少就搜多少。',
      'pro_benefit_better_model_title': '更高等級 AI 模型',
      'pro_benefit_better_model_desc': '體驗超過 3 倍的準確度與自然度。',
      'pro_benefit_longer_text_title': '更長文字翻譯',
      'pro_benefit_longer_text_desc': '從 500 字擴增至 3,000 字。',
      'pro_benefit_quality_title': '更高級的翻譯品質',
      'pro_benefit_quality_desc': '更能反映語境與細微差異。',
      'pro_benefit_no_ads_title': '移除廣告',
      'pro_benefit_no_ads_desc': '提供更乾淨、專注的畫面。',
      'pro_benefit_extras_title': '更多功能',
      'pro_benefit_extras_desc': '優先體驗即將推出的功能與語言。',
      'pro_monthly': '月費',
      'pro_yearly': '年費',
      'pro_upgrade_cta': '升級至 Pro',
      'pro_payment_coming_soon': '付款功能即將推出。',
      'pro_monthly_price': '每月 {currency}{price}',
      'pro_yearly_price': '每年 {currency}{price}',
      'pro_model_quota_tooltip': '今日剩餘 Pro 模型搜尋次數\n將於明日 00:00 重設',
      'pro_upgrade_overlay_message': '訂閱 Pro，繼續進行更多搜尋。',

      // 訪客使用者
      'guest_user': '訪客使用者',
      'guest_description': '登入以使用更多功能',

      // 登入/註冊
      'login': '登入',
      'register': '註冊',
      'login_subtitle': '登入$appName',
      'register_subtitle': '建立新帳戶',
      'email': '信箱',
      'email_hint': '請輸入信箱',
      'email_required': '請輸入信箱',
      'email_invalid': '請輸入有效的信箱格式',
      'password': '密碼',
      'password_hint': '請輸入密碼',
      'password_required': '請輸入密碼',
      'password_too_short': '密碼至少需要6個字元',
      'forgot_password': '忘記密碼',
      'forgot_password_description': '我們將通過電子郵件發送密碼重置連結',
      'forgot_password_description_check_spam_folder': '如果您沒有收到郵件，請檢查垃圾郵件資料夾。',
      'reset_password_email_sent': '密碼重置電子郵件已發送。',
      'reset_password_email_failed': '發送密碼重置電子郵件失敗。',
      'no_account_register': '沒有帳戶？註冊',
      'have_account_login': '已有帳戶？登入',
      'login_failed': '登入失敗',
      'register_failed': '註冊失敗',
      'error_occurred': '發生錯誤',
      'google_login': '使用Google登入',
      'google_login_failed': 'Google登入失敗',
      'or': '或',

      // 對話框
      'confirm': '確認',
      'language_changed': '應用語言已更改為{language}。',
      'feature_coming_soon': '功能即將推出。',
      'app_name': appName,
      'version': '版本',
      'developer': '開發者',
      'ai_dictionary_team': '$appName團隊',

      // 探索頁面
      'explore_title': '探索',
      'word_of_day': '今日推薦單字',
      'view_details': '查看詳情',
      'popular_searches': '熱門搜尋',
      'word_categories': '單字分類',
      'daily_life': '日常生活',
      'business': '商務',
      'travel': '旅行',
      'emotions': '情感',
      'learning': '學習',
      'hobby': '愛好',
      'language_tips': '語言學習技巧',
      'daily_learning': '每天學習10分鐘',
      'daily_learning_desc': '即使時間短，持續學習也很重要',
      'use_in_conversation': '在實際對話中使用',
      'use_in_conversation_desc': '嘗試在實際情況中使用學到的單字',
      'remember_in_sentence': '在句子中記憶',
      'remember_in_sentence_desc': '在上下文中記憶單字有助於保持記憶',
      'practice_pronunciation': '練習發音',
      'practice_pronunciation_desc': '透過大聲說話練習發音',
      'trending_words': '熱門單字',
      'learning_stats': '學習統計',
      'today_learning': '今天',
      'this_week': '本週',
      'total_learning': '總計',
      'words': '單字',

      // 時間相關
      'just_now': '剛剛',
      'minutes_ago': '{minutes}分鐘前',
      'hours_ago': '{hours}小時前',
      'days_ago': '{days}天前',

      // 搜尋歷史相關
      'and_others': '和另外',
      'items': '個',
      'free_version_history_limit_tooltip': '免費版最多可儲存 20 個列表。',

      // 翻譯相關
      'translation': '翻譯',
      'translation_tone': '翻譯語氣',
      'input_text': '輸入文字',
      'translation_result': '翻譯結果',
      'translate_button': '翻譯',
      'input_text_hint': '請輸入要翻譯的文字。',
      'translation_result_hint': '翻譯結果將顯示在這裡。',
      'input_text_copied': '輸入文字已複製。',
      'translation_result_copied': '翻譯結果已複製。',
      'translation_error': '翻譯過程中發生錯誤。',
      'language_change': '語言更改',
      'selected_input_language': '選擇的輸入語言：',
      'is_this_language_correct': '這個語言正確嗎？',
      'yes': '是',
      'no': '否',
      'friendly': '友好',
      'basic': '基本',
      'polite': '禮貌',
      'formal': '正式',

      // 幫助 / 教學
      'welcome_tutorial': '歡迎使用教學',
      'tutorial_welcome': '歡迎來到$appName！',
      'tutorial_welcome_desc': '我們將簡單介紹應用的主要功能。',
      'tutorial_search_title': '單字搜尋',
      'tutorial_search_desc': '如果對意思或語感感到困惑，\n請嘗試搜尋單字！',
      'tutorial_search_desc_detail': 'AI會告訴你母語者實際如何使用這個單字。',
      'tutorial_search_desc_detail_2': '你也可以在這裡更改語言。',
      'tutorial_language_title': '選擇語言',
      'tutorial_language_desc': '搜尋前請務必選擇來源語言和目標語言！',
      'tutorial_language_desc_detail': '選擇英文後，\n即可當作英文字典使用。',
      'tutorial_history_title': '搜尋紀錄',
      'tutorial_history_desc': '你搜尋過的單字會保存在這裡。',
      'tutorial_history_desc_detail': '登入後，即使重新安裝應用也能保留紀錄。',
      'tutorial_translate_title': 'AI翻譯',
      'tutorial_translate_desc': '選擇翻譯語氣，\n嘗試翻譯句子！',
      'tutorial_translate_language_selector_title': '選擇翻譯語言',
      'tutorial_translate_language_selector_desc': '選擇從哪種語言翻譯到哪種語言！',
      'tutorial_translate_desc_detail': '根據情境選擇合適的語氣，\n獲得更自然的翻譯結果。',
      'tutorial_translate_tone_picker_title': '翻譯語氣',
      'tutorial_translate_tone_picker_desc': '選擇合適的翻譯語氣以符合情境！',
      'tutorial_next': '下一步',
      'tutorial_skip': '跳過',
      'tutorial_skip_all': '全部跳過',
      'tutorial_finish': '開始使用',
      'tutorial_dont_show_again': '不再顯示',
      'tutorial_show_again': '再次查看',
      'tutorial_show_again_desc': '你可以隨時在設定中再次查看本教學。',
      // 首頁文案
      'which_language_question': '您對哪種語言感興趣？',
      'which_language_part1': '您對哪種語言',
      'which_language_part2': '感興趣？',
      // 評分提示
      'review_thanks_first_search': '感謝您的首次搜尋！',
      'review_like_app_question': '喜歡使用 WordVibe 應用嗎？',
      'review_recommend_play_store': '請在 Play 商店為我們評分並推薦給他人',
      'review_rate_now': '前往評分',
    },
    'fr': {
      // Titre de l'application
      'app_title': appName,

      // Navigation
      'home': 'Accueil',
      'history': 'Historique',
      'explore': 'Explorer',
      'profile': 'Profil',

      // Recherche
      'search_hint': 'Demandez n\'importe quel mot',
      'search_button': 'Rechercher',
      'additional_search': 'Rechercher plus',
      'searching': 'Recherche...',
      'stop_search': 'Arrêter',
      'search_failed': 'Échec de l\'obtention des résultats de recherche.',
      'search_stopped': 'La recherche a été arrêtée.',
      'no_search_result': 'Aucun résultat de recherche approprié trouvé.',
      'main_search_hint': 'Entrez un mot à rechercher',

      // Sélection de langue
      'from_language': 'De',
      'to_language': 'À',
      'language': 'Langue',
      'english': 'Anglais',
      'korean': 'Coréen',
      'chinese': 'Chinois',
      'taiwanMandarin': 'Mandarin taïwanais',
      'spanish': 'Espagnol',
      'french': 'Français',

      // Résultats de recherche
      'dictionary_meaning': 'Signification',
      'nuance': 'Nuance',
      'conversation_examples': 'Exemples de conversation',
      'similar_expressions': 'Expressions similaires',
      'conversation': 'Conversation',
      'word': 'Mot',

      // Historique de recherche
      'search_history': 'Historique de recherche',
      'no_history': 'Aucun historique de recherche',
      'history_description': 'L\'historique de recherche apparaîtra ici',
      'searched_words': 'Mots recherchés',
      'delete_history': 'Historique de recherche supprimé',
      'delete_failed': 'Échec de la suppression',
      'clear_all_history': 'Effacer tout l\'historique',
      'clear_all_confirm':
          'Supprimer tout l\'historique de recherche ?\nCette action ne peut pas être annulée.',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'close': 'Fermer',
      'all_history_deleted': 'Tout l\'historique de recherche supprimé',

      // Profil
      'profile_title': 'Profil',
      'ai_dictionary_user': 'Utilisateur de $appName',
      'edit_profile': 'Modifier le profil',
      'app_language_setting': 'Langue de l\'application',
      'notification_setting': 'Notifications',
      'notification_description': 'Recevoir des notifications d\'apprentissage',
      'dark_mode': 'Mode sombre',
      'dark_mode_description': 'Suivre les paramètres système',
      'storage': 'Stockage',
      'data': 'Données',
      'data_description': 'Gestion des données',
      'theme': 'Thème',
      'recommended_theme': 'Recommandé',
      'light_theme': 'Clair',
      'dark_theme': 'Sombre',
      'pause_search_history': 'Pause de l\'historique de recherche',
      'pause_search_history_description':
          'Lorsqu\'activé, la sauvegarde de l\'historique de recherche sera mise en pause.',
      'search_history_paused':
          'La sauvegarde de l\'historique de recherche a été mise en pause.',
      'delete_all_history': 'Supprimer tout l\'historique de recherche',
      'delete_account': 'Supprimer le compte',
      'delete_account_description': 'Supprimer définitivement votre compte',
      'delete_account_confirm':
          'Êtes-vous sûr de vouloir supprimer votre compte ?\n\nCette action ne peut pas être annulée et toutes les données seront définitivement supprimées.',
      'delete_account_success': 'Compte supprimé avec succès.',
      'delete_account_failed': 'Échec de la suppression du compte.',
      'password_required_for_delete':
          'Veuillez entrer votre mot de passe pour supprimer votre compte.',
      'password_hint_for_delete': 'Entrez votre mot de passe actuel',
      'help': 'Aide',
      'help_description': 'Utilisation et FAQ',
      'terms_of_service': 'Conditions d\'utilisation',
      'terms_of_service_description': 'Conditions d\'utilisation du service',
      'app_info': 'Informations sur l\'application',
      'app_version': 'Version $appVersion',
      'logout': 'Déconnexion',
      'logout_description': 'Se déconnecter du compte',
      'logout_confirm': 'Êtes-vous sûr de vouloir vous déconnecter ?',
      'logout_success': 'Déconnexion réussie.',
      'system': 'Système',
      'information': 'Information',
      // Pro
      'pro_upgrade': 'Passer à Pro',
      'pro_upgrade_description': 'Avantages Pro et facturation',
      // Pro upgrade screen
      'pro_headline': 'Passer à Pro.',
      'pro_thank_you': 'Merci d’avoir acheté Pro.',
      'pro_subtitle': 'Plus rapide, plus précis et plus pratique.',
      'pro_subtitle_thanks': 'Belle journée à vous !',
      'pro_benefits_title': 'Avantages Pro',
      'pro_benefit_unlimited_title': 'Recherches illimitées',
      'pro_benefit_unlimited_desc': 'Recherchez sans aucune limite.',
      'pro_benefit_better_model_title': 'Modèle IA supérieur',
      'pro_benefit_better_model_desc': 'Plus de 3× de précision et de naturel.',
      'pro_benefit_longer_text_title': 'Traduction de textes plus longs',
      'pro_benefit_longer_text_desc': 'De 500 à 3 000 caractères.',
      'pro_benefit_quality_title': 'Qualité de traduction avancée',
      'pro_benefit_quality_desc': 'Mieux reflète le contexte et la nuance.',
      'pro_benefit_no_ads_title': 'Sans publicité',
      'pro_benefit_no_ads_desc': 'Une interface claire et centrée.',
      'pro_benefit_extras_title': 'Fonctionnalités supplémentaires',
      'pro_benefit_extras_desc': 'Accédez d’abord aux nouveautés et langues.',
      'pro_monthly': 'Mensuel',
      'pro_yearly': 'Annuel',
      'pro_upgrade_cta': 'Passer à Pro',
      'pro_payment_coming_soon': 'Le paiement arrive bientôt.',
      'pro_monthly_price': '{currency}{price} par mois',
      'pro_yearly_price': '{currency}{price} par an',
      'pro_model_quota_tooltip':
          'Recherches avec le modèle Pro restantes aujourd’hui\nRéinitialisation demain à 00:00',
      'pro_upgrade_overlay_message':
          'Abonnez‑vous à Pro pour continuer davantage de recherches.',

      // Utilisateur invité
      'guest_user': 'Utilisateur invité',
      'guest_description':
          'Connectez-vous pour accéder à plus de fonctionnalités',

      // Connexion/Inscription
      'login': 'Se connecter',
      'register': 'S\'inscrire',
      'login_subtitle': 'Se connecter à $appName',
      'register_subtitle': 'Créer un nouveau compte',
      'email': 'E-mail',
      'email_hint': 'Entrez votre e-mail',
      'email_required': 'Veuillez entrer votre e-mail',
      'email_invalid': 'Veuillez entrer un format d\'e-mail valide',
      'password': 'Mot de passe',
      'password_hint': 'Entrez votre mot de passe',
      'password_required': 'Veuillez entrer votre mot de passe',
      'password_too_short':
          'Le mot de passe doit contenir au moins 6 caractères',
      'forgot_password': 'Mot de passe oublié',
      'forgot_password_description':
          'Nous vous enverrons un lien de réinitialisation par e-mail',
      'forgot_password_description_check_spam_folder':
          'Si vous ne recevez pas l\'e-mail, veuillez vérifier votre dossier spam.',
      'reset_password_email_sent':
          'L\'e-mail de réinitialisation du mot de passe a été envoyé.',
      'reset_password_email_failed':
          'Échec de l\'envoi de l\'e-mail de réinitialisation du mot de passe.',
      'no_account_register': 'Vous n\'avez pas de compte ? Inscrivez-vous',
      'have_account_login': 'Vous avez déjà un compte ? Connectez-vous',
      'login_failed': 'Échec de la connexion',
      'register_failed': 'Échec de l\'inscription',
      'error_occurred': 'Une erreur s\'est produite',
      'google_login': 'Se connecter avec Google',
      'google_login_failed': 'Échec de la connexion Google',
      'or': 'ou',

      // Dialogues
      'confirm': 'Confirmer',
      'language_changed':
          'La langue de l\'application a été changée en {language}.',
      'feature_coming_soon': 'Fonctionnalité à venir.',
      'app_name': appName,
      'version': 'Version',
      'developer': 'Développeur',
      'ai_dictionary_team': 'Équipe de $appName',

      // Page d'exploration
      'explore_title': 'Explorer',
      'word_of_day': 'Mot du jour',
      'view_details': 'Voir les détails',
      'popular_searches': 'Recherches populaires',
      'word_categories': 'Catégories de mots',
      'daily_life': 'Vie quotidienne',
      'business': 'Affaires',
      'travel': 'Voyage',
      'emotions': 'Émotions',
      'learning': 'Apprentissage',
      'hobby': 'Loisir',
      'language_tips': 'Conseils d\'apprentissage des langues',
      'daily_learning': 'Apprendre 10 minutes par jour',
      'daily_learning_desc':
          'L\'apprentissage constant est important même pour de courtes périodes',
      'use_in_conversation': 'Utiliser dans de vraies conversations',
      'use_in_conversation_desc':
          'Essayez d\'utiliser les mots appris dans de vraies situations',
      'remember_in_sentence': 'Se souvenir dans les phrases',
      'remember_in_sentence_desc':
          'Se souvenir des mots dans leur contexte aide à la rétention',
      'practice_pronunciation': 'Pratiquer la prononciation',
      'practice_pronunciation_desc':
          'Pratiquez la prononciation en parlant à voix haute',
      'trending_words': 'Mots tendance',
      'learning_stats': 'Statistiques d\'apprentissage',
      'today_learning': 'Aujourd\'hui',
      'this_week': 'Cette semaine',
      'total_learning': 'Total',
      'words': 'mots',

      // Temps
      'just_now': 'À l\'instant',
      'minutes_ago': 'Il y a {minutes} minutes',
      'hours_ago': 'Il y a {hours} heures',
      'days_ago': 'Il y a {days} jours',

      // Historique de recherche
      'and_others': 'et',
      'items': ' autres',
      'free_version_history_limit_tooltip':
          'La version gratuite enregistre jusqu’à 20 listes.',

      // Traduction
      'translation': 'Traduction',
      'translation_tone': 'Ton de traduction',
      'input_text': 'Texte d\'entrée',
      'translation_result': 'Résultat de traduction',
      'translate_button': 'Traduire',
      'input_text_hint': 'Entrez le texte à traduire.',
      'translation_result_hint': 'Le résultat de traduction apparaîtra ici.',
      'input_text_copied': 'Texte d\'entrée copié.',
      'translation_result_copied': 'Résultat de traduction copié.',
      'translation_error': 'Une erreur s\'est produite lors de la traduction.',
      'language_change': 'Changement de langue',
      'selected_input_language': 'Langue d\'entrée sélectionnée : ',
      'is_this_language_correct': 'Cette langue est-elle correcte ?',
      'yes': 'Oui',
      'no': 'Non',
      'friendly': 'Amical',
      'basic': 'Basique',
      'polite': 'Poli',
      'formal': 'Formel',

      // Aide / Tutoriel
      'welcome_tutorial': 'Tutoriel de l\'application',
      'tutorial_welcome': 'Bienvenue sur $appName !',
      'tutorial_welcome_desc':
          'Nous allons vous présenter brièvement les principales fonctionnalités de l\'application.',
      'tutorial_search_title': 'Rechercher un mot',
      'tutorial_search_desc':
          'Si vous hésitez sur un sens ou une nuance,\nessayez de rechercher le mot !',
      'tutorial_search_desc_detail':
          'L\'IA vous montrera comment les locuteurs natifs utilisent réellement le mot.',
      'tutorial_search_desc_detail_2':
          'Vous pouvez aussi changer la langue ici.',
      'tutorial_language_title': 'Choisir la langue',
      'tutorial_language_desc':
          'Avant de rechercher, sélectionnez la langue source et la langue cible !',
      'tutorial_language_desc_detail':
          'Si vous choisissez l\'anglais,\nvous pouvez l\'utiliser comme dictionnaire d\'anglais.',
      'tutorial_history_title': 'Historique des recherches',
      'tutorial_history_desc': 'Les mots recherchés seront enregistrés ici.',
      'tutorial_history_desc_detail':
          'En vous connectant, votre historique sera conservé même après réinstallation.',
      'tutorial_translate_title': 'Traduction IA',
      'tutorial_translate_desc':
          'Choisissez un ton de traduction et essayez de traduire une phrase !',
      'tutorial_translate_language_selector_title':
          'Choisir les langues de traduction',
      'tutorial_translate_language_selector_desc':
          'Choisissez la langue source et la langue cible !',
      'tutorial_translate_desc_detail':
          'Choisissez le ton adapté à la situation\npour obtenir un résultat plus naturel.',
      'tutorial_translate_tone_picker_title': 'Ton de traduction',
      'tutorial_translate_tone_picker_desc':
          'Choisissez un ton de traduction adapté à la situation !',
      'tutorial_next': 'Suivant',
      'tutorial_skip': 'Passer',
      'tutorial_skip_all': 'Tout passer',
      'tutorial_finish': 'Commencer',
      'tutorial_dont_show_again': 'Ne plus afficher',
      'tutorial_show_again': 'Afficher à nouveau',
      'tutorial_show_again_desc':
          'Vous pouvez revoir ce tutoriel à tout moment dans les paramètres.',
      // Accueil
      'which_language_question': 'Quelle langue vous intéresse ?',
      'which_language_part1': 'Quelle langue ',
      'which_language_part2': 'vous intéresse ?',
      // Demande d’avis
      'review_thanks_first_search': 'Merci pour votre première recherche !',
      'review_like_app_question': 'Vous aimez utiliser l’app WordVibe ?',
      'review_recommend_play_store':
          'Recommandez-nous en nous notant sur le Play Store',
      'review_rate_now': 'Noter maintenant',
    },
    'es': {
      // Título de la aplicación
      'app_title': appName,

      // Navegación
      'home': 'Inicio',
      'history': 'Historial',
      'explore': 'Explorar',
      'profile': 'Perfil',

      // Búsqueda
      'search_hint': 'Pregunta sobre cualquier palabra',
      'search_button': 'Buscar',
      'additional_search': 'Buscar más',
      'searching': 'Buscando...',
      'stop_search': 'Detener',
      'search_failed': 'Error al obtener resultados de búsqueda.',
      'search_stopped': 'La búsqueda se detuvo.',
      'no_search_result':
          'No se encontraron resultados de búsqueda apropiados.',
      'main_search_hint': 'Ingresa una palabra para buscar',

      // Selección de idioma
      'from_language': 'De',
      'to_language': 'A',
      'language': 'Idioma',
      'english': 'Inglés',
      'korean': 'Coreano',
      'chinese': 'Chino',
      'taiwanMandarin': 'Mandarín de Taiwán',
      'spanish': 'Español',
      'french': 'Francés',

      // Resultados de búsqueda
      'dictionary_meaning': 'Significado',
      'nuance': 'Matiz',
      'conversation_examples': 'Ejemplos de conversación',
      'similar_expressions': 'Expresiones similares',
      'conversation': 'Conversación',
      'word': 'Palabra',

      // Historial de búsqueda
      'search_history': 'Historial de búsqueda',
      'no_history': 'Sin historial de búsqueda',
      'history_description': 'El historial de búsqueda aparecerá aquí',
      'searched_words': 'Palabras buscadas',
      'delete_history': 'Historial de búsqueda eliminado',
      'delete_failed': 'Error al eliminar',
      'clear_all_history': 'Borrar todo el historial',
      'clear_all_confirm':
          '¿Eliminar todo el historial de búsqueda?\nEsta acción no se puede deshacer.',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'close': 'Cerrar',
      'all_history_deleted': 'Todo el historial de búsqueda eliminado',

      // Perfil
      'profile_title': 'Perfil',
      'ai_dictionary_user': 'Usuario de $appName',
      'edit_profile': 'Editar perfil',
      'app_language_setting': 'Idioma de la aplicación',
      'notification_setting': 'Notificaciones',
      'notification_description': 'Recibir notificaciones de aprendizaje',
      'dark_mode': 'Modo oscuro',
      'dark_mode_description': 'Seguir configuración del sistema',
      'storage': 'Almacenamiento',
      'data': 'Datos',
      'data_description': 'Gestión de datos',
      'theme': 'Tema',
      'recommended_theme': 'Recomendado',
      'light_theme': 'Claro',
      'dark_theme': 'Oscuro',
      'pause_search_history': 'Pausar historial de búsqueda',
      'pause_search_history_description':
          'Cuando se active, se pausará el guardado del historial de búsqueda.',
      'search_history_paused':
          'El guardado del historial de búsqueda está actualmente en pausa.',
      'delete_all_history': 'Eliminar todo el historial de búsqueda',
      'delete_account': 'Eliminar cuenta',
      'delete_account_description': 'Eliminar permanentemente su cuenta',
      'delete_account_confirm':
          '¿Está seguro de que desea eliminar su cuenta?\n\nEsta acción no se puede deshacer y todos los datos se eliminarán permanentemente.',
      'delete_account_success': 'Cuenta eliminada exitosamente.',
      'delete_account_failed': 'Error al eliminar la cuenta.',
      'password_required_for_delete':
          'Por favor, ingrese su contraseña para eliminar su cuenta.',
      'password_hint_for_delete': 'Ingrese su contraseña actual',
      'help': 'Ayuda',
      'help_description': 'Uso y FAQ',
      'terms_of_service': 'Términos de servicio',
      'terms_of_service_description': 'Términos de uso del servicio',
      'app_info': 'Información de la aplicación',
      'app_version': 'Versión $appVersion',
      'logout': 'Cerrar sesión',
      'logout_description': 'Cerrar sesión de la cuenta',
      'logout_confirm': '¿Estás seguro de que quieres cerrar sesión?',
      'logout_success': 'Cierre de sesión exitoso.',
      'system': 'Sistema',
      'information': 'Información',
      // Pro
      'pro_upgrade': 'Actualizar a Pro',
      'pro_upgrade_description': 'Beneficios y facturación de Pro',
      // Pro upgrade screen
      'pro_headline': 'Actualiza a Pro.',
      'pro_thank_you': 'Gracias por comprar Pro.',
      'pro_subtitle': 'Más rápido, más preciso y más cómodo.',
      'pro_subtitle_thanks': '¡Que tengas un gran día!',
      'pro_benefits_title': 'Beneficios de Pro',
      'pro_benefit_unlimited_title': 'Búsquedas ilimitadas',
      'pro_benefit_unlimited_desc': 'Busca tanto como quieras sin límites.',
      'pro_benefit_better_model_title': 'Modelo de IA superior',
      'pro_benefit_better_model_desc': 'Más de 3x precisión y naturalidad.',
      'pro_benefit_longer_text_title': 'Traducción de texto más larga',
      'pro_benefit_longer_text_desc': 'De 500 a 3.000 caracteres.',
      'pro_benefit_quality_title': 'Calidad de traducción avanzada',
      'pro_benefit_quality_desc': 'Mejor refleja el contexto y el matiz.',
      'pro_benefit_no_ads_title': 'Sin anuncios',
      'pro_benefit_no_ads_desc': 'Una pantalla limpia y enfocada.',
      'pro_benefit_extras_title': 'Funciones extra',
      'pro_benefit_extras_desc': 'Prueba antes nuevas funciones e idiomas.',
      'pro_monthly': 'Mensual',
      'pro_yearly': 'Anual',
      'pro_upgrade_cta': 'Actualizar a Pro',
      'pro_payment_coming_soon': 'El pago estará disponible pronto.',
      'pro_monthly_price': '{currency}{price} al mes',
      'pro_yearly_price': '{currency}{price} al año',
      'pro_model_quota_tooltip':
          'Búsquedas con modelo Pro restantes hoy\nSe restablecen mañana a las 00:00',
      'pro_upgrade_overlay_message':
          'Suscríbete a Pro para continuar con más búsquedas.',

      // Usuario invitado
      'guest_user': 'Usuario invitado',
      'guest_description': 'Inicia sesión para acceder a más funciones',

      // Iniciar sesión/Registrarse
      'login': 'Iniciar sesión',
      'register': 'Registrarse',
      'login_subtitle': 'Iniciar sesión en $appName',
      'register_subtitle': 'Crear una nueva cuenta',
      'email': 'Correo electrónico',
      'email_hint': 'Ingresa tu correo electrónico',
      'email_required': 'Por favor ingresa tu correo electrónico',
      'email_invalid': 'Por favor ingresa un formato de correo válido',
      'password': 'Contraseña',
      'password_hint': 'Ingresa tu contraseña',
      'password_required': 'Por favor ingresa tu contraseña',
      'password_too_short': 'La contraseña debe tener al menos 6 caracteres',
      'forgot_password': '¿Olvidaste tu contraseña?',
      'forgot_password_description':
          'Te enviaremos un enlace de restablecimiento por correo electrónico',
      'forgot_password_description_check_spam_folder':
          'Si no recibes el correo, por favor revisa tu carpeta de spam.',
      'reset_password_email_sent':
          'Se ha enviado el correo de restablecimiento de contraseña.',
      'reset_password_email_failed':
          'Error al enviar el correo de restablecimiento de contraseña.',
      'no_account_register': '¿No tienes cuenta? Regístrate',
      'have_account_login': '¿Ya tienes cuenta? Inicia sesión',
      'login_failed': 'Error al iniciar sesión',
      'register_failed': 'Error al registrarse',
      'error_occurred': 'Ocurrió un error',
      'google_login': 'Iniciar sesión con Google',
      'google_login_failed': 'Error al iniciar sesión con Google',
      'or': 'o',

      // Diálogos
      'confirm': 'Confirmar',
      'language_changed': 'El idioma de la aplicación cambió a {language}.',
      'feature_coming_soon': 'Función próximamente.',
      'app_name': appName,
      'version': 'Versión',
      'developer': 'Desarrollador',
      'ai_dictionary_team': 'Equipo de $appName',

      // Página de exploración
      'explore_title': 'Explorar',
      'word_of_day': 'Palabra del día',
      'view_details': 'Ver detalles',
      'popular_searches': 'Búsquedas populares',
      'word_categories': 'Categorías de palabras',
      'daily_life': 'Vida diaria',
      'business': 'Negocios',
      'travel': 'Viaje',
      'emotions': 'Emociones',
      'learning': 'Aprendizaje',
      'hobby': 'Pasatiempo',
      'language_tips': 'Consejos de aprendizaje de idiomas',
      'daily_learning': 'Aprender 10 minutos diarios',
      'daily_learning_desc':
          'El aprendizaje constante es importante incluso por períodos cortos',
      'use_in_conversation': 'Usar en conversaciones reales',
      'use_in_conversation_desc':
          'Intenta usar las palabras aprendidas en situaciones reales',
      'remember_in_sentence': 'Recordar en oraciones',
      'remember_in_sentence_desc':
          'Recordar palabras en contexto ayuda a la retención',
      'practice_pronunciation': 'Practicar pronunciación',
      'practice_pronunciation_desc':
          'Practica la pronunciación hablando en voz alta',
      'trending_words': 'Palabras de tendencia',
      'learning_stats': 'Estadísticas de aprendizaje',
      'today_learning': 'Hoy',
      'this_week': 'Esta semana',
      'total_learning': 'Total',
      'words': 'palabras',

      // Tiempo
      'just_now': 'Ahora mismo',
      'minutes_ago': 'Hace {minutes} minutos',
      'hours_ago': 'Hace {hours} horas',
      'days_ago': 'Hace {days} días',

      // Historial de búsqueda
      'and_others': 'y',
      'items': ' más',
      'free_version_history_limit_tooltip':
          'La versión gratuita guarda hasta 20 listas.',

      // Traducción
      'translation': 'Traducción',
      'translation_tone': 'Tono de traducción',
      'input_text': 'Texto de entrada',
      'translation_result': 'Resultado de traducción',
      'translate_button': 'Traducir',
      'input_text_hint': 'Ingresa el texto a traducir.',
      'translation_result_hint': 'El resultado de traducción aparecerá aquí.',
      'input_text_copied': 'Texto de entrada copiado.',
      'translation_result_copied': 'Resultado de traducción copiado.',
      'translation_error': 'Ocurrió un error durante la traducción.',
      'language_change': 'Cambio de idioma',
      'selected_input_language': 'Idioma de entrada seleccionado: ',
      'is_this_language_correct': '¿Es correcto este idioma?',
      'yes': 'Sí',
      'no': 'No',
      'friendly': 'Amigable',
      'basic': 'Básico',
      'polite': 'Educado',
      'formal': 'Formal',

      // Ayuda / Tutorial
      'welcome_tutorial': 'Tutorial de la aplicación',
      'tutorial_welcome': '¡Bienvenido a $appName!',
      'tutorial_welcome_desc':
          'Te guiaremos brevemente por las funciones principales de la app.',
      'tutorial_search_title': 'Buscar palabras',
      'tutorial_search_desc':
          'Si tienes dudas sobre el significado o matiz,\n¡intenta buscar la palabra!',
      'tutorial_search_desc_detail':
          'La IA te mostrará cómo usan realmente la palabra los hablantes nativos.',
      'tutorial_search_desc_detail_2': 'También puedes cambiar el idioma aquí.',
      'tutorial_language_title': 'Elegir idioma',
      'tutorial_language_desc':
          '¡Asegúrate de seleccionar el idioma de origen y destino antes de buscar!',
      'tutorial_language_desc_detail':
          'Si seleccionas inglés,\npuedes usarlo como diccionario de inglés.',
      'tutorial_history_title': 'Historial de búsqueda',
      'tutorial_history_desc': 'Las palabras que busques se guardarán aquí.',
      'tutorial_history_desc_detail':
          'Si inicias sesión, tu historial se mantendrá incluso tras reinstalar la app.',
      'tutorial_translate_title': 'Traducción con IA',
      'tutorial_translate_desc':
          'Selecciona un tono de traducción y prueba a traducir una frase.',
      'tutorial_translate_language_selector_title':
          'Elegir idiomas de traducción',
      'tutorial_translate_language_selector_desc':
          '¡Elige de qué idioma a qué idioma traducir!',
      'tutorial_translate_desc_detail':
          'Elige el tono adecuado para la situación\npara obtener resultados más naturales.',
      'tutorial_translate_tone_picker_title': 'Tono de traducción',
      'tutorial_translate_tone_picker_desc':
          '¡Elige un tono de traducción acorde a la situación!',
      'tutorial_next': 'Siguiente',
      'tutorial_skip': 'Omitir',
      'tutorial_skip_all': 'Omitir todo',
      'tutorial_finish': 'Empezar',
      'tutorial_dont_show_again': 'No mostrar de nuevo',
      'tutorial_show_again': 'Ver de nuevo',
      'tutorial_show_again_desc':
          'Puedes ver este tutorial de nuevo en la configuración en cualquier momento.',
      // Inicio
      'which_language_question': '¿Qué idioma le interesa?',
      'which_language_part1': '¿Qué idioma ',
      'which_language_part2': 'le interesa?',
      // Solicitud de reseña
      'review_thanks_first_search': '¡Gracias por tu primera búsqueda!',
      'review_like_app_question': '¿Te gusta usar la app WordVibe?',
      'review_recommend_play_store':
          'Recomiéndanos calificándonos en Play Store',
      'review_rate_now': 'Calificar ahora',
    },
  };

  String get(String key) {
    // zh-TW와 같은 복합 로케일 처리
    String languageCode;
    if (locale.languageCode == 'zh' && locale.countryCode == 'TW') {
      languageCode = 'zh-TW';
    } else {
      languageCode = locale.languageCode;
    }

    final translations =
        _localizedValues[languageCode] ?? _localizedValues['en']!;
    return translations[key] ?? key;
  }

  String getWithParams(String key, Map<String, String> params) {
    String value = get(key);
    params.forEach((paramKey, paramValue) {
      value = value.replaceAll('{$paramKey}', paramValue);
    });
    return value;
  }

  // 검색 관련
  String get search_hint => get('search_hint');
  String get search_button => get('search_button');
  String get additional_search => get('additional_search');
  String get searching => get('searching');
  String get stop_search => get('stop_search');
  String get search_failed => get('search_failed');
  String get search_stopped => get('search_stopped');
  String get no_search_result => get('no_search_result');
  String get main_search_hint => get('main_search_hint');
  String get which_language_part1 => get('which_language_part1');
  String get which_language_part2 => get('which_language_part2');
  String get which_language_question => get('which_language_question');

  // 리뷰 요청
  String get review_thanks_first_search => get('review_thanks_first_search');
  String get review_like_app_question => get('review_like_app_question');
  String get review_recommend_play_store => get('review_recommend_play_store');
  String get review_rate_now => get('review_rate_now');

  // 언어 선택
  String get from_language => get('from_language');
  String get to_language => get('to_language');
  String get language => get('language');
  String get english => get('english');
  String get korean => get('korean');
  String get chinese => get('chinese');
  String get taiwanMandarin => get('taiwanMandarin');
  String get spanish => get('spanish');
  String get french => get('french');

  // 검색 결과
  String get dictionary_meaning => get('dictionary_meaning');
  String get nuance => get('nuance');
  String get conversation_examples => get('conversation_examples');
  String get similar_expressions => get('similar_expressions');
  String get conversation => get('conversation');
  String get word => get('word');

  // 검색 기록
  String get search_history => get('search_history');
  String get no_history => get('no_history');
  String get history_description => get('history_description');
  String get searched_words => get('searched_words');
  String get delete_history => get('delete_history');
  String get delete_failed => get('delete_failed');
  String get clear_all_history => get('clear_all_history');
  String get clear_all_confirm => get('clear_all_confirm');
  String get cancel => get('cancel');
  String get delete => get('delete');
  String get close => get('close');
  String get all_history_deleted => get('all_history_deleted');

  // 시간 관련
  String get just_now => get('just_now');
  String get minutes_ago => get('minutes_ago');
  String get hours_ago => get('hours_ago');
  String get days_ago => get('days_ago');

  // 검색 기록 관련
  String get and_others => get('and_others');
  String get items => get('items');

  // 추가 키 (툴팁/오버레이)
  String get free_version_history_limit_tooltip =>
      get('free_version_history_limit_tooltip');
  String get pro_model_quota_tooltip => get('pro_model_quota_tooltip');
  String get pro_upgrade_overlay_message => get('pro_upgrade_overlay_message');

  // 번역 관련
  String get translation => get('translation');
  String get translation_tone => get('translation_tone');
  String get input_text => get('input_text');
  String get translation_result => get('translation_result');
  String get translate_button => get('translate_button');
  String get input_text_hint => get('input_text_hint');
  String get translation_result_hint => get('translation_result_hint');
  String get input_text_copied => get('input_text_copied');
  String get translation_result_copied => get('translation_result_copied');
  String get translation_error => get('translation_error');
  String get language_change => get('language_change');
  String get selected_input_language => get('selected_input_language');
  String get is_this_language_correct => get('is_this_language_correct');
  String get yes => get('yes');
  String get no => get('no');
  String get friendly => get('friendly');
  String get basic => get('basic');
  String get polite => get('polite');
  String get formal => get('formal');

  // 도움말 관련
  String get welcome_tutorial => get('welcome_tutorial');
  String get tutorial_welcome => get('tutorial_welcome');
  String get tutorial_welcome_desc => get('tutorial_welcome_desc');
  String get tutorial_search_title => get('tutorial_search_title');
  String get tutorial_search_desc => get('tutorial_search_desc');
  String get tutorial_search_desc_detail => get('tutorial_search_desc_detail');
  String get tutorial_search_desc_detail_2 =>
      get('tutorial_search_desc_detail_2');
  String get tutorial_language_title => get('tutorial_language_title');
  String get tutorial_language_desc => get('tutorial_language_desc');
  String get tutorial_language_desc_detail =>
      get('tutorial_language_desc_detail');
  String get tutorial_history_title => get('tutorial_history_title');
  String get tutorial_history_desc => get('tutorial_history_desc');
  String get tutorial_history_desc_detail =>
      get('tutorial_history_desc_detail');
  String get tutorial_translate_title => get('tutorial_translate_title');
  String get tutorial_translate_desc => get('tutorial_translate_desc');
  String get tutorial_translate_language_selector_title =>
      get('tutorial_translate_language_selector_title');
  String get tutorial_translate_language_selector_desc =>
      get('tutorial_translate_language_selector_desc');
  String get tutorial_translate_desc_detail =>
      get('tutorial_translate_desc_detail');
  String get tutorial_translate_tone_picker_title =>
      get('tutorial_translate_tone_picker_title');
  String get tutorial_translate_tone_picker_desc =>
      get('tutorial_translate_tone_picker_desc');
  String get tutorial_next => get('tutorial_next');
  String get tutorial_skip => get('tutorial_skip');
  String get tutorial_skip_all => get('tutorial_skip_all');
  String get tutorial_finish => get('tutorial_finish');
  String get tutorial_dont_show_again => get('tutorial_dont_show_again');
  String get tutorial_show_again => get('tutorial_show_again');
  String get tutorial_show_again_desc => get('tutorial_show_again_desc');
}

/// 로컬라이제이션 델리게이트
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // zh-TW와 같은 복합 로케일을 제대로 처리
    if (locale.languageCode == 'zh' && locale.countryCode == 'TW') {
      return true;
    }

    return ['ko', 'en', 'zh', 'fr', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
