"""
初始化德元升中医馆数据脚本
运行此脚本将创建德元升中医馆的职位数据
"""
import sys
import os

# 添加父目录到路径
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import app, db
from models.models import Job, User
from werkzeug.security import generate_password_hash

def init_demo_data():
    """初始化德元升中医馆数据"""
    with app.app_context():
        # 创建数据库表
        db.create_all()
        
        # 创建管理员账号
        admin = User.query.filter_by(username='admin').first()
        if not admin:
            admin = User(
                username='admin',
                email='646214256@qq.com',
                password=generate_password_hash('admin123'),
                role='admin'
            )
            db.session.add(admin)
            db.session.commit()
            print('[OK] 创建管理员账号: admin/admin123')
        else:
            print('[OK] 管理员账号已存在')
        
        # 检查是否已有职位数据
        if Job.query.count() > 0:
            print('[OK] 职位数据已存在，跳过创建')
            return
        
        # 创建德元升中医馆职位
        tcm_jobs = [
            {
                'title': '馆长',
                'department': '管理层',
                'location': '隆回县桃花坪街道大桥路50号',
                'job_type': 'full-time',
                'salary_range': '10000-15000',
                'description': '全面负责德元升中医馆的运营管理工作，带领团队传承和发扬中医文化。',
                'requirements': '''1. 年龄：30-50岁
2. 学历：大专及以上学历
3. 专业要求：中医学、中药学或医药管理相关专业
4. 具有5年以上中医馆或医疗机构管理经验
5. 熟悉中医诊疗流程和相关法律法规
6. 具有优秀的团队管理和沟通协调能力
7. 认同中医文化，热爱中医事业''',
                'responsibilities': '''1. 全面负责中医馆的日常运营管理工作
2. 制定和实施中医馆发展战略和经营计划
3. 组织和协调各部门工作，提升服务质量
4. 负责团队建设和人才培养
5. 维护客户关系，拓展业务渠道
6. 确保医疗安全和合规经营
7. 弘扬中医文化，推广中医养生理念''',
                'status': 'active',
                'created_by': admin.id
            },
            {
                'title': '副馆长',
                'department': '管理层',
                'location': '隆回县桃花坪街道大桥路50号',
                'job_type': 'full-time',
                'salary_range': '8000-12000',
                'description': '协助馆长管理中医馆日常运营，负责具体业务板块的管理工作。',
                'requirements': '''1. 年龄：28-45岁
2. 学历：大专及以上学历
3. 专业要求：中医学、中药学或医药管理相关专业
4. 具有3年以上中医馆或医疗机构管理经验
5. 熟悉中医诊疗业务和管理流程
6. 具有良好的组织协调和执行能力
7. 认同中医文化，愿意长期发展''',
                'responsibilities': '''1. 协助馆长制定和执行运营计划
2. 负责分管部门的日常管理工作
3. 监督和指导医疗服务质量
4. 协调处理客户投诉和问题
5. 组织开展中医健康讲座和活动
6. 完成馆长交办的其他工作任务''',
                'status': 'active',
                'created_by': admin.id
            },
            {
                'title': '中医执业医师',
                'department': '医疗部',
                'location': '隆回县桃花坪街道大桥路50号',
                'job_type': 'full-time',
                'salary_range': '8000-20000',
                'description': '运用中医理论和技术为患者提供专业的诊疗服务，传承和发扬中医药文化。',
                'requirements': '''1. 年龄：25-55岁
2. 学历：本科及以上学历，中医学或中西医结合专业
3. 资质：持有中医执业医师资格证书
4. 具有扎实的中医理论基础和临床经验
5. 熟练掌握中医诊断方法和治疗技术
6. 具有良好的医德医风和服务意识
7. 具有团队合作精神，愿意长期发展''',
                'responsibilities': '''1. 运用中医望闻问切为患者诊断病情
2. 根据患者情况制定个性化治疗方案
3. 开具中药处方，指导患者用药
4. 开展针灸、推拿等中医特色治疗
5. 做好医疗文书记录和病历管理
6. 参与中医健康宣教和义诊活动
7. 不断学习提升中医诊疗水平''',
                'status': 'active',
                'created_by': admin.id
            },
            {
                'title': '药剂师',
                'department': '药房',
                'location': '隆回县桃花坪街道大桥路50号',
                'job_type': 'full-time',
                'salary_range': '4500-8000',
                'description': '负责中药调剂、药品管理和用药指导工作，确保患者用药安全有效。',
                'requirements': '''1. 年龄：22-50岁
2. 学历：大专及以上学历，中药学或药学专业
3. 资质：持有药师资格证书
4. 熟悉常用中药材的性味归经和功效
5. 掌握中药调剂、炮制等专业技能
6. 具有良好的服务意识和责任心
7. 工作细心认真，有团队合作精神''',
                'responsibilities': '''1. 按照处方准确调配中药饮片
2. 负责中药材的验收、储存和养护
3. 指导患者正确煎煮和服用中药
4. 做好药品的进销存管理
5. 确保药品质量和用药安全
6. 参与中药知识宣教工作
7. 完成药房日常管理工作''',
                'status': 'active',
                'created_by': admin.id
            },
            {
                'title': '理疗师',
                'department': '康复理疗部',
                'location': '隆回县桃花坪街道大桥路50号',
                'job_type': 'full-time',
                'salary_range': '4000-8000',
                'description': '运用中医传统疗法和现代理疗技术为患者提供康复治疗服务。',
                'requirements': '''1. 年龄：22-45岁
2. 学历：中专及以上学历，中医、康复或针推专业
3. 资质：持有相关职业资格证书优先
4. 掌握针灸、推拿、拔罐、艾灸等技术
5. 熟悉人体经络穴位和常见病理疗方法
6. 具有良好的服务意识和沟通能力
7. 工作耐心细致，有责任心''',
                'responsibilities': '''1. 根据患者情况制定理疗方案
2. 开展针灸、推拿、拔罐等中医理疗
3. 操作各类理疗设备为患者治疗
4. 指导患者进行康复锻炼
5. 做好理疗记录和设备维护
6. 向患者普及中医养生知识
7. 维护良好的客户关系''',
                'status': 'active',
                'created_by': admin.id
            },
            {
                'title': '健康顾问/售后人员',
                'department': '客服部',
                'location': '隆回县桃花坪街道大桥路50号',
                'job_type': 'full-time',
                'salary_range': '3000-10000',
                'description': '为客户提供专业的中医健康咨询和贴心的售后服务，传播中医养生文化。',
                'requirements': '''1. 年龄：20-40岁
2. 学历：高中及以上学历
3. 对中医养生有浓厚兴趣，愿意学习中医知识
4. 具有良好的沟通表达和服务意识
5. 形象气质佳，亲和力强
6. 有客服或销售经验者优先
7. 积极主动，责任心强，能承受工作压力''',
                'responsibilities': '''1. 接待来访客户，提供咨询服务
2. 了解客户需求，介绍中医养生方案
3. 跟进客户治疗效果，做好回访工作
4. 处理客户反馈和投诉，提升满意度
5. 维护客户关系，开发潜在客户
6. 学习中医养生知识，提升专业能力
7. 完成部门安排的其他工作任务''',
                'status': 'active',
                'created_by': admin.id
            },
            {
                'title': '综合专员',
                'department': '综合办公室',
                'location': '隆回县桃花坪街道大桥路50号',
                'job_type': 'full-time',
                'salary_range': '3000-5000',
                'description': '负责中医馆的行政、人事、财务等综合管理工作，为业务部门提供支持。',
                'requirements': '''1. 年龄：22-40岁
2. 学历：大专及以上学历，行政管理或相关专业
3. 熟练使用办公软件（Word、Excel、PPT等）
4. 具有良好的文字表达和组织协调能力
5. 工作细心认真，执行力强
6. 有行政、人事或财务工作经验者优先
7. 有团队合作精神和服务意识''',
                'responsibilities': '''1. 负责日常行政事务管理
2. 协助处理人事招聘、考勤等工作
3. 协助完成财务报销和账务记录
4. 管理办公用品和固定资产
5. 组织安排会议和各类活动
6. 做好档案管理和文件归档
7. 完成领导交办的其他工作''',
                'status': 'active',
                'created_by': admin.id
            },
            {
                'title': '网络/社区运营专员',
                'department': '市场部',
                'location': '隆回县桃花坪街道大桥路50号',
                'job_type': 'full-time',
                'salary_range': '3000-8000',
                'description': '负责中医馆的线上推广和社区运营，传播中医文化，拓展客户资源。',
                'requirements': '''1. 年龄：20-35岁
2. 学历：大专及以上学历，市场营销或相关专业
3. 熟悉微信、抖音等新媒体平台运营
4. 具有较强的文案策划和内容创作能力
5. 了解网络推广和社群营销方法
6. 对中医养生文化有兴趣，愿意学习
7. 思维活跃，执行力强，有团队精神''',
                'responsibilities': '''1. 运营管理微信公众号、抖音等平台
2. 策划和发布中医养生科普内容
3. 开展线上推广活动，吸引潜在客户
4. 建设和维护客户社群，提升活跃度
5. 收集和分析运营数据，优化推广策略
6. 协助开展线下活动和义诊宣传
7. 塑造和传播德元升品牌形象''',
                'status': 'active',
                'created_by': admin.id
            },
            {
                'title': '前台接待',
                'department': '客服部',
                'location': '隆回县桃花坪街道大桥路50号',
                'job_type': 'full-time',
                'salary_range': '2800-4000',
                'description': '负责前台接待、预约登记等工作，为客户提供优质的服务体验。',
                'requirements': '''1. 年龄：20-35岁
2. 学历：高中及以上学历
3. 形象气质佳，普通话标准
4. 具有良好的沟通能力和服务意识
5. 熟练使用电脑和办公软件
6. 工作认真负责，耐心细致
7. 有前台接待或客服经验者优先''',
                'responsibilities': '''1. 热情接待来访客户，提供咨询服务
2. 负责客户预约登记和信息录入
3. 引导客户就诊，维护就诊秩序
4. 接听电话，解答客户咨询
5. 保持前台区域整洁有序
6. 协助处理客户反馈和投诉
7. 完成上级安排的其他工作''',
                'status': 'active',
                'created_by': admin.id
            },
            {
                'title': '保洁人员',
                'department': '后勤部',
                'location': '隆回县桃花坪街道大桥路50号',
                'job_type': 'full-time',
                'salary_range': '2500-3500',
                'description': '负责中医馆环境卫生清洁工作，为客户提供整洁舒适的就诊环境。',
                'requirements': '''1. 年龄：25-55岁
2. 学历：不限
3. 身体健康，吃苦耐劳
4. 有保洁工作经验者优先
5. 工作认真负责，注重细节
6. 服从管理，有团队合作精神
7. 能够熟练使用各类清洁工具''',
                'responsibilities': '''1. 负责诊室、走廊、卫生间等区域清洁
2. 定期消毒，保持环境卫生
3. 清理垃圾，维护环境整洁
4. 爱护和保养清洁工具设备
5. 发现设施损坏及时报修
6. 遵守医疗卫生规范
7. 完成上级安排的其他清洁任务''',
                'status': 'active',
                'created_by': admin.id
            }
        ]
        
        for job_data in tcm_jobs:
            job = Job(**job_data)
            db.session.add(job)
        
        db.session.commit()
        print(f'[OK] 成功创建 {len(tcm_jobs)} 个德元升中医馆职位')
        
        print('\n' + '='*50)
        print('德元升中医馆招聘系统初始化完成！')
        print('='*50)
        print('\n弘扬中医文化、让每个家庭都有一个懂中医的人')
        print('\n联系方式：')
        print('邮箱：646214256@qq.com')
        print('电话：17775662859（刘）')
        print('地址：隆回县桃花坪街道大桥路50号')
        print('    （原隆回县药材公司大院内）')
        print('\n系统访问：')
        print('1. 启动后端服务: python backend/app.py')
        print('2. 招聘页面: http://localhost:5000/')
        print('3. 管理后台: http://localhost:5000/admin')
        print(f'\n管理员账号: admin / admin123')
        print('='*50)

if __name__ == '__main__':
    init_demo_data()
