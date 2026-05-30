import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnalysisRecordManager {
  // Shared state: User ID and Username session variables
  static String? currentUserId;
  static String? currentUsername;
  static bool get isLoggedIn => currentUserId != null;

  // Shared state: Static list of all analysis records for the current user
  static final List<Map<String, dynamic>> records = [
    {
      'title': '錦錨餐廳',
      'subtitle': '2 小時前分析 • 共 80 則評論',
      'score': 85,
      'starRating': 4.2,
      'originalStarRating': 4.5,
      'icon': Icons.restaurant,
      'label': '信譽良好',
      'zeroTextSpam': '未發現顯著無文字五星灌水現象，真實度良好。',
      'duplicatePatterns': '未發現大量重複罐頭評論，評論個體化程度高。',
      'incentivizedTriggers': '發現 2 則評論提及打卡送小菜。',
      'serviceAttitude': '未發現顯著服務態度問題，顧客稱讚櫃檯親切。',
      'environmentHygiene': '有 1 則抱怨說杯子洗得不夠乾淨。',
      'lowStarAnalysis': '低星差評比例低，已過濾無理惡意差評，真實反映餐具偶有不潔狀況。',
      'midStarAnalysis': '中星評論反映出尖峰時段出餐速度較慢，但分量足夠。',
      'highStarAnalysis': '多數高星好評描述詳細，推測為真實滿意度反映。',
      'maliciousBombDetected': false,
      'maliciousBombRatio': 0,
      'isBookmarked': true,
    },
    {
      'title': '老街豆花',
      'subtitle': '4 小時前分析 • 共 50 則評論',
      'score': 68,
      'starRating': 3.8,
      'originalStarRating': 4.4,
      'icon': Icons.icecream_outlined,
      'label': '信譽良好',
      'zeroTextSpam': '無字好評比例偏高 (25%)，顯示有部分灌水跡象。',
      'duplicatePatterns': '發現少量類似「推推！下次還要再來！」的罐頭評論。',
      'incentivizedTriggers': '發現有打卡送豆漿的行銷推廣痕跡。',
      'serviceAttitude': '部分顧客反映店員動作稍慢，但態度依然客氣。',
      'environmentHygiene': '桌椅清理乾淨，衛生大致良好。',
      'lowStarAnalysis': '低星差評多因排隊等待時間過長引起，為正常客觀抱怨。',
      'midStarAnalysis': '多數顧客給予中評，表示分量與價格均屬正常，無功無過。',
      'highStarAnalysis': '好評以觀光客分享為主，夾雜了部分店家贈禮的打卡評論。',
      'maliciousBombDetected': false,
      'maliciousBombRatio': 3,
      'isBookmarked': false,
    },
    {
      'title': '42號小館',
      'subtitle': '5 小時前分析 • 共 100 則評論',
      'score': 32,
      'starRating': 2.3,
      'originalStarRating': 4.8,
      'icon': Icons.restaurant,
      'label': '信譽較差',
      'zeroTextSpam': '無字五星好評暴增 (75%)，有高度水軍刷榜嫌疑。',
      'duplicatePatterns': '發現大量完全重複的模板文「老闆人很好！環境乾淨！推！」。',
      'incentivizedTriggers': '明確查獲大量行銷活動洗評現象。',
      'serviceAttitude': '多位真實顧客投訴服務人員態度冷漠、甚至跟客人爭吵。',
      'environmentHygiene': '多篇真實差評指出桌子黏膩、筷子有前人的油漬，衛生堪憂。',
      'lowStarAnalysis': '低星評論多數指出核心服務與衛生痛點，包含出餐不乾淨、服務員態度惡劣，為真實嚴重投訴。',
      'midStarAnalysis': '幾乎沒有中立評論，分數分佈呈極端兩極化，顯示人為操縱分數明顯。',
      'highStarAnalysis': '好評高達 90% 均為無文字或極端簡短的主廚空洞讚美，具高度虛假灌水特徵。',
      'maliciousBombDetected': true,
      'maliciousBombRatio': 8,
      'isBookmarked': false,
    },
    {
      'title': '極品燒肉',
      'subtitle': '3 天前分析 • 共 90 則評論',
      'score': 92,
      'starRating': 4.6,
      'originalStarRating': 4.7,
      'icon': Icons.local_fire_department,
      'label': '信譽極佳',
      'zeroTextSpam': '未發現任何灌水嫌疑，星等可信度極高。',
      'duplicatePatterns': '完全無重複罐頭文特徵，評論極具個人就餐感受。',
      'incentivizedTriggers': '完全未提及任何好評送禮等利益誘因行為。',
      'serviceAttitude': '極致好評！多則評論具體點名感謝特定桌邊服務人員之貼心。',
      'environmentHygiene': '環境排煙一流，乾淨整潔無異味。',
      'lowStarAnalysis': '極少數低星差評均為預約困難或價格高昂的抱怨，無同行惡意攻擊特徵。',
      'midStarAnalysis': '中星評論指出假日較難停車。',
      'highStarAnalysis': '極高比例的真實正面反饋，描述細緻生動，可信度極優。',
      'maliciousBombDetected': false,
      'maliciousBombRatio': 0,
      'isBookmarked': true,
    }
  ];

  // User account profile state
  static final Map<String, dynamic> userProfile = {
    'name': '陳大文',
    'email': 'raymond.chan@example.com',
    'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBotv-3k9fTLaVQdRQJq_99AZrp_AKais_eqZQ-FTbKwSwwO7TRbAUBJzViO8tK55nnRphO7kgOXblx4xIU6nbH3vRVWKzPLmcqziv6rrXhzmzkVzw-dreb1QPp-OqQ7eeUkvN2Aw8pN0s5IGCjsomWLIkXL-DILAn19-o4t1b2Wbf10UUGF7-UEje5aaysnwJYqUgbUIyweXFYVb4BZookC9vXZMZXjIx9q-BPlqqE157_KbJ8dXkcTdJ73LJCRJ2102WtUfT-Gu-0',
    'isGoogleConnected': true,
    'isAppleConnected': false,
    'isLineConnected': false,
  };

  // User preferences state
  static final Map<String, dynamic> preferences = {
    'sampleSize': 80,
    'focusArea': '全部',
  };

  // Callback to notify screens when state changes
  static final List<VoidCallback> _listeners = [];

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  // 1. 註冊方法
  static Future<bool> register(String username, String password, String name, String email) async {
    final apiUrl = Uri.parse('http://127.0.0.1:8000/user/register');
    try {
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'name': name,
          'email': email,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        final err = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        throw Exception(err['detail'] ?? '註冊失敗！');
      }
    } catch (e) {
      print('Register Error: $e');
      rethrow;
    }
  }

  // 2. 登入方法
  static Future<bool> login(String username, String password) async {
    final apiUrl = Uri.parse('http://127.0.0.1:8000/user/login');
    try {
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>;
        currentUserId = user['id'].toString();
        currentUsername = user['username'].toString();
        
        // 登入成功後，拉取該使用者專屬歷史紀錄與檔案
        await fetchUserData();
        return true;
      } else {
        final err = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        throw Exception(err['detail'] ?? '登入失敗！');
      }
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }

  // 3. 獲取使用者專屬資料與歷史紀錄
  static Future<void> fetchUserData() async {
    if (currentUserId == null) return;
    final headers = {'x-user-id': currentUserId!};
    
    // a. 獲取個人檔案
    try {
      final profResp = await http.get(
        Uri.parse('http://127.0.0.1:8000/user/profile'),
        headers: headers,
      );
      if (profResp.statusCode == 200) {
        final data = jsonDecode(utf8.decode(profResp.bodyBytes)) as Map<String, dynamic>;
        userProfile['name'] = data['name'] ?? '未定義';
        userProfile['email'] = data['email'] ?? '未定義';
        userProfile['avatar'] = data['avatar'] ?? '';
        userProfile['isGoogleConnected'] = data['isGoogleConnected'] ?? false;
        userProfile['isAppleConnected'] = data['isAppleConnected'] ?? false;
        userProfile['isLineConnected'] = data['isLineConnected'] ?? false;
        preferences['sampleSize'] = data['sampleSize'] ?? 80;
        preferences['focusArea'] = data['focusArea'] ?? '全部';
      }
    } catch (e) {
      print('Fetch Profile Error: $e');
    }

    // b. 獲取該使用者的歷史記錄
    try {
      final histResp = await http.get(
        Uri.parse('http://127.0.0.1:8000/history'),
        headers: headers,
      );
      if (histResp.statusCode == 200) {
        final list = jsonDecode(utf8.decode(histResp.bodyBytes)) as List<dynamic>;
        records.clear();
        for (var item in list) {
          final merchantName = item['title'] ?? '未定義商家';
          
          // 決定分類 Icon
          IconData itemIcon = Icons.storefront;
          if (merchantName.contains('醫院') || merchantName.contains('診所') || merchantName.contains('醫學')) {
            itemIcon = Icons.local_hospital;
          } else if (merchantName.contains('餐廳') || merchantName.contains('咖啡') || merchantName.contains('私廚') || merchantName.contains('館') || merchantName.contains('店')) {
            itemIcon = Icons.restaurant;
          } else if (merchantName.contains('旅店') || merchantName.contains('酒店') || merchantName.contains('民宿') || merchantName.contains('旅館')) {
            itemIcon = Icons.hotel;
          }
          
          records.add({
            'title': merchantName,
            'url': item['url'] ?? merchantName,
            'subtitle': item['subtitle'] ?? '',
            'score': item['score'] ?? 50,
            'starRating': (item['starRating'] ?? 3.5) as double,
            'originalStarRating': (item['originalStarRating'] ?? 4.5) as double,
            'icon': itemIcon,
            'label': item['label'] ?? '中度灌水',
            'zeroTextSpam': item['zeroTextSpam'] ?? '無資料',
            'duplicatePatterns': item['duplicatePatterns'] ?? '無資料',
            'incentivizedTriggers': item['incentivizedTriggers'] ?? '無資料',
            'serviceAttitude': item['serviceAttitude'] ?? '無資料',
            'environmentHygiene': item['environmentHygiene'] ?? '無資料',
            'lowStarAnalysis': item['lowStarAnalysis'] ?? '無資料',
            'midStarAnalysis': item['midStarAnalysis'] ?? '無資料',
            'highStarAnalysis': item['highStarAnalysis'] ?? '無資料',
            'maliciousBombDetected': item['maliciousBombDetected'] ?? false,
            'maliciousBombRatio': item['maliciousBombRatio'] ?? 0,
            'isBookmarked': item['isBookmarked'] ?? false,
          });
        }
      }
    } catch (e) {
      print('Fetch History Error: $e');
    }
    
    _notifyListeners();
  }

  // 4. 登出方法
  static void logout() {
    currentUserId = null;
    currentUsername = null;
    records.clear();
    // 重置為當前 Demo 的初始狀態 (如果點擊重設)
    userProfile['name'] = '陳大文';
    userProfile['email'] = 'raymond.chan@example.com';
    userProfile['isGoogleConnected'] = true;
    userProfile['isAppleConnected'] = false;
    userProfile['isLineConnected'] = false;
    preferences['sampleSize'] = 80;
    preferences['focusArea'] = '全部';
    _notifyListeners();
  }

  // 5. 新增記錄方法 (在本地插入新分析的商家)
  static void addRecord(Map<String, dynamic> record) {
    records.removeWhere((element) => element['title'] == record['title']);
    record['isBookmarked'] = false;
    records.insert(0, record);
    _notifyListeners();
  }

  // 6. 串接 FastAPI /analyze 介面 (帶入 x-user-id Headers)
  static Future<Map<String, dynamic>?> analyzeUrl(String url) async {
    final apiUrl = Uri.parse('http://127.0.0.1:8000/analyze');
    final headers = {
      'Content-Type': 'application/json',
      if (currentUserId != null) 'x-user-id': currentUserId!,
    };
    
    try {
      final response = await http.post(
        apiUrl,
        headers: headers,
        body: jsonEncode({'url': url}),
      ).timeout(const Duration(seconds: 45));
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        
        final merchantName = decoded['merchant_name'] ?? '未定義商家';
        final veriScore = decoded['veri_score'] ?? 50;
        final realStarRating = (decoded['real_star_rating'] ?? 3.5) as double;
        final originalStarRating = (decoded['original_star_rating'] ?? 4.5) as double;
        final totalAnalyzedText = decoded['total_analyzed']?.toString() ?? '50+';
        
        final metrics = decoded['metrics'] as Map<String, dynamic>? ?? {};
        final nlpInsights = decoded['nlp_insights'] as Map<String, dynamic>? ?? {};
        final stratified = decoded['stratified_analysis'] as Map<String, dynamic>? ?? {};
        
        String label = '信譽中等';
        if (veriScore >= 68) {
          label = '信譽良好';
        } else if (veriScore >= 45) {
          label = '信譽中等';
        } else {
          label = '信譽較差';
        }

        IconData itemIcon = Icons.storefront;
        if (merchantName.contains('醫院') || merchantName.contains('診所') || merchantName.contains('醫學')) {
          itemIcon = Icons.local_hospital;
        } else if (merchantName.contains('餐廳') || merchantName.contains('咖啡') || merchantName.contains('私廚') || merchantName.contains('館') || merchantName.contains('店')) {
          itemIcon = Icons.restaurant;
        } else if (merchantName.contains('旅店') || merchantName.contains('酒店') || merchantName.contains('民宿') || merchantName.contains('旅館')) {
          itemIcon = Icons.hotel;
        }

        final Map<String, dynamic> newRecord = {
          'title': merchantName,
          'url': url,
          'subtitle': '剛剛分析 • 共 $totalAnalyzedText 則評論',
          'score': veriScore,
          'starRating': realStarRating,
          'originalStarRating': originalStarRating,
          'icon': itemIcon,
          'label': label,
          'zeroTextSpam': metrics['zero_text_spam'] ?? '無資料',
          'duplicatePatterns': metrics['duplicate_patterns'] ?? '無資料',
          'incentivizedTriggers': metrics['incentivized_triggers'] ?? '無資料',
          'serviceAttitude': nlpInsights['service_attitude_issue'] ?? '無資料',
          'environmentHygiene': nlpInsights['environment_hygiene_issue'] ?? '無資料',
          'lowStarAnalysis': stratified['low_star_analysis'] ?? '無資料',
          'midStarAnalysis': stratified['mid_star_analysis'] ?? '無資料',
          'highStarAnalysis': stratified['high_star_analysis'] ?? '無資料',
          'maliciousBombDetected': stratified['malicious_bomb_detected'] ?? false,
          'maliciousBombRatio': stratified['malicious_bomb_ratio'] ?? 0,
        };

        addRecord(newRecord);
        return newRecord;
      } else {
        // 👈 解析後端真實的錯誤詳細資訊 (如 429 額度超載等)
        final err = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        throw Exception(err['detail'] ?? '後端分析服務失敗！');
      }
    } catch (e) {
      print('HTTP Request Error: $e');
      rethrow;
    }
  }

  // 7. 更新個人檔案方法 (帶入 x-user-id)
  static Future<void> updateProfile(String name, String email, {String? avatar}) async {
    userProfile['name'] = name;
    userProfile['email'] = email;
    if (avatar != null) {
      userProfile['avatar'] = avatar;
    }
    _notifyListeners();
    
    final apiUrl = Uri.parse('http://127.0.0.1:8000/user/profile');
    try {
      await http.put(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          if (currentUserId != null) 'x-user-id': currentUserId!,
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          if (avatar != null) 'avatar': avatar,
        }),
      );
    } catch (e) {
      print('Sync Profile Error: $e');
    }
  }

  // 8. 連接切換同步 (帶入 x-user-id)
  static Future<void> toggleAccountConnection(String provider) async {
    if (provider == 'apple') {
      userProfile['isAppleConnected'] = !(userProfile['isAppleConnected'] ?? false);
    } else if (provider == 'line') {
      userProfile['isLineConnected'] = !(userProfile['isLineConnected'] ?? false);
    }
    _notifyListeners();

    final apiUrl = Uri.parse('http://127.0.0.1:8000/user/connect');
    try {
      await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          if (currentUserId != null) 'x-user-id': currentUserId!,
        },
        body: jsonEncode({'provider': provider}),
      );
    } catch (e) {
      print('Sync Connect Error: $e');
    }
  }

  // 9. 收藏狀態切換同步 (帶入 x-user-id)
  static Future<void> toggleBookmark(String title) async {
    for (var r in records) {
      if (r['title'] == title) {
        r['isBookmarked'] = !(r['isBookmarked'] ?? false);
        _notifyListeners();
        
        final apiUrl = Uri.parse('http://127.0.0.1:8000/bookmarks/toggle');
        try {
          await http.post(
            apiUrl,
            headers: {
              'Content-Type': 'application/json',
              if (currentUserId != null) 'x-user-id': currentUserId!,
            },
            body: jsonEncode({'title': title}),
          );
        } catch (e) {
          print('Sync Bookmark Error: $e');
        }
        return;
      }
    }
  }

  // 10. 分析偏好設定同步 (帶入 x-user-id)
  static Future<void> updatePreferences(int sampleSize, String focusArea) async {
    preferences['sampleSize'] = sampleSize;
    preferences['focusArea'] = focusArea;
    _notifyListeners();
    
    final apiUrl = Uri.parse('http://127.0.0.1:8000/user/preferences');
    try {
      await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          if (currentUserId != null) 'x-user-id': currentUserId!,
        },
        body: jsonEncode({'sample_size': sampleSize, 'focus_area': focusArea}),
      );
    } catch (e) {
      print('Sync Preferences Error: $e');
    }
  }
}
