import 'package:flutter/material.dart';

/// 앱의 다국어 지원을 위한 로컬라이제이션 클래스
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // 앱 이름 상수
  static const String appName = 'Sasha';

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
      'main_search_hint': '검색할 단어를 입력해보세요',

      // 언어 선택
      'from_language': '출발 언어',
      'to_language': '도착 언어',
      'language': '언어',
      'english': '영어',
      'korean': '한국어',
      'chinese': '중국어',
      'taiwanese': '대만어',
      'spanish': '스페인어',
      'french': '프랑스어',

      // 검색 결과
      'dictionary_meaning': '사전적 뜻',
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
      'pause_search_history': '검색 기록 저장 일시중지',
      'pause_search_history_description': '활성화하면 검색 기록 저장이 중지됩니다.',
      'search_history_paused': '현재 검색 기록 저장이 일시중지 상태입니다.',
      'delete_all_history': '모든 검색 기록 삭제',
      'delete_account': '계정 삭제',
      'help': '도움말',
      'help_description': '사용법 및 FAQ',
      'app_info': '앱 정보',
      'app_version': '버전 1.0.0',
      'logout': '로그아웃',
      'logout_description': '계정에서 로그아웃',
      'logout_confirm': '정말 로그아웃하시겠습니까?',
      'logout_success': '로그아웃되었습니다.',
      'system': '시스템',
      'information': '정보',

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
      'main_search_hint': 'Enter a word to search',

      // Language Selection
      'from_language': 'From',
      'to_language': 'To',
      'language': 'Language',
      'english': 'English',
      'korean': 'Korean',
      'chinese': 'Chinese',
      'taiwanese': 'Taiwanese',
      'spanish': 'Spanish',
      'french': 'French',

      // Search Results
      'dictionary_meaning': 'Dictionary Meaning',
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
      'pause_search_history': 'Pause search history',
      'pause_search_history_description':
          'When activated, search history saving will be paused.',
      'search_history_paused': 'Search history saving is currently paused.',
      'delete_all_history': 'Delete all search history',
      'delete_account': 'Delete account',
      'help': 'Help',
      'help_description': 'Usage and FAQ',
      'app_info': 'App Info',
      'app_version': 'Version 1.0.0',
      'logout': 'Logout',
      'logout_description': 'Logout from account',
      'logout_confirm': 'Are you sure you want to logout?',
      'logout_success': 'Logged out successfully.',
      'system': 'System',
      'information': 'Information',

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
      'main_search_hint': '输入要搜索的单词',

      // 语言选择
      'from_language': '从',
      'to_language': '到',
      'language': '语言',
      'english': '英语',
      'korean': '韩语',
      'chinese': '中文',
      'taiwanese': '繁体中文',
      'spanish': '西班牙语',
      'french': '法语',

      // 搜索结果
      'dictionary_meaning': '词典含义',
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
      'pause_search_history': '暂停搜索历史记录',
      'pause_search_history_description': '激活后，搜索历史记录保存将被暂停。',
      'search_history_paused': '当前搜索历史记录保存处于暂停状态。',
      'delete_all_history': '删除所有搜索历史记录',
      'delete_account': '删除账户',
      'help': '帮助',
      'help_description': '使用方法和常见问题',
      'app_info': '应用信息',
      'app_version': '版本 1.0.0',
      'logout': '退出登录',
      'logout_description': '从账户退出',
      'logout_confirm': '确定要退出登录吗？',
      'logout_success': '已成功退出登录。',
      'system': '系统',
      'information': '信息',

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
      'main_search_hint': '輸入要搜尋的單字',

      // 語言選擇
      'from_language': '從',
      'to_language': '到',
      'language': '語言',
      'english': '英語',
      'korean': '韓語',
      'chinese': '簡體中文',
      'taiwanese': '繁體中文',
      'spanish': '西班牙語',
      'french': '法語',

      // 搜尋結果
      'dictionary_meaning': '辭典含義',
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
      'pause_search_history': '暫停搜尋歷史記錄',
      'pause_search_history_description': '啟用後，搜尋歷史記錄儲存將被暫停。',
      'search_history_paused': '目前搜尋歷史記錄儲存為暫停狀態。',
      'delete_all_history': '刪除所有搜尋歷史記錄',
      'delete_account': '刪除帳戶',
      'help': '幫助',
      'help_description': '使用方法和常見問題',
      'app_info': '應用資訊',
      'app_version': '版本 1.0.0',
      'logout': '登出',
      'logout_description': '從帳戶登出',
      'logout_confirm': '確定要登出嗎？',
      'logout_success': '已成功登出。',
      'system': '系統',
      'information': '資訊',

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
      'main_search_hint': 'Entrez un mot à rechercher',

      // Sélection de langue
      'from_language': 'De',
      'to_language': 'À',
      'language': 'Langue',
      'english': 'Anglais',
      'korean': 'Coréen',
      'chinese': 'Chinois',
      'taiwanese': 'Taiwanais',
      'spanish': 'Espagnol',
      'french': 'Français',

      // Résultats de recherche
      'dictionary_meaning': 'Signification du dictionnaire',
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
      'pause_search_history': 'Pause de l\'historique de recherche',
      'pause_search_history_description':
          'Lorsqu\'activé, la sauvegarde de l\'historique de recherche sera mise en pause.',
      'search_history_paused':
          'La sauvegarde de l\'historique de recherche a été mise en pause.',
      'delete_all_history': 'Supprimer tout l\'historique de recherche',
      'delete_account': 'Supprimer le compte',
      'help': 'Aide',
      'help_description': 'Utilisation et FAQ',
      'app_info': 'Informations sur l\'application',
      'app_version': 'Version 1.0.0',
      'logout': 'Déconnexion',
      'logout_description': 'Se déconnecter du compte',
      'logout_confirm': 'Êtes-vous sûr de vouloir vous déconnecter ?',
      'logout_success': 'Déconnexion réussie.',
      'system': 'Système',
      'information': 'Information',

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
      'main_search_hint': 'Ingresa una palabra para buscar',

      // Selección de idioma
      'from_language': 'De',
      'to_language': 'A',
      'language': 'Idioma',
      'english': 'Inglés',
      'korean': 'Coreano',
      'chinese': 'Chino',
      'taiwanese': 'Taiwanés',
      'spanish': 'Español',
      'french': 'Francés',

      // Resultados de búsqueda
      'dictionary_meaning': 'Significado del diccionario',
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
      'pause_search_history': 'Pausar historial de búsqueda',
      'pause_search_history_description':
          'Cuando se active, se pausará el guardado del historial de búsqueda.',
      'search_history_paused':
          'El guardado del historial de búsqueda está actualmente en pausa.',
      'delete_all_history': 'Eliminar todo el historial de búsqueda',
      'delete_account': 'Eliminar cuenta',
      'help': 'Ayuda',
      'help_description': 'Uso y FAQ',
      'app_info': 'Información de la aplicación',
      'app_version': 'Versión 1.0.0',
      'logout': 'Cerrar sesión',
      'logout_description': 'Cerrar sesión de la cuenta',
      'logout_confirm': '¿Estás seguro de que quieres cerrar sesión?',
      'logout_success': 'Cierre de sesión exitoso.',
      'system': 'Sistema',
      'information': 'Información',

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
  String get main_search_hint => get('main_search_hint');

  // 언어 선택
  String get from_language => get('from_language');
  String get to_language => get('to_language');
  String get language => get('language');
  String get english => get('english');
  String get korean => get('korean');
  String get chinese => get('chinese');
  String get taiwanese => get('taiwanese');
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
  String get all_history_deleted => get('all_history_deleted');

  // 시간 관련
  String get just_now => get('just_now');
  String get minutes_ago => get('minutes_ago');
  String get hours_ago => get('hours_ago');
  String get days_ago => get('days_ago');

  // 검색 기록 관련
  String get and_others => get('and_others');
  String get items => get('items');

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
