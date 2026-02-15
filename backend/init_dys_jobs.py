"""
德元升中医馆职位初始化脚本
按照管理、技术人员、保洁人员分类，从高到低排序
"""
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from app import app, db
from models.models import Job

def init_jobs():
    """初始化德元升中医馆的职位信息"""

    jobs_data = [
        # ==================== 管理类职位 ====================
        {
            "title": "馆长",
            "department": "管理层",
            "location": "隆回县桃花坪街道大桥路50号（原隆回县药材公司大院内）",
            "job_type": "full-time",
            "salary_range": "5000-10000元/月以上",
            "description": "全面负责德元升中医馆的运营管理工作，带领团队践行\"弘扬中医文化、让每个家庭都有一个懂中医的人\"的使命。",
            "requirements": """任职要求：
1. 医学、管理或相关专业背景
2. 5年以上医疗机构管理经验
3. 熟悉中医馆运营流程
4. 具备中医行业经验者优先
5. 年龄：30-50岁""",
            "responsibilities": """岗位职责：
1. 制定并执行中医馆发展战略
2. 负责日常运营管理和团队建设
3. 把控医疗服务质量和患者满意度
4. 协调各部门工作，确保高效运转
5. 拓展业务渠道，提升品牌影响力""",
            "status": "active",
            "category": "管理",
            "priority": 1,
            "position_count": 1
        },
        {
            "title": "副馆长",
            "department": "管理层",
            "location": "隆回县桃花坪街道大桥路50号（原隆回县药材公司大院内）",
            "job_type": "full-time",
            "salary_range": "5000-10000元/月以上",
            "description": "协助馆长管理中医馆日常运营，负责具体业务模块的管理工作。",
            "requirements": """任职要求：
1. 医学、管理或相关专业背景
2. 5年以上医疗机构管理经验
3. 熟悉中医馆运营流程
4. 具备中医行业经验者优先
5. 年龄：30-50岁""",
            "responsibilities": """岗位职责：
1. 协助馆长完成各项管理工作
2. 负责分管部门的日常运营
3. 监督医疗服务质量和流程规范
4. 处理客户投诉和突发事件
5. 参与战略规划和决策制定""",
            "status": "active",
            "category": "管理",
            "priority": 2,
            "position_count": 2
        },

        # ==================== 技术人员类职位（按薪资从高到低） ====================
        {
            "title": "中医执业医师",
            "department": "医疗部",
            "location": "隆回县桃花坪街道大桥路50号（原隆回县药材公司大院内）",
            "job_type": "full-time",
            "salary_range": "8000-20000元/月以上",
            "description": "负责中医诊疗工作，为患者提供专业的中医诊断和调理方案，传承和发扬中医药文化。",
            "requirements": """任职要求：
1. 具备中医医师执业资格证书
2. 中医临床经验十年以上
3. 退休名老中医优先
4. 年龄：40-65岁
5. 精通中医诊疗技术""",
            "responsibilities": """岗位职责：
1. 负责中医诊疗工作
2. 开具中医处方
3. 制定针对患者的个性化调理方案
4. 为患者提供健康咨询和养生指导
5. 参与疑难病例的会诊

薪资待遇：基本工资+提成，缴纳五险""",
            "status": "active",
            "category": "技术人员",
            "priority": 3,
            "position_count": 3
        },
        {
            "title": "健康顾问/售后人员",
            "department": "客户服务部",
            "location": "隆回县桃花坪街道大桥路50号（原隆回县药材公司大院内）",
            "job_type": "full-time",
            "salary_range": "3000-20000元/月",
            "description": "负责客户开发、服务及关系维护，为客户提供专业的健康咨询和售后服务。",
            "requirements": """任职要求：
1. 善于沟通，有销售经验优先
2. 有健康行业背景者优先
3. 年龄：30-55岁
4. 具备良好的服务意识和客户关系维护能力""",
            "responsibilities": """岗位职责：
1. 负责客户开发和邀约
2. 提供专业的健康咨询服务
3. 客情关系维护和跟踪服务
4. 客户满意度提升
5. 完成销售目标

薪资待遇：基本工资+提成，缴纳五险""",
            "status": "active",
            "category": "技术人员",
            "priority": 4,
            "position_count": 20
        },
        {
            "title": "网络/社区运营专员",
            "department": "市场部",
            "location": "隆回县桃花坪街道大桥路50号（原隆回县药材公司大院内）",
            "job_type": "full-time",
            "salary_range": "3000-10000元/月以上",
            "description": "负责中医馆品牌推广和社区运营，提升医馆知名度和影响力。",
            "requirements": """任职要求：
1. 大专及以上学历
2. 市场营销、传媒或相关专业
3. 有健康行业经验者优先
4. 年龄：25-40岁
5. 熟悉新媒体运营和社区营销""",
            "responsibilities": """岗位职责：
1. 策划并执行社区健康活动
2. 组织义诊和健康讲座
3. 线上运营和内容营销
4. 提升医馆知名度和品牌影响力
5. 数据分析和效果评估

薪资待遇：基本工资+提成，缴纳五险""",
            "status": "active",
            "category": "技术人员",
            "priority": 5,
            "position_count": 3
        },
        {
            "title": "综合专员（前台/收银/客服/导诊）",
            "department": "综合服务部",
            "location": "隆回县桃花坪街道大桥路50号（原隆回县药材公司大院内）",
            "job_type": "full-time",
            "salary_range": "3500-9000元/月",
            "description": "负责前台接待、收银、客服咨询和导诊服务，展现中医馆专业形象。",
            "requirements": """任职要求：
1. 形象气质佳，限女性
2. 善于沟通，有亲和力
3. 熟练使用电脑及常用办公软件
4. 打字流畅
5. 年龄：20-35岁""",
            "responsibilities": """岗位职责：
1. 前台接待和咨询服务
2. 收银和财务结算
3. 客户咨询和问题处理
4. 患者导诊和就医指引
5. 维护前台环境和秩序

薪资待遇：基本工资+提成，缴纳五险""",
            "status": "active",
            "category": "技术人员",
            "priority": 6,
            "position_count": 4
        },
        {
            "title": "理疗师",
            "department": "理疗部",
            "location": "隆回县桃花坪街道大桥路50号（原隆回县药材公司大院内）",
            "job_type": "full-time",
            "salary_range": "3000-8000元/月",
            "description": "为患者提供专业的中医理疗服务，包括针灸、推拿等传统疗法。",
            "requirements": """任职要求：
1. 中医针灸、推拿或康复相关专业
2. 持有相关资格证书的优先
3. 手法娴熟，有临床经验者优先
4. 具备耐心与亲和力
5. 年龄：25-55岁""",
            "responsibilities": """岗位职责：
1. 为患者提供针灸、推拿等理疗服务
2. 根据患者情况制定理疗方案
3. 观察治疗效果并及时调整
4. 做好理疗记录和患者沟通
5. 维护理疗设备和环境卫生

薪资待遇：基本工资+提成，缴纳五险""",
            "status": "active",
            "category": "技术人员",
            "priority": 7,
            "position_count": 3
        },
        {
            "title": "药剂师",
            "department": "药房",
            "location": "隆回县桃花坪街道大桥路50号（原隆回县药材公司大院内）",
            "job_type": "full-time",
            "salary_range": "3000-5000元/月",
            "description": "负责中药调剂、煎煮及药品质量管理，确保患者用药安全。",
            "requirements": """任职要求：
1. 中药学或相关专业
2. 具备药剂师资格证
3. 年龄：25-55岁
4. 熟悉中药材性质和配伍
5. 工作认真负责，细心严谨""",
            "responsibilities": """岗位职责：
1. 负责中药调剂和核对
2. 中药煎煮和质量把控
3. 药品质量管理和库存管理
4. 为患者提供用药指导
5. 维护药房环境和设备

薪资待遇：基本工资+提成，缴纳五险""",
            "status": "active",
            "category": "技术人员",
            "priority": 8,
            "position_count": 2
        },

        # ==================== 保洁人员类职位 ====================
        {
            "title": "保洁人员",
            "department": "后勤部",
            "location": "隆回县桃花坪街道大桥路50号（原隆回县药材公司大院内）",
            "job_type": "full-time",
            "salary_range": "2500-3000元/月",
            "description": "负责中医馆内环境卫生的清洁工作，为患者提供整洁舒适的就医环境。",
            "requirements": """任职要求：
1. 年龄：30-60岁
2. 身体健康，能胜任保洁工作
3. 工作认真负责
4. 有医疗机构保洁经验者优先""",
            "responsibilities": """岗位职责：
1. 负责中医馆内环境卫生的清洁
2. 诊室、走廊、卫生间等区域的日常清洁
3. 垃圾清理和分类处理
4. 保持医馆环境整洁有序
5. 配合做好消毒防疫工作

薪资待遇：缴纳五险""",
            "status": "active",
            "category": "保洁人员",
            "priority": 9,
            "position_count": 2
        }
    ]

    with app.app_context():
        # 清空现有职位（谨慎操作）
        print("正在清空现有职位数据...")
        Job.query.delete()
        db.session.commit()

        # 添加新职位
        print("正在添加德元升中医馆职位...")
        for job_data in jobs_data:
            job = Job(**job_data)
            db.session.add(job)
            print(f"  ✓ 添加职位: {job_data['title']} ({job_data['category']})")

        db.session.commit()
        print(f"\n成功添加 {len(jobs_data)} 个职位！")
        print("\n职位分类统计：")
        print(f"  管理类：2个职位")
        print(f"  技术人员类：6个职位")
        print(f"  保洁人员类：1个职位")

if __name__ == "__main__":
    print("=" * 60)
    print("德元升中医馆 - 职位初始化脚本")
    print("=" * 60)
    init_jobs()
    print("=" * 60)
