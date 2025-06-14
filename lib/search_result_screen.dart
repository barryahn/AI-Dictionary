import 'package:flutter/material.dart';

// 검색 결과 화면 위젯
class SearchResultScreen extends StatelessWidget {
  final String query;
  // 생성자에서 검색어를 받음
  const SearchResultScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 상단 앱바 (공유 버튼 포함)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
      ),
      // 본문 영역
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // 검색 입력창 (읽기 전용)
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: query),
            style: const TextStyle(fontSize: 28, color: Colors.black),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
          const Divider(thickness: 1),
          // 검색어(큰 글씨)
          const SizedBox(height: 8),
          Text(
            query,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          // 품사 정보
          const Text(
            '부사구',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          // 사전적 의미
          const SizedBox(height: 16),
          const Text(
            '사전적 의미',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          const Text('(특히 의문문에서) 혹시라도', style: TextStyle(fontSize: 16)),
          // 활용 예시
          const SizedBox(height: 16),
          const Text(
            '활용 예시',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          // 예문 리스트
          _ExampleRow(
            en: 'Do you, by any chance, have a pen I could borrow?',
            ko: '혹시 빌릴 수 있는 펜 있어요?',
          ),
          _ExampleRow(
            en: 'Are you, by any chance, free this weekend?',
            ko: '혹시 이번 주말에 시간 괜찮아요?',
          ),
          _ExampleRow(
            en: 'By any chance, did you see my phone?',
            ko: '혹시 내 핸드폰 봤어?',
          ),
          _ExampleRow(
            en: 'Would you, by any chance, know where the station is?',
            ko: '혹시 역이 어디 있는지 아세요?',
          ),
          _ExampleRow(
            en: 'He didn\'t, by any chance, mention my name, did he?',
            ko: '걔가 혹시라도 내 이름 언급하지는 않았지?',
          ),
          // 비슷한 표현
          const SizedBox(height: 16),
          const Text(
            '비슷한 표현',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'possibly 어쩌면, 아마도 (좀 더 일반적이고 중립적)\nperhaps 아마도, 어쩌면 (약간 문어체 느낌도 있음)\nWould you mind...? 정중한 요청 표현 (by any chance와 함께 자주 씀)',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// 예문(영어/한글) 표시용 위젯
class _ExampleRow extends StatelessWidget {
  final String en;
  final String ko;
  const _ExampleRow({required this.en, required this.ko});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(en, style: const TextStyle(fontSize: 16)),
          Text(ko, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
