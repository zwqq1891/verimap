from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import collections

app = FastAPI(title="Google Maps 評論打假偵探 API", version="1.0")

# 定義前端傳過來的資料格式
class ReviewInput(BaseModel):
    stars: int
    text: Optional[str] = ""

class ReviewPayload(BaseModel):
    restaurant_name: str
    reviews: List[ReviewInput]

# 核心打假演算法路徑
@app.post("/api/analyze")
async def analyze_reviews(payload: ReviewPayload):
    total = len(payload.reviews)
    if total == 0:
        raise HTTPException(status_code=400, detail="評論列表不能為空！")

    empty_five_star = 0
    duplicate_text_count = 0
    incentive_count = 0
    boss_bad_count = 0
    environment_bad_count = 0
    food_good_count = 0

    # 利益交換/打卡小菜關鍵字組
    incentive_keywords = ['打卡', '送', '換', '小菜', '好評', '肉盤', '禮物', '飲料', '星', '招待']
    text_counts = collections.Counter()

    for r in payload.reviews:
        txt = r.text.strip() if r.text else ""
        
        # 5星但完全沒寫字
        if r.stars == 5 and len(txt) == 0:
            empty_five_star += 1
            continue
            
        if len(txt) == 0:
            continue

        text_counts[txt] += 1

        # 好評誘導檢測
        has_incentive = any(key in txt for key in incentive_keywords)
        if has_incentive and r.stars == 5:
            incentive_count += 1

        # 客觀店家特徵挖掘
        if '老闆' in txt and any(k in txt for k in ['差', '臭', '兇', '態度']):
            boss_bad_count += 1
        if any(k in txt for k in ['環境', '衛生', '髒', '不乾淨']):
            environment_bad_count += 1
        if any(k in txt for k in ['好吃', '美味', '讚', '推']) and any(k in txt for k in ['食物', '餐點', '肉', '菜']):
            food_good_count += 1

    for txt, count in text_counts.items():
        if count > 1:
            duplicate_text_count += count

    # 權重扣分演算法
    empty_penalty = (empty_five_star / total) * 30
    duplicate_penalty = (duplicate_text_count / total) * 40
    incentive_penalty = (incentive_count / total) * 50
    
    fake_score = min(100, round(empty_penalty + duplicate_penalty + incentive_penalty))
    real_score = 100 - fake_score

    return {
        "status": "success",
        "restaurant_name": payload.restaurant_name,
        "metrics": {
            "total_analyzed": total,
            "real_score": real_score,
            "fake_score_breakdown": {
                "total_fake_score": fake_score,
                "empty_five_star_count": empty_five_star,
                "duplicate_text_count": duplicate_text_count,
                "incentive_count": incentive_count
            }
        },
        "highlights": {
            "has_incentive_alert": incentive_count > 0,
            "has_water_army_alert": duplicate_text_count > 0
        },
        "features_summary": {
            "service_attitude_issue": boss_bad_count > 0,
            "environment_hygiene_issue": environment_bad_count > 0,
            "food_quality_excellent": food_good_count > 0
        }
    }