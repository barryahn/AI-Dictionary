import 'package:flutter/material.dart';

/// 앱의 다국어 지원을 위한 로컬라이제이션 클래스
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'ko': {
      // 앱 제목
      'app_title': 'AI Dictionary',

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
      'clear_all_confirm': '모든 검색 기록을 삭제하시겠습니까?',
      'cancel': '취소',
      'delete': '삭제',
      'all_history_deleted': '모든 검색 기록이 삭제되었습니다',

      // 프로필
      'profile_title': '프로필',
      'ai_dictionary_user': 'AI Dictionary 사용자',
      'edit_profile': '프로필 편집',
      'app_language_setting': '앱 언어 설정',
      'notification_setting': '알림 설정',
      'notification_description': '학습 알림 받기',
      'dark_mode': '다크 모드',
      'dark_mode_description': '시스템 설정 따름',
      'storage': '저장 공간',
      'storage_description': '검색 기록 관리',
      'help': '도움말',
      'help_description': '사용법 및 FAQ',
      'app_info': '앱 정보',
      'app_version': '버전 1.0.0',
      'logout': '로그아웃',
      'logout_description': '계정에서 로그아웃',
      'logout_confirm': '정말 로그아웃하시겠습니까?',

      // 다이얼로그
      'confirm': '확인',
      'language_changed': '앱 언어가 {language}로 변경되었습니다.',
      'feature_coming_soon': '기능은 준비 중입니다.',
      'app_name': 'AI Dictionary',
      'version': '버전',
      'developer': '개발자',
      'ai_dictionary_team': 'AI Dictionary Team',

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
    },
    'en': {
      // App Title
      'app_title': 'AI Dictionary',

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
      'clear_all_confirm': 'Delete all search history?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'all_history_deleted': 'All search history deleted',

      // Profile
      'profile_title': 'Profile',
      'ai_dictionary_user': 'AI Dictionary User',
      'edit_profile': 'Edit Profile',
      'app_language_setting': 'App Language',
      'notification_setting': 'Notifications',
      'notification_description': 'Receive learning notifications',
      'dark_mode': 'Dark Mode',
      'dark_mode_description': 'Follow system settings',
      'storage': 'Storage',
      'storage_description': 'Manage search history',
      'help': 'Help',
      'help_description': 'Usage and FAQ',
      'app_info': 'App Info',
      'app_version': 'Version 1.0.0',
      'logout': 'Logout',
      'logout_description': 'Logout from account',
      'logout_confirm': 'Are you sure you want to logout?',

      // Dialogs
      'confirm': 'Confirm',
      'language_changed': 'App language changed to {language}.',
      'feature_coming_soon': 'Feature coming soon.',
      'app_name': 'AI Dictionary',
      'version': 'Version',
      'developer': 'Developer',
      'ai_dictionary_team': 'AI Dictionary Team',

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
    },
    'zh': {
      // 应用标题
      'app_title': 'AI 词典',

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
      'clear_all_confirm': '删除所有搜索历史？',
      'cancel': '取消',
      'delete': '删除',
      'all_history_deleted': '所有搜索历史已删除',

      // 个人资料
      'profile_title': '个人资料',
      'ai_dictionary_user': 'AI 词典用户',
      'edit_profile': '编辑资料',
      'app_language_setting': '应用语言',
      'notification_setting': '通知',
      'notification_description': '接收学习通知',
      'dark_mode': '深色模式',
      'dark_mode_description': '跟随系统设置',
      'storage': '存储',
      'storage_description': '管理搜索历史',
      'help': '帮助',
      'help_description': '使用方法和常见问题',
      'app_info': '应用信息',
      'app_version': '版本 1.0.0',
      'logout': '退出登录',
      'logout_description': '从账户退出',
      'logout_confirm': '确定要退出登录吗？',

      // 对话框
      'confirm': '确认',
      'language_changed': '应用语言已更改为{language}。',
      'feature_coming_soon': '功能即将推出。',
      'app_name': 'AI 词典',
      'version': '版本',
      'developer': '开发者',
      'ai_dictionary_team': 'AI 词典团队',

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
    },
    'fr': {
      // Titre de l'application
      'app_title': 'Dictionnaire IA',

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
      'clear_all_confirm': 'Supprimer tout l\'historique de recherche ?',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'all_history_deleted': 'Tout l\'historique de recherche supprimé',

      // Profil
      'profile_title': 'Profil',
      'ai_dictionary_user': 'Utilisateur du Dictionnaire IA',
      'edit_profile': 'Modifier le profil',
      'app_language_setting': 'Langue de l\'application',
      'notification_setting': 'Notifications',
      'notification_description': 'Recevoir des notifications d\'apprentissage',
      'dark_mode': 'Mode sombre',
      'dark_mode_description': 'Suivre les paramètres système',
      'storage': 'Stockage',
      'storage_description': 'Gérer l\'historique de recherche',
      'help': 'Aide',
      'help_description': 'Utilisation et FAQ',
      'app_info': 'Informations sur l\'application',
      'app_version': 'Version 1.0.0',
      'logout': 'Déconnexion',
      'logout_description': 'Se déconnecter du compte',
      'logout_confirm': 'Êtes-vous sûr de vouloir vous déconnecter ?',

      // Dialogues
      'confirm': 'Confirmer',
      'language_changed':
          'La langue de l\'application a été changée en {language}.',
      'feature_coming_soon': 'Fonctionnalité à venir.',
      'app_name': 'Dictionnaire IA',
      'version': 'Version',
      'developer': 'Développeur',
      'ai_dictionary_team': 'Équipe du Dictionnaire IA',

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
    },
    'es': {
      // Título de la aplicación
      'app_title': 'Diccionario IA',

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
      'clear_all_confirm': '¿Eliminar todo el historial de búsqueda?',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'all_history_deleted': 'Todo el historial de búsqueda eliminado',

      // Perfil
      'profile_title': 'Perfil',
      'ai_dictionary_user': 'Usuario del Diccionario IA',
      'edit_profile': 'Editar perfil',
      'app_language_setting': 'Idioma de la aplicación',
      'notification_setting': 'Notificaciones',
      'notification_description': 'Recibir notificaciones de aprendizaje',
      'dark_mode': 'Modo oscuro',
      'dark_mode_description': 'Seguir configuración del sistema',
      'storage': 'Almacenamiento',
      'storage_description': 'Gestionar historial de búsqueda',
      'help': 'Ayuda',
      'help_description': 'Uso y FAQ',
      'app_info': 'Información de la aplicación',
      'app_version': 'Versión 1.0.0',
      'logout': 'Cerrar sesión',
      'logout_description': 'Cerrar sesión de la cuenta',
      'logout_confirm': '¿Estás seguro de que quieres cerrar sesión?',

      // Diálogos
      'confirm': 'Confirmar',
      'language_changed': 'El idioma de la aplicación cambió a {language}.',
      'feature_coming_soon': 'Función próximamente.',
      'app_name': 'Diccionario IA',
      'version': 'Versión',
      'developer': 'Desarrollador',
      'ai_dictionary_team': 'Equipo del Diccionario IA',

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
    },
  };

  String get(String key) {
    final languageCode = locale.languageCode;
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
}

/// 로컬라이제이션 델리게이트
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ko', 'en', 'zh', 'fr', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
