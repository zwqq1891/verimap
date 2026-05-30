import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/recent_analysis_card.dart';
import '../widgets/credibility_gauge.dart';
import '../widgets/analysis_record_manager.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const HomeScreen({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isAnalyzing = false;
  
  // Real-time analysis results
  double? _resultScore;
  String? _resultMerchant;
  Map<String, dynamic>? _analysisRecord;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _startAnalysis([String? presetUrl]) async {
    final url = presetUrl ?? _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('請輸入 Google 地圖商家網址！'),
          backgroundColor: AppTheme.tertiaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (url.toLowerCase() == 'test') {
      setState(() {
        _isAnalyzing = true;
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: AppTheme.surfaceColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'VeriScore 正在模擬分析中...',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '偵測到測試輸入，正在為您生成隨機測試分析結果畫面...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.secondaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1200));
      Navigator.of(context).pop();

      final random = Random();
      final List<Map<String, dynamic>> testTemplates = [
        {
          'title': '好心情咖啡廳 (測試)',
          'url': 'test',
          'subtitle': '剛剛測試分析 • 共 120 則評論',
          'score': 82,
          'starRating': 4.3,
          'originalStarRating': 4.5,
          'icon': Icons.restaurant,
          'label': '信譽良好',
          'zeroTextSpam': '未發現顯著水軍刷評痕跡，評論文本正常。',
          'duplicatePatterns': '評論用字多元化，無重複模板跡象。',
          'incentivizedTriggers': '發現有 1 則評論提到拍照打卡送餅乾。',
          'serviceAttitude': '服務人員態度親切，顧客普遍稱讚櫃檯笑容。',
          'environmentHygiene': '店內裝潢別緻、桌椅整潔，整體環境維護優良。',
          'lowStarAnalysis': '極少數低星評論多抱怨週末排隊時間長或低消限制。',
          'midStarAnalysis': '中星評論認為飲品水準佳，但部分甜點品項售價稍高。',
          'highStarAnalysis': '真實高星評論描述具體，且高度推崇手沖咖啡及放鬆氣氛。',
          'maliciousBombDetected': false,
          'maliciousBombRatio': 0,
        },
        {
          'title': '第一川菜館 (測試)',
          'url': 'test',
          'subtitle': '剛剛測試分析 • 共 75 則評論',
          'score': 54,
          'starRating': 3.6,
          'originalStarRating': 4.4,
          'icon': Icons.restaurant,
          'label': '信譽中等',
          'zeroTextSpam': '存在約 15% 的空洞高星評分，疑似有少量宣傳。',
          'duplicatePatterns': '發現 3 組字眼極其相似的評論，如「味道很好，環境不錯」。',
          'incentivizedTriggers': '評論中有多次提及「五星好評送可樂」活動。',
          'serviceAttitude': '上菜速度偶有延遲，忙碌時店員態度顯得有些焦躁。',
          'environmentHygiene': '桌面偶爾有些許油膩，餐具清洗尚算乾淨。',
          'lowStarAnalysis': '低星反映假日尖峰用餐出餐混亂、部分餐點過於油膩辛辣。',
          'midStarAnalysis': '中星評論指出口味符合預期，但價格偏貴，性價比一般。',
          'highStarAnalysis': '好評多集中於招牌菜的口味，但部分疑似為贈品活動評論。',
          'maliciousBombDetected': false,
          'maliciousBombRatio': 2,
        },
        {
          'title': '幸福牙醫診所 (測試)',
          'url': 'test',
          'subtitle': '剛剛測試分析 • 共 150 則評論',
          'score': 28,
          'starRating': 2.1,
          'originalStarRating': 4.8,
          'icon': Icons.local_hospital,
          'label': '信譽較差',
          'zeroTextSpam': '發現高達 65% 的無文字五星評價，洗板灌水嫌疑極高。',
          'duplicatePatterns': '出現大量模板評論「醫生細心、技術好，讚！」，格式高度一致。',
          'incentivizedTriggers': '明確查獲「寫評論送小禮物與潔牙套組」的集體行銷痕跡。',
          'serviceAttitude': '真實差評集中抱怨櫃檯人員口氣強硬、態度差，預約時間常被拖延。',
          'environmentHygiene': '候診室沙發有磨損痕跡，但診療室內部衛生符合標準。',
          'lowStarAnalysis': '多位真實患者控訴預約等候超過一小時、櫃檯服務差及醫生溝通粗魯。',
          'midStarAnalysis': '幾乎沒有中星中立評價，分數呈極端的五星與一星兩極化，灌水操縱感極強。',
          'highStarAnalysis': '好評極度缺乏文字細節描述，且有大量在同一時間段集中發布的灌水特徵。',
          'maliciousBombDetected': true,
          'maliciousBombRatio': 15,
        }
      ];

      final selected = testTemplates[random.nextInt(testTemplates.length)];

      setState(() {
        _isAnalyzing = false;
        _analysisRecord = selected;
        _resultScore = (selected['score'] as int).toDouble();
        _resultMerchant = selected['title'] as String;
      });
      return;
    }

    if (presetUrl == null) {
      // FocusScope.of(context).unfocus();
    }

    setState(() {
      _isAnalyzing = true;
    });

    // Show a premium loading dialog mimicking AI analysis
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppTheme.surfaceColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
                const SizedBox(height: 24),
                Text(
                  'VeriScore 正在深度分析中...',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '正在啟動聯網搜尋、分層抽樣過濾、比對差評抹黑雜訊，請稍候 (約需 10-15 秒)...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 呼叫真實後端 API 串接介面！
      final result = await AnalysisRecordManager.analyzeUrl(url);
      
      Navigator.of(context).pop(); // 關閉載入對話框

      if (result != null) {
        setState(() {
          _isAnalyzing = false;
          _analysisRecord = result;
          _resultScore = (result['score'] as int).toDouble();
          _resultMerchant = result['title'] as String;
        });
      }
    } catch (e) {
      Navigator.of(context).pop(); // 關閉載入對話框
      setState(() {
        _isAnalyzing = false;
      });
      
      // 顯示錯誤訊息 SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ 分析失敗：請確認後端服務已啟動且 GEMINI_API_KEY 有效！\n錯誤: $e'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  void _resetAnalysis() {
    setState(() {
      _resultScore = null;
      _resultMerchant = null;
      _analysisRecord = null;
      _urlController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Return Analysis Result View if analyzed
    if (_resultScore != null && _resultMerchant != null) {
      return _buildResultView();
    }

    // 2. Return Default Homepage View
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          // Heading Group
          Text(
            '揭開真相',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI 驅動的評論可信度與真實滿意度分析工具',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // URL Input Card
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.outlineVariant, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                )
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    hintText: '在此貼上 Google 地圖商家網址或店名...',
                    prefixIcon: Icon(Icons.link, color: AppTheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isAnalyzing ? null : () => _startAnalysis(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.rocket_launch, size: 18),
                        SizedBox(width: 8),
                        Text('啟動 VeriScore 聯網分析'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Presets to test directly
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                '快捷真實測試範例',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          RecentAnalysisCard(
            title: '中壢長榮醫院',
            subtitle: '提供真實 Maps 網址 • 實時搜尋過濾 80 則評論',
            score: 88,
            icon: Icons.local_hospital,
            onTap: () {
              _startAnalysis("https://www.google.com/maps/place/中壢長榮醫院/@24.9644575,121.2475365,15z/data=!4m8!3m7!1s0x346822418308968f:0xe17a8a95fb74ae1e!8m2!3d24.9644573!4d121.257836!9m1!1b1!16s%2Fg%2F1pztd4kyk?entry=ttu&g_ep=EgoyMDI2MDUyNy4wIKXMDSoASAFQAw%3D%3D");
            },
          ),
          const SizedBox(height: 12),
          RecentAnalysisCard(
            title: '42號小館',
            subtitle: '高風險示範 • 偵測到大量行銷與刷好評水軍',
            score: 32,
            icon: Icons.restaurant,
            trailingLabel: '信譽較差',
            onTap: () {
              // Load historical mock data for 42號小館 directly
              final record = AnalysisRecordManager.records.firstWhere(
                (element) => element['title'] == '42號小館',
                orElse: () => AnalysisRecordManager.records[2],
              );
              setState(() {
                _analysisRecord = record;
                _resultScore = (record['score'] as int).toDouble();
                _resultMerchant = record['title'] as String;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final theme = Theme.of(context);
    final score = _resultScore!;
    final starRating = _analysisRecord?['starRating'] ?? 3.5;
    final originalRating = _analysisRecord?['originalStarRating'] ?? 4.5;
    final isLow = score < 40;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface),
                onPressed: _resetAnalysis,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _resultMerchant!,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Dynamic Bookmark Button!
              StatefulBuilder(
                builder: (context, setBookmarkState) {
                  final isBookmarked = AnalysisRecordManager.records.any(
                    (r) => r['title'] == _resultMerchant && (r['isBookmarked'] ?? false),
                  );
                  return IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? const Color(0xFFFFA726) : AppTheme.onSurface,
                    ),
                    onPressed: () {
                      AnalysisRecordManager.toggleBookmark(_resultMerchant!);
                      setBookmarkState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isBookmarked ? '已取消收藏此商家！' : '已成功收藏此商家！'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ratings comparison row
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              // Original Google Rating
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_border, color: AppTheme.secondaryColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '原 Google 評論：',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    Text(
                      '${originalRating.toStringAsFixed(1)} / 5.0',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                    ),
                  ],
                ),
              ),
              
              // AI Summarized Real Rating
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'AI 實際星等：',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                    ...List.generate(5, (index) {
                      if (index < starRating.floor()) {
                        return const Icon(Icons.star, color: Colors.amber, size: 16);
                      } else if (index < starRating && starRating - index >= 0.5) {
                        return const Icon(Icons.star_half, color: Colors.amber, size: 16);
                      } else {
                        return const Icon(Icons.star_border, color: Colors.amber, size: 16);
                      }
                    }),
                    const SizedBox(width: 6),
                    Text(
                      '${starRating.toStringAsFixed(1)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Custom Credibility Gauge
          CredibilityGauge(score: score),
          const SizedBox(height: 24),

          // Insight Indicator Block (AI Credibility Basis Breakdown)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLow
                  ? AppTheme.errorContainerColor.withOpacity(0.3)
                  : AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLow ? AppTheme.errorContainerColor : AppTheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isLow ? Icons.error : Icons.verified,
                      color: isLow ? AppTheme.errorColor : AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isLow
                            ? '評估結果：此商家評論信譽偏低 ($score%)'
                            : '評估結果：此商家評論信譽良好 ($score%)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isLow ? AppTheme.errorColor : AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppTheme.outlineVariant, height: 1),
                const SizedBox(height: 12),
                Text(
                  '🔍 AI 評估可信度與商譽之核心依據：',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildBasisBullet('• 灌水指數：', _analysisRecord?['zeroTextSpam'] ?? '無資料'),
                _buildBasisBullet('• 重複文特徵：', _analysisRecord?['duplicatePatterns'] ?? '無資料'),
                _buildBasisBullet('• 利益引誘：', _analysisRecord?['incentivizedTriggers'] ?? '無資料'),
                if ((_analysisRecord?['maliciousBombRatio'] ?? 0) > 0)
                  _buildBasisBullet('• 同行抹黑檢測：', '偵測到約 ${_analysisRecord?['maliciousBombRatio']}% 的疑似惡意差評或情緒性排隊投訴'),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Core Feature: Stratified Analysis & Competitor Filtration
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '🎯 AI 分層抽樣打假與防抹黑分析',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.security, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '同行差評惡意攻擊檢測',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (_analysisRecord?['maliciousBombDetected'] ?? false)
                            ? AppTheme.errorContainerColor
                            : AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (_analysisRecord?['maliciousBombDetected'] ?? false) ? '偵測到惡意抹黑' : '安全 (未見同行抹黑)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: (_analysisRecord?['maliciousBombDetected'] ?? false) ? AppTheme.errorColor : AppTheme.primaryColor,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('低分評論噪音佔比：'),
                    const Spacer(),
                    Text(
                      '${_analysisRecord?['maliciousBombRatio'] ?? 0}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (_analysisRecord?['maliciousBombDetected'] ?? false) ? AppTheme.errorColor : AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ((_analysisRecord?['maliciousBombRatio'] ?? 0) as int) / 100.0,
                    minHeight: 8,
                    backgroundColor: AppTheme.surfaceContainerLow,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      (_analysisRecord?['maliciousBombDetected'] ?? false) ? AppTheme.errorColor : AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildStratifiedItem(
                  '40% 低星投訴分析 (已過濾惡意噪音，還原真實痛點)',
                  _analysisRecord?['lowStarAnalysis'] ?? '無資料',
                  Icons.trending_down_outlined,
                  AppTheme.errorColor,
                ),
                const Divider(height: 24),
                _buildStratifiedItem(
                  '30% 中星客觀體驗 (中立顧客體驗)',
                  _analysisRecord?['midStarAnalysis'] ?? '無資料',
                  Icons.thumbs_up_down_outlined,
                  Colors.orange,
                ),
                const Divider(height: 24),
                _buildStratifiedItem(
                  '30% 高星好評分析 (排除行銷利益後的真實推薦)',
                  _analysisRecord?['highStarAnalysis'] ?? '無資料',
                  Icons.trending_up_outlined,
                  Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // NLP Painpoint Extraction
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '💬 真實顧客語意痛點摘要',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            '核心服務態度問題',
            _analysisRecord?['serviceAttitude'] ?? '無資料',
            Icons.face_retouching_off_outlined,
            isLow,
          ),
          _buildMetricCard(
            '環境衛生與清潔度',
            _analysisRecord?['environmentHygiene'] ?? '無資料',
            Icons.cleaning_services_outlined,
            isLow,
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _resetAnalysis,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('返回搜尋並分析其他商家'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStratifiedItem(String title, String content, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                content,
                style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.secondaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, bool isAlert) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppTheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppTheme.outlineVariant,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.surfaceColor,
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasisBullet(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.onSurfaceVariant)),
          Expanded(
            child: Text(content, style: const TextStyle(fontSize: 13, color: AppTheme.secondaryColor)),
          ),
        ],
      ),
    );
  }
}
