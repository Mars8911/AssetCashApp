import { useState } from 'react';
import { Bell, ChevronRight, X, Check, Calendar, Info } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { BottomNav } from './BottomNav';

interface Notification {
  id: number;
  subject: string;
  description: string;
  validPeriod: string;
  category: string;
  icon: string;
  isRead: boolean;
  detailContent: string;
  relatedInfo?: string[];
}

export function NotificationsPage() {
  const [activeTab, setActiveTab] = useState('all');
  const [selectedNotif, setSelectedNotif] = useState<Notification | null>(null);
  const [notifications, setNotifications] = useState<Notification[]>([
    {
      id: 1,
      subject: '繳款提醒',
      description: '您本月的還款日為 2026/03/05，請準時繳款以避免產生額外費用',
      validPeriod: '2026/03/01 - 2026/03/05',
      category: 'payment',
      icon: '💳',
      isRead: false,
      detailContent: '親愛的王小明會員，您好！本月應繳金額為 NT$172,615，繳款日期為每月 5 日。為確保您的還款紀錄良好，請於期限內完成繳款。您可透過網路銀行轉帳、ATM 轉帳或至指定店家繳款。',
      relatedInfo: [
        '應繳總額：NT$172,615',
        '繳款日期：2026/03/05',
        '逾期將產生滯納金',
        '可使用多種繳款方式',
      ],
    },
    {
      id: 2,
      subject: '付款成功通知',
      description: '您於 2026/02/20 的繳款已成功處理，感謝您的準時繳款',
      validPeriod: '2026/02/20',
      category: 'success',
      icon: '✅',
      isRead: false,
      detailContent: '感謝您準時完成繳款！您於 2026/02/20 15:30 透過網路銀行轉帳繳款 NT$172,615 已成功入帳。您的還款紀錄良好，將有助於日後申請更優惠的利率方案。',
      relatedInfo: [
        '繳款金額：NT$172,615',
        '繳款時間：2026/02/20 15:30',
        '繳款方式：網路銀行轉帳',
        '交易編號：TXN20260220153045',
      ],
    },
    {
      id: 3,
      subject: '店家公告',
      description: 'A店家將於 2026/03/10-12 進行系統維護，部分服務暫停',
      validPeriod: '2026/03/10 - 2026/03/12',
      category: 'announcement',
      icon: '📢',
      isRead: true,
      detailContent: 'A店家預定於 2026 年 3 月 10 日至 12 日進行系統升級維護作業。維護期間，線上繳款功能將暫停服務，建議您提前安排繳款事宜或選擇其他繳款管道。造成不便，敬請見諒。',
      relatedInfo: [
        '維護時間：2026/03/10 00:00 - 03/12 23:59',
        '影響範圍：線上繳款系統',
        '替代方案：ATM 轉帳、臨櫃繳款',
        '客服專線：0800-123-456',
      ],
    },
    {
      id: 4,
      subject: '活動訊息',
      description: '新春特惠活動開跑！3月份準時繳款享 500 元現金回饋',
      validPeriod: '2026/03/01 - 2026/03/31',
      category: 'activity',
      icon: '🎉',
      isRead: false,
      detailContent: '為感謝會員長期支持，A店家推出新春特惠活動！凡於 2026 年 3 月份準時完成繳款的會員，即可獲得 NT$500 現金回饋，回饋金將於次月自動抵扣應繳金額。名額有限，把握機會！',
      relatedInfo: [
        '活動期間：2026/03/01 - 03/31',
        '回饋金額：NT$500',
        '發放方式：次月自動抵扣',
        '參加條件：準時完成 3 月份繳款',
      ],
    },
    {
      id: 5,
      subject: '優質會員制度',
      description: '恭喜！您已符合優質會員資格，享有專屬優惠與服務',
      validPeriod: '長期有效',
      category: 'membership',
      icon: '👑',
      isRead: true,
      detailContent: '親愛的王小明會員，感謝您長期保持良好的還款紀錄！您已符合優質會員資格，現在起可享有利率優惠、優先審核、專屬客服等多項專屬權益。優質會員資格將持續有效，只要您維持良好還款紀錄。',
      relatedInfo: [
        '利率優惠：降低 0.5% - 1%',
        '優先審核：新申請案件優先處理',
        '專屬客服：VIP 客服專線',
        '生日禮遇：生日當月特別優惠',
      ],
    },
  ]);

  const tabs = [
    { id: 'all', label: '全部通知' },
    { id: 'payment', label: '繳款提醒' },
    { id: 'announcement', label: '公告訊息' },
    { id: 'activity', label: '活動優惠' },
  ];

  const filteredNotifications = activeTab === 'all' 
    ? notifications 
    : notifications.filter(n => n.category === activeTab);

  const unreadCount = notifications.filter(n => !n.isRead).length;

  const markAsRead = (id: number) => {
    setNotifications(notifications.map(n => 
      n.id === id ? { ...n, isRead: true } : n
    ));
  };

  const handleNotificationClick = (notif: Notification) => {
    setSelectedNotif(notif);
    markAsRead(notif.id);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900 flex justify-center">
      <div className="w-full max-w-[393px] relative flex flex-col h-screen">
        {/* 頂部區域 */}
        <div className="bg-slate-800/50 backdrop-blur-xl border-b border-white/10 p-4 pb-3">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h1 className="text-white text-xl font-bold">推播通知</h1>
              <p className="text-blue-300 text-xs">
                {unreadCount > 0 ? `您有 ${unreadCount} 則未讀通知` : '所有通知已讀'}
              </p>
            </div>
            <div className="relative">
              <div className="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center shadow-lg shadow-blue-500/30">
                <Bell className="w-5 h-5 text-white" />
              </div>
              {unreadCount > 0 && (
                <div className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 rounded-full flex items-center justify-center border-2 border-slate-900">
                  <span className="text-white text-xs font-bold">{unreadCount}</span>
                </div>
              )}
            </div>
          </div>

          {/* 分類標籤 */}
          <div className="flex gap-2 overflow-x-auto pb-1">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`px-3 py-1.5 rounded-lg text-xs font-medium whitespace-nowrap transition-all ${
                  activeTab === tab.id
                    ? 'bg-blue-500/20 text-blue-300 border border-blue-500/30'
                    : 'bg-white/5 text-blue-300 border border-white/10'
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>
        </div>

        {/* 通知列表 */}
        <div className="flex-1 overflow-y-auto pb-20 px-4 pt-4">
          <div className="space-y-3">
            {filteredNotifications.map((notif, index) => (
              <motion.div
                key={notif.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.05 }}
                className={`backdrop-blur-xl rounded-2xl p-4 border transition-all cursor-pointer ${
                  notif.isRead
                    ? 'bg-white/5 border-white/10 hover:bg-white/10'
                    : 'bg-blue-500/10 border-blue-500/30 hover:bg-blue-500/15'
                }`}
                onClick={() => handleNotificationClick(notif)}
              >
                <div className="flex items-start gap-4">
                  {/* 圖示 */}
                  <div className="relative">
                    <div className={`w-14 h-14 rounded-xl flex items-center justify-center text-3xl flex-shrink-0 border ${
                      notif.isRead
                        ? 'bg-white/5 border-white/10'
                        : 'bg-gradient-to-br from-blue-500/20 to-cyan-500/20 border-blue-500/30'
                    }`}>
                      {notif.icon}
                    </div>
                    {!notif.isRead && (
                      <div className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full border-2 border-slate-900"></div>
                    )}
                  </div>

                  {/* 內容 */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between mb-2">
                      <h3 className={`font-semibold ${notif.isRead ? 'text-white' : 'text-white'}`}>
                        {notif.subject}
                      </h3>
                      <ChevronRight className="w-5 h-5 text-blue-300 flex-shrink-0 ml-2" />
                    </div>
                    <p className={`text-xs mb-3 ${notif.isRead ? 'text-blue-200' : 'text-blue-100'}`}>
                      {notif.description}
                    </p>
                    
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <Calendar className="w-3 h-3 text-blue-300" />
                        <span className="text-blue-300 text-xs">{notif.validPeriod}</span>
                      </div>
                      {!notif.isRead && (
                        <div className="bg-red-500/20 border border-red-500/50 px-2 py-0.5 rounded-full">
                          <span className="text-red-300 text-xs font-medium">未讀</span>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>

          {filteredNotifications.length === 0 && (
            <div className="flex flex-col items-center justify-center py-12">
              <div className="w-20 h-20 rounded-full bg-white/5 flex items-center justify-center mb-4">
                <Bell className="w-10 h-10 text-blue-300/50" />
              </div>
              <p className="text-blue-300 text-sm">目前沒有通知</p>
            </div>
          )}

          {/* 說明 */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="mt-6 bg-white/5 backdrop-blur-xl rounded-xl p-4 border border-white/10"
          >
            <h4 className="text-white font-semibold text-sm mb-2">通知說明</h4>
            <ul className="text-blue-200 text-xs space-y-1">
              <li>• 重要通知會以紅點標示</li>
              <li>• 點擊通知可查看詳細內容</li>
              <li>• 通知保留時間為 30 天</li>
            </ul>
          </motion.div>
        </div>

        {/* 底部導航欄 */}
        <BottomNav />

        {/* 通知詳情模態框 */}
        <AnimatePresence>
          {selectedNotif && (
            <>
              {/* 背景遮罩 */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                onClick={() => setSelectedNotif(null)}
                className="fixed inset-0 bg-black/70 z-50 backdrop-blur-sm"
              />
              
              {/* 詳情卡片 */}
              <motion.div
                initial={{ opacity: 0, scale: 0.9, y: 20 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.9, y: 20 }}
                className="fixed inset-x-4 top-1/2 -translate-y-1/2 z-50 max-w-[393px] mx-auto"
              >
                <div className="bg-gradient-to-br from-slate-800 to-slate-900 rounded-3xl border border-white/20 shadow-2xl max-h-[80vh] overflow-hidden flex flex-col">
                  {/* 頭部 */}
                  <div className="bg-gradient-to-r from-blue-500 to-cyan-500 p-6 relative">
                    <button
                      onClick={() => setSelectedNotif(null)}
                      className="absolute top-4 right-4 w-8 h-8 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center hover:bg-white/30 transition-all"
                    >
                      <X className="w-5 h-5 text-white" />
                    </button>
                    
                    <div className="text-5xl mb-3">{selectedNotif.icon}</div>
                    <h2 className="text-white text-2xl font-bold mb-2">{selectedNotif.subject}</h2>
                    <div className="flex items-center gap-2">
                      <Calendar className="w-4 h-4 text-blue-100" />
                      <span className="text-blue-100 text-sm">{selectedNotif.validPeriod}</span>
                    </div>
                  </div>

                  {/* 內容 */}
                  <div className="flex-1 overflow-y-auto p-6">
                    {/* 通知內容 */}
                    <div className="mb-6">
                      <div className="flex items-center gap-2 mb-3">
                        <Info className="w-5 h-5 text-blue-400" />
                        <h3 className="text-white font-semibold">通知內容</h3>
                      </div>
                      <p className="text-blue-200 text-sm leading-relaxed">
                        {selectedNotif.detailContent}
                      </p>
                    </div>

                    {/* 相關資訊 */}
                    {selectedNotif.relatedInfo && (
                      <div className="mb-6">
                        <h3 className="text-white font-semibold mb-3">相關資訊</h3>
                        <div className="bg-white/5 rounded-xl p-4 border border-white/10">
                          <ul className="space-y-2">
                            {selectedNotif.relatedInfo.map((info, index) => (
                              <li key={index} className="text-blue-200 text-sm flex items-start gap-2">
                                <span className="text-cyan-400 mt-1">•</span>
                                <span>{info}</span>
                              </li>
                            ))}
                          </ul>
                        </div>
                      </div>
                    )}

                    {/* 狀態標記 */}
                    <div className="flex items-center gap-2">
                      <div className={`flex items-center gap-2 px-3 py-1.5 rounded-lg ${
                        selectedNotif.isRead 
                          ? 'bg-green-500/20 border border-green-500/30' 
                          : 'bg-blue-500/20 border border-blue-500/30'
                      }`}>
                        <Check className={`w-4 h-4 ${selectedNotif.isRead ? 'text-green-400' : 'text-blue-400'}`} />
                        <span className={`text-sm font-medium ${selectedNotif.isRead ? 'text-green-300' : 'text-blue-300'}`}>
                          {selectedNotif.isRead ? '已讀' : '標記為已讀'}
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* 底部按鈕 */}
                  <div className="p-6 pt-0">
                    <motion.button
                      whileTap={{ scale: 0.98 }}
                      onClick={() => setSelectedNotif(null)}
                      className="w-full bg-gradient-to-r from-blue-500 to-cyan-500 text-white rounded-xl py-3 font-semibold hover:shadow-lg hover:shadow-blue-500/50 transition-all"
                    >
                      確認
                    </motion.button>
                  </div>
                </div>
              </motion.div>
            </>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
