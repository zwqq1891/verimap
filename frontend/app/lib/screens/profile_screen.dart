import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/analysis_record_manager.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Register listener so that profile stats and details sync in real-time
    AnalysisRecordManager.addListener(_onRecordsChanged);
  }

  @override
  void dispose() {
    AnalysisRecordManager.removeListener(_onRecordsChanged);
    super.dispose();
  }

  void _onRecordsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // 1. Edit Profile Dialog
  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: AnalysisRecordManager.userProfile['name']);
    final emailController = TextEditingController(text: AnalysisRecordManager.userProfile['email']);
    final avatarController = TextEditingController(text: AnalysisRecordManager.userProfile['avatar']);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('編輯個人資料', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '姓名',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: '電子郵件',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: avatarController,
                  onChanged: (val) {
                    setDialogState(() {});
                  },
                  decoration: const InputDecoration(
                    labelText: '自定義頭像圖片連結 (可貼上任何網址)',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 16),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '快捷選擇推薦頭像：',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.secondaryColor),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPresetAvatarIcon(
                      url: 'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none"><circle cx="50" cy="50" r="50" fill="url(%23grad)"/><defs><linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="%231a73e8"/><stop offset="100%" stop-color="%238000ff"/></linearGradient></defs><circle cx="50" cy="40" r="18" fill="white" opacity="0.95"/><path d="M20 78 C20 62, 35 58, 50 58 C65 58, 80 62, 80 78" fill="white" opacity="0.95"/></svg>',
                      currentUrl: avatarController.text,
                      onTap: (newUrl) {
                        avatarController.text = newUrl;
                        setDialogState(() {});
                      },
                    ),
                    _buildPresetAvatarIcon(
                      url: 'https://cdn-icons-png.flaticon.com/512/387/387561.png',
                      currentUrl: avatarController.text,
                      onTap: (newUrl) {
                        avatarController.text = newUrl;
                        setDialogState(() {});
                      },
                    ),
                    _buildPresetAvatarIcon(
                      url: 'https://cdn-icons-png.flaticon.com/512/2716/2716612.png',
                      currentUrl: avatarController.text,
                      onTap: (newUrl) {
                        avatarController.text = newUrl;
                        setDialogState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                final newEmail = emailController.text.trim();
                final newAvatar = avatarController.text.trim();
                if (newName.isNotEmpty && newEmail.isNotEmpty) {
                  AnalysisRecordManager.updateProfile(
                    newName, 
                    newEmail, 
                    avatar: newAvatar.isNotEmpty ? newAvatar : null,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('個人資料與自定義頭像已更新！'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('儲存'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetAvatarIcon({
    required String url,
    required String currentUrl,
    required Function(String) onTap,
  }) {
    final isSelected = url == currentUrl;
    return GestureDetector(
      onTap: () => onTap(url),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppTheme.surfaceContainerLow,
                child: const Icon(Icons.person, size: 20),
              );
            },
          ),
        ),
      ),
    );
  }

  // 2. Preferences Dialog
  void _showPreferencesDialog(BuildContext context) {
    int currentSize = AnalysisRecordManager.preferences['sampleSize'] ?? 80;
    String currentFocus = AnalysisRecordManager.preferences['focusArea'] ?? '全部';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('分析偏好設定', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('預設聯網抓取評論數量：', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [50, 80, 100].map((size) {
                  final isSelected = currentSize == size;
                  return ChoiceChip(
                    label: Text('$size 則'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setDialogState(() {
                          currentSize = size;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('AI 痛點剖析偏好焦點：', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: currentFocus,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ['全部', '服務態度', '衛生清潔', '產品為主'].map((focus) {
                  return DropdownMenuItem<String>(
                    value: focus,
                    child: Text(focus),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() {
                      currentFocus = val;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                AnalysisRecordManager.updatePreferences(currentSize, currentFocus);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('偏好設定已更新！抓取筆數：$currentSize 則，焦點：$currentFocus'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('儲存'),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Subscription Dialog
  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.workspace_premium, color: Colors.amber),
            SizedBox(width: 8),
            Text('訂閱方案詳情', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Text('目前方案：', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PRO 專業版',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('解鎖權益：', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildBenefitRow('無限次 Gemini 聯網打假分析'),
            _buildBenefitRow('防惡意抹黑進階過濾算分'),
            _buildBenefitRow('下載/匯出 PDF 信譽報告'),
            _buildBenefitRow('多平台帳號歷史備份與同步'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: const [
                Text('訂閱期至：', style: TextStyle(color: AppTheme.secondaryColor)),
                Spacer(),
                Text('2027-05-31 (自動續約)', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  // 4. Help & Support Dialog
  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('幫助與支援', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('常見問題：', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Q: 為什麼 VeriScore 聯網分析需要 10-15 秒？', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('A: 因為 Gemini 會實時發送多個不同的搜尋組合去 Google 網路上抓取高低分評論的背景並進行打假，這比一般 mock 靜態算分耗時，但能保證真實。', style: TextStyle(fontSize: 12, color: AppTheme.secondaryColor)),
            SizedBox(height: 12),
            Text('Q: 惡意差評抹黑檢測的準確度如何？', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('A: 系統依據評論字數、個體化描述以及是否有重複罐頭文特徵，來排除情緒性及惡意同行的惡意投訴。', style: TextStyle(fontSize: 12, color: AppTheme.secondaryColor)),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            Text('客服電子郵件：support@verimap.ai', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = AnalysisRecordManager.userProfile;
    final totalAnalyzed = AnalysisRecordManager.records.length;
    final totalBookmarked = AnalysisRecordManager.records.where((r) => r['isBookmarked'] == true).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600), // Bound width on wide screens for premium editorial look
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Profile Information Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
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
                    // Avatar Image with shadow and border
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.surfaceContainerLow, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            offset: Offset(0, 4),
                            blurRadius: 16,
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          profile['avatar'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.surfaceContainerHighest,
                              child: const Icon(
                                Icons.person,
                                size: 48,
                                color: AppTheme.secondaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile['name'],
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile['email'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditProfileDialog(context),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('編輯個人資料'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.outlineVariant),
                          foregroundColor: AppTheme.onSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Stats Section (Bento Box Style Grid - Dynamic!)
              Row(
                children: [
                  Expanded(
                    child: _buildBentoStatCard(
                      theme: theme,
                      title: '已分析商家數',
                      value: '$totalAnalyzed',
                      unit: '間',
                      icon: Icons.analytics,
                      iconColor: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBentoStatCard(
                      theme: theme,
                      title: '我的收藏',
                      value: '$totalBookmarked',
                      unit: '項',
                      icon: Icons.bookmark,
                      iconColor: const Color(0xFFFFA726),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Connected Accounts Card (NEW!)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.link, color: AppTheme.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          '已連接帳號設定',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '連結第三方帳號以雲端備份分析紀錄與自訂收藏。',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Google
                    _buildConnectionItem(
                      provider: 'Google',
                      accountName: profile['email'],
                      icon: Icons.account_circle,
                      iconColor: Colors.red,
                      isConnected: profile['isGoogleConnected'] ?? true,
                      isDefault: true,
                      onToggle: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Google 帳號為您的主要註冊帳號，無法解除連接！'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. Menu Options List
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
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
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      title: '帳號設定 (編輯個人資料)',
                      icon: Icons.manage_accounts_outlined,
                      onTap: () => _showEditProfileDialog(context),
                    ),
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      title: '分析偏好設定',
                      icon: Icons.tune_outlined,
                      onTap: () => _showPreferencesDialog(context),
                    ),
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      title: '訂閱方案詳情',
                      icon: Icons.workspace_premium_outlined,
                      onTap: () => _showSubscriptionDialog(context),
                    ),
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      title: '幫助與支援 (常見問題)',
                      icon: Icons.help_outline,
                      onTap: () => _showSupportDialog(context),
                    ),
                    _buildMenuItem(
                      context: context,
                      theme: theme,
                      title: '登出帳號並重置快取',
                      icon: Icons.logout,
                      textColor: AppTheme.errorColor,
                      iconColor: AppTheme.errorColor,
                      isLast: true,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('確認登出與重置'),
                            content: const Text('這將會登出您的帳號並重置本地快取，您確定要登出嗎？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // 呼叫登出，清除用戶狀態
                                  AnalysisRecordManager.logout();
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('已成功登出並重置狀態！'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  
                                  // 跳轉回登入畫面
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                                    (route) => false,
                                  );
                                },
                                child: const Text('確定登出', style: TextStyle(color: AppTheme.errorColor)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBentoStatCard({
    required ThemeData theme,
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            offset: Offset(0, 1),
            blurRadius: 4,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionItem({
    required String provider,
    required String accountName,
    required IconData icon,
    required Color iconColor,
    required bool isConnected,
    bool isDefault = false,
    required VoidCallback onToggle,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                accountName,
                style: const TextStyle(fontSize: 12, color: AppTheme.secondaryColor),
              ),
            ],
          ),
        ),
        if (isDefault)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: const Text(
              '預設主帳號',
              style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          )
        else
          Switch(
            value: isConnected,
            activeColor: AppTheme.primaryContainerColor,
            onChanged: (val) => onToggle(),
          ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required IconData icon,
    Color? textColor,
    Color? iconColor,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(20))
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(
                    color: AppTheme.outlineVariant,
                    width: 1,
                  ),
                ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? AppTheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: textColor ?? AppTheme.onSurface,
                ),
              ),
            ),
            if (textColor == null)
              const Icon(
                Icons.chevron_right,
                color: AppTheme.secondaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
