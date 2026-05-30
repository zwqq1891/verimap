import os
import json
import sqlite3
import hashlib
from typing import Optional, List
from fastapi import FastAPI, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from dotenv import load_dotenv

# 1. 載入 .env 檔案
load_dotenv(override=True)

# 初始化 FastAPI
app = FastAPI(
    title="VeriMap / Review Defender Persistent Backend",
    description="Real-time review credibility analysis using Gemini API with persistent SQLite database.",
    version="2.1.0"
)

# 2. 配置 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "verimap.db")

# 3. 定義 Pydantic 結構化輸出 Response Schema
class MetricsDetail(BaseModel):
    zero_text_spam: str = Field(description="無字五星灌水分析，判斷有多少比例的評論屬於無文字純給分的行為")
    duplicate_patterns: str = Field(description="重複罐頭文特徵分析，偵測千篇一律、缺乏實質消費細節的空洞讚美")
    incentivized_triggers: str = Field(description="行銷利益誘因分析，偵測是否提及打卡送小菜、送禮物、好評送折扣等特徵")

class NLPInsightsDetail(BaseModel):
    service_attitude_issue: str = Field(description="服務態度問題分析，提取真實顧客對服務品質、櫃檯人員冷漠或不佳的反饋，若無則填寫'未發現顯著服務態度問題'")
    environment_hygiene_issue: str = Field(description="環境衛生問題分析，提取真實顧客對環境整潔度、餐具衛生或髒亂的反饋，若無則填寫'未發現顯著環境衛生問題'")

class StratifiedAnalysis(BaseModel):
    low_star_analysis: str = Field(description="40% 低星評論 (1-2星) 分析：辨識是否有同行惡意抹黑、水軍差評或情緒化無理發洩；並過濾雜訊，提取相對正常、客觀且有真實參考價值的實質抱怨。")
    mid_star_analysis: str = Field(description="30% 中星評論 (3星) 分析：摘要客觀、中立、好壞並陳的真實顧客回饋。")
    high_star_analysis: str = Field(description="30% 高星評論 (4-5星) 分析：評估正面評價中，有多少屬於自然的真實讚美，多少屬於活動打卡或行銷洗出來的虛假好評。")
    malicious_bomb_detected: bool = Field(description="是否偵測到顯著的惡意針對或同行抹黑洗差評現象")
    malicious_bomb_ratio: int = Field(description="估計低星差評中屬於『惡意/無理發洩/抹黑』的百分比 (0-100%)")

class AnalysisResponse(BaseModel):
    merchant_name: str = Field(description="搜尋並辨識出的真實商家/機構名稱")
    veri_score: int = Field(description="最終可信度 VeriScore (0-100)，分數越低代表洗好評、灌水與偏誤風險越高")
    real_star_rating: float = Field(description="核心亮點：過濾掉水軍好評與惡意負評雜訊後，AI 評估出的該商家『綜合實際星等』(1.0 - 5.0 顆星)")
    original_star_rating: float = Field(description="Google 地圖上該商家展示的『原始公開星等評分』(1.0 - 5.0 顆星，例如 4.7)")
    total_analyzed: int = Field(description="深度分析的真實評論估計筆數（例如：50 - 100 則）")
    metrics: MetricsDetail = Field(description="三大特定灌水指標分析")
    nlp_insights: NLPInsightsDetail = Field(description="兩大顧客語意痛點偵測")
    stratified_analysis: StratifiedAnalysis = Field(description="核心亮點：40%/30%/30% 分層抽樣打假與真實抱怨過濾分析")

# 4. 定義 API 請求與使用者模型
class AnalyzeRequest(BaseModel):
    url: str = Field(..., description="商家的 Google Maps 網址或名稱")

class ProfileUpdateRequest(BaseModel):
    name: str
    email: str
    avatar: Optional[str] = None

class ConnectRequest(BaseModel):
    provider: str

class PreferencesRequest(BaseModel):
    sample_size: int
    focus_area: str

class BookmarkToggleRequest(BaseModel):
    title: str

class RegisterRequest(BaseModel):
    username: str = Field(..., description="使用者帳號")
    password: str = Field(..., description="密碼")
    name: str = Field(..., description="顯示名稱")
    email: str = Field(..., description="電子信箱")

class LoginRequest(BaseModel):
    username: str = Field(..., description="使用者帳號")
    password: str = Field(..., description="密碼")

# 5. SQLite 資料庫初始化與預設 Demo 數據
def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    print(f"--- [VeriMap Database] Initializing SQLite Database at: {DB_PATH} ---")
    conn = get_db()
    cursor = conn.cursor()
    
    # 檢查是否需要升級結構 (若沒有 username 欄位，就重建表格)
    schema_needs_reset = False
    try:
        cursor.execute("SELECT username FROM users LIMIT 1")
    except sqlite3.OperationalError:
        schema_needs_reset = True
        
    if schema_needs_reset:
        print("[Database] Schema upgraded or needs resetting. Recreating tables...")
        cursor.execute("DROP TABLE IF EXISTS records")
        cursor.execute("DROP TABLE IF EXISTS users")
        conn.commit()
    
    # 創建 users 表
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password_hash TEXT,
            name TEXT DEFAULT '陳大文',
            email TEXT DEFAULT 'raymond.chan@example.com',
            avatar TEXT DEFAULT 'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none"><circle cx="50" cy="50" r="50" fill="url(%23grad)"/><defs><linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="%231a73e8"/><stop offset="100%" stop-color="%238000ff"/></linearGradient></defs><circle cx="50" cy="40" r="18" fill="white" opacity="0.95"/><path d="M20 78 C20 62, 35 58, 50 58 C65 58, 80 62, 80 78" fill="white" opacity="0.95"/></svg>',
            is_google_connected INTEGER DEFAULT 1,
            is_apple_connected INTEGER DEFAULT 0,
            is_line_connected INTEGER DEFAULT 0,
            sample_size INTEGER DEFAULT 80,
            focus_area TEXT DEFAULT '全部'
        )
    """)
    
    # 創建 records 表 (與 user_id 綁定，防止同名商家在多使用者間衝突)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER DEFAULT 1,
            url TEXT,
            title TEXT,
            subtitle TEXT,
            score INTEGER,
            star_rating REAL,
            original_star_rating REAL DEFAULT 4.5,
            label TEXT,
            zero_text_spam TEXT,
            duplicate_patterns TEXT,
            incentivized_triggers TEXT,
            service_attitude TEXT,
            environment_hygiene TEXT,
            low_star_analysis TEXT,
            mid_star_analysis TEXT,
            high_star_analysis TEXT,
            malicious_bomb_detected INTEGER DEFAULT 0,
            malicious_bomb_ratio INTEGER DEFAULT 0,
            is_bookmarked INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id),
            UNIQUE (user_id, title)
        )
    """)
    
    conn.commit()

    # 執行資料庫遷移：如果 records 表沒有 original_star_rating 欄位，則新增它
    try:
        cursor.execute("SELECT original_star_rating FROM records LIMIT 1")
    except sqlite3.OperationalError:
        print("[Database Migration] Adding original_star_rating column to records table...")
        cursor.execute("ALTER TABLE records ADD COLUMN original_star_rating REAL DEFAULT 4.5")
        conn.commit()
    
    # 檢查並寫入預設的使用者 (raymond / 123456)
    cursor.execute("SELECT COUNT(*) as count FROM users")
    if cursor.fetchone()["count"] == 0:
        pwd_hash = hashlib.sha256(b"123456").hexdigest()
        cursor.execute("""
            INSERT INTO users (username, password_hash, name, email, is_google_connected, is_apple_connected, is_line_connected)
            VALUES ('raymond', ?, '陳大文', 'raymond.chan@example.com', 1, 0, 0)
        """, (pwd_hash,))
        conn.commit()
        print("[Database] Default User '陳大文' (raymond / 123456) inserted.")

    # 檢查並寫入預設的 4 筆商譽紀錄
    cursor.execute("SELECT COUNT(*) as count FROM records")
    if cursor.fetchone()["count"] == 0:
        presets = [
            {
                "title": "錦錨餐廳",
                "subtitle": "2 小時前分析 • 共 80 則評論",
                "score": 85,
                "star_rating": 4.2,
                "original_star_rating": 4.5,
                "label": "信譽良好",
                "zero_text_spam": "未發現顯著無文字五星灌水現象，真實度良好。",
                "duplicate_patterns": "未發現大量重複罐頭評論，評論個體化程度高。",
                "incentivized_triggers": "發現 2 則評論提及打卡送小菜。",
                "service_attitude": "未發現顯著服務態度問題，顧客稱讚櫃檯親切。",
                "environment_hygiene": "有 1 則抱怨說杯子洗得不夠乾淨。",
                "low_star_analysis": "低星差評比例低，已過濾無理惡意差評，真實反映餐具偶有不潔狀況。",
                "mid_star_analysis": "中星評論反映出尖峰時段出餐速度較慢，但分量足夠。",
                "high_star_analysis": "多數高星好評描述詳細，推測為真實滿意度反映。",
                "malicious_bomb_detected": 0,
                "malicious_bomb_ratio": 0,
                "is_bookmarked": 1
            },
            {
                "title": "老街豆花",
                "subtitle": "4 小時前分析 • 共 50 則評論",
                "score": 68,
                "star_rating": 3.8,
                "original_star_rating": 4.4,
                "label": "信譽良好",
                "zero_text_spam": "無字好評比例偏高 (25%)，顯示有部分灌水跡象。",
                "duplicate_patterns": "發現少量類似「推推！下次還要再來！」的罐頭評論。",
                "incentivized_triggers": "發現有打卡送豆漿的行銷推廣痕跡。",
                "service_attitude": "部分顧客反映店員動作稍慢，但態度依然客氣。",
                "environment_hygiene": "桌椅清理乾淨，衛生大致良好。",
                "low_star_analysis": "低星差評多因排隊等待時間過長引起，為正常客觀抱怨。",
                "mid_star_analysis": "多數顧客給予中評，表示分量與價格均屬正常，無功無過。",
                "high_star_analysis": "好評以觀光客分享為主，夾雜了部分店家贈禮的打卡評論。",
                "malicious_bomb_detected": 0,
                "malicious_bomb_ratio": 3,
                "is_bookmarked": 0
            },
            {
                "title": "42號小館",
                "subtitle": "5 小時前分析 • 共 100 則評論",
                "score": 32,
                "star_rating": 2.3,
                "original_star_rating": 4.8,
                "label": "信譽較差",
                "zero_text_spam": "無字五星好評暴增 (75%)，有高度水軍刷榜嫌疑。",
                "duplicate_patterns": "發現大量完全重複的模板文「老闆人很好！環境乾淨！推！」。",
                "incentivized_triggers": "明確查獲大量行銷活動洗評現象。",
                "service_attitude": "多位真實顧客投訴服務人員態度冷漠、甚至跟客人爭吵。",
                "environment_hygiene": "多篇真實差評指出桌子黏膩、筷子有前人的油漬，衛生堪憂。",
                "low_star_analysis": "低星評論多數指出核心服務與衛生痛點，包含出餐不乾淨、服務員態度惡劣，為真實嚴重投訴。",
                "mid_star_analysis": "幾乎沒有中立評論，分數分佈呈極端兩極化，顯示人為操縱分數明顯。",
                "high_star_analysis": "好評高達 90% 均為無文字或極端簡短的主廚空洞讚美，具高度虛假灌水特徵。",
                "malicious_bomb_detected": 1,
                "malicious_bomb_ratio": 8,
                "is_bookmarked": 0
            },
            {
                "title": "極品燒肉",
                "subtitle": "3 天前分析 • 共 90 則評論",
                "score": 92,
                "star_rating": 4.6,
                "original_star_rating": 4.7,
                "label": "信譽良好",
                "zero_text_spam": "未發現任何灌水嫌疑，星等可信度極高。",
                "duplicate_patterns": "完全無重複罐頭文特徵，評論極具個人就餐感受。",
                "incentivized_triggers": "完全未提及任何好評送禮等利益誘因行為。",
                "service_attitude": "極致好評！多則評論具體點名感謝特定桌邊服務人員之貼心。",
                "environment_hygiene": "環境排煙一流，乾淨整潔無异味。",
                "low_star_analysis": "極少數低星差評均為預約困難或價格高昂的抱怨，無同行惡意攻擊特徵。",
                "mid_star_analysis": "中星評論指出假日較難停車。",
                "high_star_analysis": "極高比例的真實正面反饋，描述細緻生動，可信度極優。",
                "malicious_bomb_detected": 0,
                "malicious_bomb_ratio": 0,
                "is_bookmarked": 1
            }
        ]
        for p in presets:
            cursor.execute("""
                INSERT INTO records (
                    user_id, url, title, subtitle, score, star_rating, original_star_rating, label,
                    zero_text_spam, duplicate_patterns, incentivized_triggers,
                    service_attitude, environment_hygiene, low_star_analysis,
                    mid_star_analysis, high_star_analysis, malicious_bomb_detected,
                    malicious_bomb_ratio, is_bookmarked
                ) VALUES (1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                p["title"], p["title"], p["subtitle"], p["score"], p["star_rating"], p["original_star_rating"], p["label"],
                p["zero_text_spam"], p["duplicate_patterns"], p["incentivized_triggers"],
                p["service_attitude"], p["environment_hygiene"], p["low_star_analysis"],
                p["mid_star_analysis"], p["high_star_analysis"], p["malicious_bomb_detected"],
                p["malicious_bomb_ratio"], p["is_bookmarked"]
            ))
        conn.commit()
        print("[Database] 4 default analysis presets inserted successfully.")
    
    # 遷移現有使用者的舊頭像網址為新版 SVG 圖標，移除真人肖像以保護隱私並美化
    try:
        cursor.execute("""
            UPDATE users 
            SET avatar = 'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="none"><circle cx="50" cy="50" r="50" fill="url(%23grad)"/><defs><linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="%231a73e8"/><stop offset="100%" stop-color="%238000ff"/></linearGradient></defs><circle cx="50" cy="40" r="18" fill="white" opacity="0.95"/><path d="M20 78 C20 62, 35 58, 50 58 C65 58, 80 62, 80 78" fill="white" opacity="0.95"/></svg>'
            WHERE avatar LIKE '%lh3.googleusercontent.com%'
        """)
        conn.commit()
        print("[Database Migration] Migrated old human portrait avatars to SVG generic avatars successfully.")
    except Exception as migration_err:
        print(f"[Database Migration Error] {migration_err}")

    conn.close()

# 啟動時初始化資料庫
init_db()

# 6. URL 解析商家名稱 Helper
import urllib.parse
import re

def extract_merchant_name(url_or_name: str) -> str:
    if not url_or_name.startswith("http"):
        return url_or_name
    
    try:
        decoded_url = urllib.parse.unquote(url_or_name)
        match = re.search(r"/maps/place/([^/]+)", decoded_url)
        if match:
            name = match.group(1).replace("+", " ").strip()
            if "@" in name:
                name = name.split("@")[0].strip()
            return name
    except Exception:
        pass
    
    try:
        parsed_url = urllib.parse.urlparse(url_or_name)
        params = urllib.parse.parse_qs(parsed_url.query)
        if "q" in params:
            return params["q"][0].strip()
    except Exception:
        pass

    return url_or_name

# =====================================================================
# API 路由區段
# =====================================================================

# A. 註冊與登入模組
@app.post("/user/register")
def register_user(payload: RegisterRequest):
    conn = get_db()
    cursor = conn.cursor()
    
    # 檢查使用者是否已存在
    cursor.execute("SELECT id FROM users WHERE username = ?", (payload.username,))
    if cursor.fetchone():
        conn.close()
        raise HTTPException(status_code=400, detail="此使用者帳號已存在！")
        
    pwd_hash = hashlib.sha256(payload.password.encode()).hexdigest()
    try:
        cursor.execute("""
            INSERT INTO users (username, password_hash, name, email)
            VALUES (?, ?, ?, ?)
        """, (payload.username, pwd_hash, payload.name, payload.email))
        conn.commit()
        
        new_id = cursor.lastrowid
        conn.close()
        return {
            "status": "success",
            "message": "註冊成功！請使用此帳號登入。",
            "user": {
                "id": new_id,
                "username": payload.username,
                "name": payload.name,
                "email": payload.email
            }
        }
    except Exception as e:
        conn.close()
        raise HTTPException(status_code=500, detail=f"註冊時發生錯誤: {str(e)}")

@app.post("/user/login")
def login_user(payload: LoginRequest):
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute("SELECT * FROM users WHERE username = ?", (payload.username,))
    user = cursor.fetchone()
    
    if not user:
        conn.close()
        raise HTTPException(status_code=400, detail="使用者帳號不存在，請重新輸入！")
        
    pwd_hash = hashlib.sha256(payload.password.encode()).hexdigest()
    if user["password_hash"] != pwd_hash:
        conn.close()
        raise HTTPException(status_code=400, detail="密碼錯誤，請重新輸入！")
        
    user_id = user["id"]
    conn.close()
    return {
        "status": "success",
        "message": "登入成功！歡迎使用 VeriMap 系統！",
        "user": {
            "id": user_id,
            "username": user["username"],
            "name": user["name"],
            "email": user["email"]
        }
    }

# B. 個人檔案與設定模組 (支援 x-user-id 頭部)
@app.get("/user/profile")
def get_user_profile(x_user_id: Optional[str] = Header(None)):
    user_id = int(x_user_id) if x_user_id else 1
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    user = cursor.fetchone()
    
    if not user:
        conn.close()
        raise HTTPException(status_code=404, detail="找不到對應的使用者帳號！")
        
    # 計算該使用者的歷史記錄與收藏數
    cursor.execute("SELECT COUNT(*) as total FROM records WHERE user_id = ?", (user_id,))
    total_analyzed = cursor.fetchone()["total"]
    
    cursor.execute("SELECT COUNT(*) as bookmarked FROM records WHERE user_id = ? AND is_bookmarked = 1", (user_id,))
    total_bookmarked = cursor.fetchone()["bookmarked"]
    
    conn.close()
    
    return {
        "name": user["name"],
        "email": user["email"],
        "avatar": user["avatar"],
        "isGoogleConnected": bool(user["is_google_connected"]),
        "isAppleConnected": bool(user["is_apple_connected"]),
        "isLineConnected": bool(user["is_line_connected"]),
        "sampleSize": user["sample_size"],
        "focusArea": user["focus_area"],
        "totalAnalyzed": total_analyzed,
        "totalBookmarked": total_bookmarked
    }

@app.put("/user/profile")
def update_user_profile(payload: ProfileUpdateRequest, x_user_id: Optional[str] = Header(None)):
    user_id = int(x_user_id) if x_user_id else 1
    conn = get_db()
    cursor = conn.cursor()
    
    if payload.avatar:
        cursor.execute("""
            UPDATE users
            SET name = ?, email = ?, avatar = ?
            WHERE id = ?
        """, (payload.name, payload.email, payload.avatar, user_id))
    else:
        cursor.execute("""
            UPDATE users
            SET name = ?, email = ?
            WHERE id = ?
        """, (payload.name, payload.email, user_id))
    
    conn.commit()
    conn.close()
    return {"status": "success", "message": "個人檔案已成功保存！"}

@app.post("/user/connect")
def toggle_connection(payload: ConnectRequest, x_user_id: Optional[str] = Header(None)):
    user_id = int(x_user_id) if x_user_id else 1
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    user = cursor.fetchone()
    
    if not user:
        conn.close()
        raise HTTPException(status_code=404, detail="找不到使用者！")
        
    if payload.provider == 'apple':
        new_val = 1 - user["is_apple_connected"]
        cursor.execute("UPDATE users SET is_apple_connected = ? WHERE id = ?", (new_val, user_id))
    elif payload.provider == 'line':
        new_val = 1 - user["is_line_connected"]
        cursor.execute("UPDATE users SET is_line_connected = ? WHERE id = ?", (new_val, user_id))
    else:
        conn.close()
        raise HTTPException(status_code=400, detail="不支援的連接類型！")
        
    conn.commit()
    conn.close()
    return {"status": "success", "message": "連接開關狀態已持久化保存！"}

@app.post("/user/preferences")
def update_preferences(payload: PreferencesRequest, x_user_id: Optional[str] = Header(None)):
    user_id = int(x_user_id) if x_user_id else 1
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute("""
        UPDATE users
        SET sample_size = ?, focus_area = ?
        WHERE id = ?
    """, (payload.sample_size, payload.focus_area, user_id))
    
    conn.commit()
    conn.close()
    return {"status": "success", "message": "分析偏好設定已儲存！"}

# C. 分析紀錄模組 (多帳號隔離與收藏關聯)
@app.get("/history")
def get_analysis_history(x_user_id: Optional[str] = Header(None)):
    user_id = int(x_user_id) if x_user_id else 1
    conn = get_db()
    cursor = conn.cursor()
    
    # 僅查詢該使用者的紀錄
    cursor.execute("SELECT * FROM records WHERE user_id = ? ORDER BY id DESC", (user_id,))
    rows = cursor.fetchall()
    conn.close()
    
    results = []
    for r in rows:
        results.append({
            "title": r["title"],
            "url": r["url"] or r["title"],
            "subtitle": r["subtitle"],
            "score": r["score"],
            "starRating": r["star_rating"],
            "originalStarRating": r["original_star_rating"] if "original_star_rating" in r.keys() else 4.5,
            "label": r["label"],
            "zeroTextSpam": r["zero_text_spam"],
            "duplicatePatterns": r["duplicate_patterns"],
            "incentivizedTriggers": r["incentivized_triggers"],
            "serviceAttitude": r["service_attitude"],
            "environmentHygiene": r["environment_hygiene"],
            "lowStarAnalysis": r["low_star_analysis"],
            "midStarAnalysis": r["mid_star_analysis"],
            "highStarAnalysis": r["high_star_analysis"],
            "maliciousBombDetected": bool(r["malicious_bomb_detected"]),
            "maliciousBombRatio": r["malicious_bomb_ratio"],
            "isBookmarked": bool(r["is_bookmarked"])
        })
    return results

@app.post("/bookmarks/toggle")
def toggle_bookmark(payload: BookmarkToggleRequest, x_user_id: Optional[str] = Header(None)):
    user_id = int(x_user_id) if x_user_id else 1
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute("SELECT is_bookmarked FROM records WHERE user_id = ? AND title = ?", (user_id, payload.title))
    row = cursor.fetchone()
    
    if not row:
        conn.close()
        raise HTTPException(status_code=404, detail="找不到該商家分析紀錄！")
        
    new_bookmark_state = 1 - row["is_bookmarked"]
    cursor.execute("UPDATE records SET is_bookmarked = ? WHERE user_id = ? AND title = ?", (new_bookmark_state, user_id, payload.title))
    conn.commit()
    conn.close()
    
    return {
        "status": "success", 
        "title": payload.title, 
        "isBookmarked": bool(new_bookmark_state),
        "message": "收藏狀態已成功持久化至資料庫！"
    }

# D. 備份模擬打假引擎 (手動 Demo 快照)
def generate_fallback_analysis(merchant_name: str, sample_limit: int) -> dict:
    import hashlib
    h = int(hashlib.md5(merchant_name.encode('utf-8')).hexdigest(), 16)
    score = 55 + (h % 35)
    rating = round(3.1 + (h % 15) * 0.1, 1)
    total = sample_limit
    
    if "開源社" in merchant_name:
        return {
            "merchant_name": merchant_name,
            "veri_score": 64,
            "real_star_rating": 3.7,
            "total_analyzed": 76,
            "metrics": {
                "zero_text_spam": "發現約 30% 的五星好評為無文字純給分。對於學區平價雞排店而言，此類純給分多為學生快速支持，灌水動機屬中等偏低。",
                "duplicate_patterns": "未發現明顯的大規模水軍洗評。評論大多呈現個別消費者的語氣，多數為學區顧客的即時簡短讚賞。",
                "incentivized_triggers": "偵測到約 10% 的評論提及「好評送甜不辣」或「打卡送飲料」等學區促銷活動，存在一定的行銷誘因引導好評。"
            },
            "nlp_insights": {
                "service_attitude_issue": "偶有評論投訴尖峰時段店員態度較為不耐煩，但整體而言，對於平價小吃店的服務態度，多數顧客並無過高要求，屬正常範圍。",
                "environment_hygiene_issue": "部分評論提及油煙味較重，且店內油炸環境稍顯油膩，但對於外帶為主的雞排店，並不影響核心消費體驗。"
            },
            "stratified_analysis": {
                "low_star_analysis": "40% 低星評論中，有相當比例 (約 35%) 屬於無理謾罵（如「難吃死」、「一顆星都不想給」等情緒發洩），在排除這類同行惡意或極端評論後，真實反映的僅有出餐排隊稍久等常規痛點。",
                "mid_star_analysis": "30% 中星評論指出口味中規中矩，雞排分量十足，但調味稍微偏鹹，是中立客觀的描述。",
                "high_star_analysis": "30% 高星好評多集中於讚揚雞排的多汁與皮脆，其中約有 10% 疑似是受贈品小點心吸引而給的好評。",
                "malicious_bomb_detected": False,
                "malicious_bomb_ratio": 12
            }
        }
    
    return {
        "merchant_name": merchant_name,
        "veri_score": score,
        "real_star_rating": rating,
        "total_analyzed": total,
        "metrics": {
            "zero_text_spam": f"偵測到約 {h % 15 + 10}% 的無文字五星好評為無文字純給分。顯示有部分自然形成的快速好評，灌水風險屬低到中等。",
            "duplicate_patterns": "經分析，未發現大規模的機器水軍或極端重複的罐頭評論，評論的語言特徵分散且具備個體特徵。",
            "incentivized_triggers": f"發現約 {h % 12 + 2}% 的評論包含如「打卡送飲料」、「好評送小點心」等字眼，存在輕度的行銷利益引導傾向。"
        },
        "nlp_insights": {
            "service_attitude_issue": "多數評論滿意員工的服務態度，部分提及尖峰期店員因忙碌稍顯冷淡，但未發現嚴重態度爭議。",
            "environment_hygiene_issue": "衛生整潔度大致良好，除少數評論指出餐具清潔需加強外，無重大的衛生疑慮。"
        },
        "stratified_analysis": {
            "low_star_analysis": f"低星差評 (約佔 {15 + h % 10}%) 多集中於價格偏高、排隊時間過長等客觀因素，已自動過濾無理謾罵與惡意負評雜訊。",
            "mid_star_analysis": "中星評論 (約佔 30%) 呈現正反兩面並陳的客觀觀點，提及產品品質好但空間偏小。",
            "high_star_analysis": "高星好評 (約佔 45%) 以真實消費滿意反饋為主，伴隨少量的自然推薦。",
            "malicious_bomb_detected": (score < 60),
            "malicious_bomb_ratio": h % 12
        }
    }

# E. 核心實時分析端點 (移除自動備用模擬，直接反饋 API 限額 429 錯誤)
@app.post("/analyze", response_model=AnalysisResponse)
async def analyze_reviews(payload: AnalyzeRequest, x_user_id: Optional[str] = Header(None)):
    user_id = int(x_user_id) if x_user_id else 1
    merchant_name = extract_merchant_name(payload.url)
    print(f"--- [VeriMap Backend] User: {user_id} | Extracted Merchant Name: {merchant_name} ---")

    # 讀取該使用者的 sample size 與剖析焦點偏好
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT sample_size, focus_area FROM users WHERE id = ?", (user_id,))
    user_pref = cursor.fetchone()
    sample_limit = user_pref["sample_size"] if user_pref else 80
    focus_area = user_pref["focus_area"] if user_pref else "全部"
    conn.close()

    result = None

    # 1. 嘗試使用 Gemini 進行實時聯網搜尋與分析
    gemini_api_key = os.getenv("GEMINI_API_KEY")
    if not gemini_api_key or "your_gemini_api_key_here" in gemini_api_key:
        raise HTTPException(
            status_code=400,
            detail="⚠️ 伺服器未設定有效的 GEMINI_API_KEY 環境變數！請在 'backend' 資料夾下建立 '.env' 檔案並填入。"
        )
    
    try:
        from google import genai
        from google.genai import types
        client = genai.Client(api_key=gemini_api_key)
        
        search_prompt = f"""
請利用你的 Google Search 工具，針對以下商家進行「全方位、多次且多維度的深度聯網搜尋與資料收集」：
👉 商家名稱：{merchant_name}
👉 原始地圖網址：{payload.url}
👉 分析偏好焦點：{focus_area}

【剖析焦點指引】
使用者目前的分析偏好焦點為「{focus_area}」。若焦點非「全部」，請在網路搜尋及閱讀評價時，特別著重並加強收集與「{focus_area}」相關的真實顧客體驗、具體抱怨、讚賞特徵或消費痛點。

【多維度搜尋組合指引】
請以「{merchant_name}」作為主要搜尋關鍵字，自動執行至少 4-5 次不同的搜尋組合，以完整覆蓋不同星級的評論：
1. 搜尋低分評論組合（1-2 星）：「{merchant_name} 差評 抱怨 投訴 態度 髒 爛 1星 2星 糾紛 PTT Dcard」
2. 搜尋中分評論組合（3 星）：「{merchant_name} 3星 普通 還好 評價」
3. 搜尋高分評論組合（4-5 星）：「{merchant_name} 五星 好評 推薦 4星 5星 醫療團隊 專業」
4. 搜尋是否有惡意負評或對手抹黑：「{merchant_name} 惡意 爭議 糾紛 對手 抹黑 新聞」
5. 針對分析焦點加強搜尋（當焦點不為全部時）：特別組合如「{merchant_name} {focus_area}」進行深度查找。

【任務與收集目標】
請大量閱讀並分析搜尋結果，儘可能廣泛地收集並彙整該商家【{sample_limit} 則左右】不同的真實顧客評價內容與評分數據。
請將收集到的數據整理成詳細報告，並在報告中特別包含以下三個分層的內容：
- 【低分評論區（約佔 40%）】：收集顧客具體的不滿。請特別注意並辨識是否有「情緒化惡意洗版、同行惡意抹黑、無實質內容的針對性發洩」；將這些雜訊過濾，找出「相對正常、有具體消費/看診細節、具有真實參考意義」的實質負評。
- 【中分評論區（約佔 30%）】：收集態度中立、客觀指出優缺點的消費體驗。
- 【高分評論區（約佔 30%）】：收集正面讚賞，並分析其是否屬於真實體驗或是疑似打卡利益引誘的灌水好評。
"""
        
        # 第一階段：聯網搜尋
        search_response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=search_prompt,
            config=types.GenerateContentConfig(
                system_instruction="你是一個專業的網路信譽與評論研究專家。你的任務是利用聯網搜尋，為指定商家收集並整理最真實的 Google 評論與信譽背景資料，落實分層分析抽樣與過濾惡意負評。",
                tools=[{"google_search": {}}],
                temperature=0.2,
            )
        )
        
        search_text = getattr(search_response, "text", None)
        if not search_text and search_response.candidates and search_response.candidates[0].content.parts:
            search_text = search_response.candidates[0].content.parts[0].text
        if not search_text:
            raise ValueError(f"無法透過 Google Search 搜尋到商家 {merchant_name} 的評論資料。")

        # 第二階段：結構化 JSON 分析
        analysis_prompt = f"""
以下是利用 Google Search 實時深度抓取到關於商家的真實大量評論與網路信譽資料：
=== 搜尋到的真實資料開始 ===
{search_text}
=== 搜尋到的真實資料結束 ===

👉 使用者剖析焦點偏好：{focus_area}

【偏好焦點分析指令】
本次評估的使用者分析偏好焦點為：「{focus_area}」。請在做語意分析時特別著重與呼應使用者的焦點：
- 若焦點為「服務態度」，請特別擴大與深化 `service_attitude_issue` 中的案例挖掘與顧客反映細節。
- 若焦點為「衛生清潔」，請特別擴大與深化 `environment_hygiene_issue` 中的案例挖掘與顧客反映細節。
- 若焦點為「產品為主」，請在做評論分層分析（`low_star_analysis`、`mid_star_analysis`、`high_star_analysis`）以及整體可信度評估時，特別著重分析該商家在「產品/商品/餐點品質、口味、商品瑕疵、耐用度或用料細節」方面的真實反饋與優缺點提煉。

【任務】
請根據上述「真實且豐富的搜尋資料」，進行嚴格的 NLP 分析與可信度打分評估，並將分析結果格式化填入指定的 JSON 格式中：

請嚴格填充以下結構，且不能自創其他欄位：
1. merchant_name: 辨識出的商家真實官方名稱。
2. veri_score: 計算一個 0 到 100 之間的 VeriScore 可信度評分：
   - 大量真實正面評論、幾乎無灌水嫌疑 ➜ 85-100 分。
   - 有少量利益引誘或無字高分 ➜ 70-84 分。
   - 發現明顯重複水軍罐頭文或大量行銷灌水 ➜ 40-69 分。
   - 惡意洗好評、高度造假或極多顧客真實投訴環境與態度痛點 ➜ 0-39 分。
3. real_star_rating: 核心亮點！過濾掉水軍好評與惡意負評雜訊後，AI 評估出的該商家『綜合實際星等』。必須填寫 1.0 到 5.0 之間的浮點數（例如：3.6 或是 2.8），此分數反映了過濾偏誤雜訊後最真實的顧客滿意度。
4. total_analyzed: 深度分析的真實評論估計總筆數（必須填寫 {sample_limit} 左右的整數）。
5. metrics (灌水指標評估，請結合大量樣本分析)：
   - zero_text_spam: 評估無字五星灌水比例（分析是否有高比例純給五星但沒有寫文字評論的灌水行為）。
   - duplicate_patterns: 評估重複罐頭文特徵（是否有大量罐頭文或水軍灌水跡象）。
   - incentivized_triggers: 評估利益誘因分析（是否提及打卡送禮物、送折扣、送小菜等行銷利益引誘特徵）。
6. nlp_insights (語意痛點偵測，請提煉大樣本評論中的核心痛點與具體案例)：
   - service_attitude_issue: 深度提取並評估真實顧客對服務品質、櫃檯/醫護人員態度冷漠或口角等具體反饋與摘要（若無則寫「未發現顯著服務態度問題」）。
   - environment_hygiene_issue: 深度提取並評估真實顧客對環境整潔度、餐具/儀器衛生、桌椅黏膩或髒亂等具體反饋與摘要（若無則寫「未發現顯著環境衛生問題」）。
7. stratified_analysis (核心亮點：40%/30%/30% 分層抽樣打假與真實抱怨過濾分析)：
   - low_star_analysis: 40% 低星評論 (1-2星) 分析：辨識是否有同行惡意抹黑、水軍差評或情緒化無理發洩；並過濾雜訊，提取相對正常、客觀且有真實參考價值的實質抱怨。
   - mid_star_analysis: 30% 中星評論 (3星) 分析：摘要客觀、中立、好壞並陳的真實顧客回饋。
   - high_star_analysis: 30% 高星評論 (4-5星) 分析：評估正面評價中，有多少屬於自然的真實讚美，多少屬於活動打卡或行銷洗出來的虛假好評。
   - malicious_bomb_detected: 是否偵測到顯著的惡意針對或同行抹黑洗差評現象 (必須填寫布林值 true 或 false)。
   - malicious_bomb_ratio: 估計低星差評中屬於『惡意/無理發洩/抹黑』的百分比 (必須填寫 0 到 100 之間的整數)。

請嚴格使用繁體中文，且只輸出符合指定 Schema 的 JSON。
"""

        analysis_response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=analysis_prompt,
            config=types.GenerateContentConfig(
                system_instruction="你是一個專門分析網路商家評論信譽的 AI 專家。請根據提供的真實背景搜尋資料，嚴格以 JSON 格式進行商家的可信度評估與分析，輸出必須完美匹配 response_schema 結構。",
                response_mime_type="application/json",
                response_schema=AnalysisResponse,
                temperature=0.1,
            ),
        )

        raw_analysis_text = getattr(analysis_response, "text", None)
        if not raw_analysis_text and analysis_response.candidates and analysis_response.candidates[0].content.parts:
            raw_analysis_text = analysis_response.candidates[0].content.parts[0].text
        
        if not raw_analysis_text:
            raise ValueError("Gemini 結構化分析回傳空內容。")

        result = json.loads(raw_analysis_text)
        
    except Exception as e:
        error_msg = str(e)
        status_code = 500
        # 👈 識別 API 額度用盡的 429 錯誤
        if "429" in error_msg or "RESOURCE_EXHAUSTED" in error_msg:
            status_code = 429
            detail_msg = f"⚠️ Gemini API Key 額度已耗盡 (429 Resource Exhausted)！請檢查您的 Google AI Studio 帳單或配額限額。\n錯誤細節：{error_msg}"
        else:
            detail_msg = f"⚠️ 呼叫 Gemini 聯網搜尋與打假分析失敗！\n錯誤細節：{error_msg}"
            
        print(f"[API Error] Real-time analysis failed: {detail_msg}")
        raise HTTPException(
            status_code=status_code,
            detail=detail_msg
        )

    # 2. 解析欄位以持久化寫入資料庫
    res_merchant = result.get("merchant_name", merchant_name)
    veri_score = int(result.get("veri_score", 50))
    real_star_rating = float(result.get("real_star_rating", 3.5))
    original_star_rating = float(result.get("original_star_rating", 4.5))
    total_analyzed = int(result.get("total_analyzed", sample_limit))
    
    metrics_obj = result.get("metrics", {})
    zero_text_spam = metrics_obj.get("zero_text_spam", "無資料")
    duplicate_patterns = metrics_obj.get("duplicate_patterns", "無資料")
    incentivized_triggers = metrics_obj.get("incentivized_triggers", "無資料")
    
    nlp_obj = result.get("nlp_insights", {})
    service_attitude_issue = nlp_obj.get("service_attitude_issue", "未發現顯著服務態度問題")
    environment_hygiene_issue = nlp_obj.get("environment_hygiene_issue", "未發現顯著環境衛生問題")
    
    strat_obj = result.get("stratified_analysis", {})
    low_star_analysis = strat_obj.get("low_star_analysis", "無資料")
    mid_star_analysis = strat_obj.get("mid_star_analysis", "無資料")
    high_star_analysis = strat_obj.get("high_star_analysis", "無資料")
    malicious_bomb_detected = 1 if strat_obj.get("malicious_bomb_detected", False) else 0
    malicious_bomb_ratio = int(strat_obj.get("malicious_bomb_ratio", 0))

    label = "信譽中等"
    if veri_score >= 68: label = "信譽良好"
    elif veri_score >= 45: label = "信譽中等"
    else: label = "信譽較差"

    # 3. 持久化寫入/更新 SQLite 資料庫 (UNIQUE user_id + title)
    try:
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO records (
                user_id, url, title, subtitle, score, star_rating, original_star_rating, label,
                zero_text_spam, duplicate_patterns, incentivized_triggers,
                service_attitude, environment_hygiene, low_star_analysis,
                mid_star_analysis, high_star_analysis, malicious_bomb_detected,
                malicious_bomb_ratio, is_bookmarked
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)
            ON CONFLICT(user_id, title) DO UPDATE SET
                url = excluded.url,
                subtitle = excluded.subtitle,
                score = excluded.score,
                star_rating = excluded.star_rating,
                original_star_rating = excluded.original_star_rating,
                label = excluded.label,
                zero_text_spam = excluded.zero_text_spam,
                duplicate_patterns = excluded.duplicate_patterns,
                incentivized_triggers = excluded.incentivized_triggers,
                service_attitude = excluded.service_attitude,
                environment_hygiene = excluded.environment_hygiene,
                low_star_analysis = excluded.low_star_analysis,
                mid_star_analysis = excluded.mid_star_analysis,
                high_star_analysis = excluded.high_star_analysis,
                malicious_bomb_detected = excluded.malicious_bomb_detected,
                malicious_bomb_ratio = excluded.malicious_bomb_ratio
        """, (
            user_id,
            payload.url,
            res_merchant,
            f"剛剛分析 • 共 {total_analyzed} 則評論",
            veri_score,
            real_star_rating,
            original_star_rating,
            label,
            zero_text_spam,
            duplicate_patterns,
            incentivized_triggers,
            service_attitude_issue,
            environment_hygiene_issue,
            low_star_analysis,
            mid_star_analysis,
            high_star_analysis,
            malicious_bomb_detected,
            malicious_bomb_ratio
        ))
        conn.commit()
        conn.close()
        print(f"[Database] Persistent saved successfully: '{res_merchant}' for user {user_id} in verimap.db")
    except Exception as db_err:
        print(f"[Database Error] SQLite 持久化失敗: {db_err}")

    # 4. 回傳結構化 AnalysisResponse
    return {
        "merchant_name": res_merchant,
        "veri_score": veri_score,
        "real_star_rating": real_star_rating,
        "original_star_rating": original_star_rating,
        "total_analyzed": total_analyzed,
        "metrics": {
            "zero_text_spam": zero_text_spam,
            "duplicate_patterns": duplicate_patterns,
            "incentivized_triggers": incentivized_triggers
        },
        "nlp_insights": {
            "service_attitude_issue": service_attitude_issue,
            "environment_hygiene_issue": environment_hygiene_issue
        },
        "stratified_analysis": {
            "low_star_analysis": low_star_analysis,
            "mid_star_analysis": mid_star_analysis,
            "high_star_analysis": high_star_analysis,
            "malicious_bomb_detected": bool(malicious_bomb_detected),
            "malicious_bomb_ratio": malicious_bomb_ratio
        }
    }

# 首頁路由，顯示運作狀態
@app.get("/")
def read_root():
    return {
        "status": "online",
        "service": "VeriMap Database-Driven Backend API",
        "database": f"SQLite Connected ({DB_PATH})",
        "message": "後端 SQLite 關聯式資料庫引擎運作正常，在線為前端提供持久化服務！"
    }
