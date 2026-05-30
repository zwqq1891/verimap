import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/recent_analysis_card.dart';
import '../widgets/analysis_record_manager.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 註冊監聽器，當 Home 頁面分析完新商家時，History 頁面會自動重繪
    AnalysisRecordManager.addListener(_onRecordsChanged);
  }

  @override
  void dispose() {
    AnalysisRecordManager.removeListener(_onRecordsChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onRecordsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allRecords = AnalysisRecordManager.records;

    // Filter lists based on query
    final filteredRecords = allRecords.where((record) {
      final title = record['title'].toString().toLowerCase();
      final subtitle = record['subtitle'].toString().toLowerCase();
      return title.contains(_searchQuery) || subtitle.contains(_searchQuery);
    }).toList();

    // 分流為「今天」與「本週稍早」
    final filteredToday = filteredRecords.where((record) {
      final subtitle = record['subtitle'].toString();
      return subtitle.contains('剛剛') || subtitle.contains('小時') || subtitle.contains('今日');
    }).toList();

    final filteredEarlier = filteredRecords.where((record) {
      final subtitle = record['subtitle'].toString();
      return !subtitle.contains('剛剛') && !subtitle.contains('小時') && !subtitle.contains('今日');
    }).toList();

    final hasResults = filteredRecords.isNotEmpty;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '分析紀錄',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Search Input Field
            TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: '搜尋商家名稱或地點...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceVariant),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // Scrollable List
            Expanded(
              child: hasResults
                  ? ListView(
                      children: [
                        // Today's Group
                        if (filteredToday.isNotEmpty) ...[
                          _buildSectionHeader(theme, '今天'),
                          const SizedBox(height: 12),
                          ...filteredToday.map((record) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: RecentAnalysisCard(
                                  title: record['title'],
                                  subtitle: record['subtitle'],
                                  score: record['score'],
                                  icon: record['icon'],
                                  trailingLabel: record['label'],
                                  onTap: () => _showDetailSheet(context, record),
                                ),
                              )),
                          const SizedBox(height: 16),
                        ],

                        // Earlier Group
                        if (filteredEarlier.isNotEmpty) ...[
                          _buildSectionHeader(theme, '本週稍早'),
                          const SizedBox(height: 12),
                          ...filteredEarlier.map((record) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Opacity(
                                  opacity: 0.85,
                                  child: RecentAnalysisCard(
                                    title: record['title'],
                                    subtitle: record['subtitle'],
                                    score: record['score'],
                                    icon: record['icon'],
                                    trailingLabel: record['label'],
                                    onTap: () => _showDetailSheet(context, record),
                                  ),
                                ),
                              )),
                        ],
                        const SizedBox(height: 32),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_outlined,
                            size: 64,
                            color: AppTheme.secondaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '找不到符合的分析紀錄',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '請嘗試使用其他關鍵字搜尋',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.secondaryColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        const Divider(color: AppTheme.outlineVariant, height: 1),
      ],
    );
  }

  // Interactive Bottom Sheet showing complete details
  void _showDetailSheet(BuildContext context, Map<String, dynamic> record) {
    final theme = Theme.of(context);
    final score = record['score'] as int;
    final starRating = record['starRating'] ?? 3.5;
    final originalRating = record['originalStarRating'] ?? 4.5;
    final isLow = score < 40;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 支援滾動，避免內容過多溢出
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isLow ? AppTheme.errorContainerColor : AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      record['icon'] as IconData,
                      color: isLow ? AppTheme.errorColor : AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record['title'],
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          record['subtitle'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Star Rating Row (Ratings Comparison Capsules)
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  // Original Google Rating
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_border, color: AppTheme.secondaryColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '原 Google 評論：',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        Text(
                          '${originalRating.toStringAsFixed(1)} / 5.0',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  
                  // AI Summarized Real Rating
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'AI 實際星等：',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                        ...List.generate(5, (index) {
                          if (index < starRating.floor()) {
                            return const Icon(Icons.star, color: Colors.amber, size: 14);
                          } else if (index < starRating && starRating - index >= 0.5) {
                            return const Icon(Icons.star_half, color: Colors.amber, size: 14);
                          } else {
                            return const Icon(Icons.star_border, color: Colors.amber, size: 14);
                          }
                        }),
                        const SizedBox(width: 4),
                        Text(
                          '${starRating.toStringAsFixed(1)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // VeriScore Gauge Box (AI Credibility Basis Breakdown)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLow ? AppTheme.errorContainerColor.withOpacity(0.3) : AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLow ? AppTheme.errorContainerColor : AppTheme.outlineVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isLow ? Icons.warning_amber_rounded : Icons.verified,
                          color: isLow ? AppTheme.errorColor : AppTheme.primaryColor,
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
                    _buildBasisBullet('• 灌水指數：', record['zeroTextSpam'] ?? '無資料'),
                    _buildBasisBullet('• 重複文特徵：', record['duplicatePatterns'] ?? '無資料'),
                    _buildBasisBullet('• 利益引誘：', record['incentivizedTriggers'] ?? '無資料'),
                    if ((record['maliciousBombRatio'] ?? 0) > 0)
                      _buildBasisBullet('• 同行抹黑檢測：', '偵測到約 ${record['maliciousBombRatio']}% 的疑似惡意差評或情緒性排隊投訴'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Stratified Analysis (40/30/30) Section
              Text(
                '🎯 AI 分層抽樣打假與防抹黑分析',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
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
                        const Expanded(
                          child: Text(
                            '差評惡意洗板攻擊檢測：',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${record['maliciousBombRatio'] ?? 0}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (record['maliciousBombDetected'] ?? false) ? AppTheme.errorColor : AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStratifiedRow('40% 低星投訴分析 (過濾後真實痛點)', record['lowStarAnalysis'] ?? '無資料', Icons.trending_down_outlined, AppTheme.errorColor),
                    const Divider(height: 20),
                    _buildStratifiedRow('30% 中星客觀體驗 (中立顧客體驗)', record['midStarAnalysis'] ?? '無資料', Icons.thumbs_up_down_outlined, Colors.orange),
                    const Divider(height: 20),
                    _buildStratifiedRow('30% 高星好評分析 (排除行銷利益後的真實好評)', record['highStarAnalysis'] ?? '無資料', Icons.trending_up_outlined, Colors.green),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // NLP Painpoint Extraction
              Text(
                '💬 真實顧客語意痛點摘要',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              _buildDetailCard(theme, '核心服務態度問題', record['serviceAttitude'] ?? '無資料', Icons.face_retouching_off_outlined),
              _buildDetailCard(theme, '環境衛生與清潔度', record['environmentHygiene'] ?? '無資料', Icons.cleaning_services_outlined),

              const SizedBox(height: 24),
              // 重新分析按鈕 (隨時間獲得最新真實評論)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('重新分析 (更新實時評論)', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                    foregroundColor: AppTheme.primaryColor,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppTheme.primaryColor, width: 1.2),
                    ),
                  ),
                  onPressed: () {
                    // 關閉目前詳情彈出視窗
                    Navigator.pop(context);
                    
                    // 顯示重新分析的毛玻璃載入視窗
                    _showReanalyzeLoadingOverlay(context, record);
                  },
                ),
              ),

              const SizedBox(height: 28),
              StatefulBuilder(
                builder: (context, setSheetState) {
                  final isBookmarked = AnalysisRecordManager.records.any(
                    (r) => r['title'] == record['title'] && (r['isBookmarked'] ?? false),
                  );
                  return Row(
                    children: [
                      // Elegant bookmark icon button
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isBookmarked ? const Color(0xFFFFA726).withOpacity(0.5) : AppTheme.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? const Color(0xFFFFA726) : AppTheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            AnalysisRecordManager.toggleBookmark(record['title']);
                            setSheetState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isBookmarked ? '已取消收藏此商家！' : '已成功收藏此商家！'),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.outlineVariant),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('關閉'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            String mainstreamComment = record['highStarAnalysis'] ?? '無資料';
                            if (score < 45) {
                              mainstreamComment = record['lowStarAnalysis'] ?? '無資料';
                            } else if (score < 68) {
                              mainstreamComment = record['midStarAnalysis'] ?? '無資料';
                            }
                            final String shareText = '嗨朋友 我分享了一則 ${record['title']} 的 google 評論分析：\n'
                                '🔹 原評論星等：${originalRating.toStringAsFixed(1)} \n'
                                '✨ ai分析實際星等：${starRating.toStringAsFixed(1)} \n'
                                '🛡️ 評論可信度：$score分 \n'
                                '💬 主流評論：$mainstreamComment';
                            Clipboard.setData(ClipboardData(text: shareText)).then((_) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('已複製商家可信度分析分享文字！快去貼給朋友吧～'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('分享報告'),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 實時重新分析與毛玻璃加載
  void _showReanalyzeLoadingOverlay(BuildContext context, Map<String, dynamic> record) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '正在重新分析「${record['title']}」...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '正在連線 Google Maps 抓取最新實時評論\n排除水軍與惡意抹黑中，此過程約需 10-15 秒...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // 調用實時分析 API (使用原本儲存的 url，若無則用 title)
    final String originalUrl = record['url'] ?? record['title'];
    AnalysisRecordManager.analyzeUrl(originalUrl).then((newRecord) {
      // 關閉加載視窗
      Navigator.pop(context);

      if (newRecord != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ 「${record['title']}」最新評論打假分析已更新！'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );

        // 稍微延遲後重新彈出更新後的詳細分析報告
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _showDetailSheet(context, newRecord);
          }
        });
      }
    }).catchError((err) {
      // 關閉加載視窗
      Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 重新分析失敗：${err.toString().replaceAll('Exception: ', '')}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    });
  }

  Widget _buildStratifiedRow(String title, String content, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Text(content, style: const TextStyle(fontSize: 12, height: 1.4, color: AppTheme.secondaryColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(ThemeData theme, String title, String content, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: AppTheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.surfaceColor,
          child: Icon(icon, color: AppTheme.primaryColor, size: 18),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(content, style: const TextStyle(fontSize: 12, color: AppTheme.secondaryColor)),
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
