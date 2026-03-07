import { useState } from 'react';
import { Store, DollarSign, TrendingUp, Calendar } from 'lucide-react';
import { motion } from 'motion/react';
import { BottomNav } from './BottomNav';

export function HomePage() {
  const [selectedStore] = useState('A店家');
  const [activeCategory, setActiveCategory] = useState('movable');

  // 模擬還款資料 - 根據分類
  const paymentData = {
    movable: {
      totalAmount: 1384567,
      paidAmount: 1,
      monthlyPayment: 101092,
      remainingMonths: 21,
      notifications: [
        {
          id: 1,
          title: '汽車貸款繳款提醒',
          content: '車牌 ABC-1234 本月還款日為 3/5，應繳 NT$92,592',
          date: '2026-03-01',
          type: 'reminder',
        },
        {
          id: 2,
          title: '機車貸款付款成功',
          content: '車牌 XYZ-9876 已成功繳納 2 月份款項 NT$8,500',
          date: '2026-02-15',
          type: 'success',
        },
      ],
    },
    immovable: {
      totalAmount: 14100000,
      paidAmount: 676544,
      monthlyPayment: 62023,
      remainingMonths: 180,
      notifications: [
        {
          id: 3,
          title: '房屋貸款繳款提醒',
          content: '信義區房產本月還款日為 3/10，應繳 NT$45,678',
          date: '2026-03-01',
          type: 'reminder',
        },
        {
          id: 4,
          title: '土地貸款利率調整通知',
          content: '板橋區土地貸款利率調整為 3.2%',
          date: '2026-02-20',
          type: 'info',
        },
      ],
    },
    others: {
      totalAmount: 0,
      paidAmount: 0,
      monthlyPayment: 0,
      remainingMonths: 0,
      notifications: [],
    },
  };

  const categories = [
    { id: 'movable', label: '動保' },
    { id: 'immovable', label: '不動產' },
    { id: 'others', label: '其他' },
  ];

  const currentData = paymentData[activeCategory as keyof typeof paymentData];

  const calculateProgress = () => {
    return (currentData.paidAmount / currentData.totalAmount) * 100;
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900 flex justify-center">
      <div className="w-full max-w-[393px] relative flex flex-col h-screen">
        {/* 頂部區域 */}
        <div className="bg-gradient-to-r from-slate-800 to-slate-900 border-b border-white/10 p-4 pb-3">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center shadow-lg shadow-blue-500/30">
                <Store className="w-5 h-5 text-white" />
              </div>
              <div>
                <h1 className="text-white font-bold">會員中心</h1>
                <p className="text-blue-300 text-xs">{selectedStore}</p>
              </div>
            </div>
            <div className="bg-blue-500/20 px-3 py-1.5 rounded-lg border border-blue-500/30">
              <span className="text-xs text-blue-300">一般會員</span>
            </div>
          </div>
        </div>

        {/* 內容區域 */}
        <div className="flex-1 overflow-y-auto pb-20 px-4 pt-4">
          {/* 還款資訊卡片 */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-gradient-to-br from-blue-500/20 to-cyan-500/20 backdrop-blur-xl rounded-2xl p-4 border border-white/20 mb-4 shadow-xl"
          >
            <h2 className="text-white font-semibold mb-4 flex items-center gap-2">
              <DollarSign className="w-5 h-5" />
              還款資訊
            </h2>

            {/* 還款總額 */}
            <div className="mb-4">
              <p className="text-blue-200 text-sm mb-1">還款總額</p>
              <p className="text-white text-3xl font-bold">
                ${currentData.totalAmount.toLocaleString()}
              </p>
            </div>

            {/* 度條 */}
            <div className="mb-4">
              <div className="flex justify-between text-xs text-blue-200 mb-2">
                <span>已還款進度</span>
                <span>{calculateProgress().toFixed(1)}%</span>
              </div>
              <div className="w-full h-3 bg-white/10 rounded-full overflow-hidden">
                <motion.div
                  initial={{ width: 0 }}
                  animate={{ width: `${calculateProgress()}%` }}
                  transition={{ duration: 1, delay: 0.3 }}
                  className="h-full bg-gradient-to-r from-blue-500 to-cyan-500 rounded-full"
                />
              </div>
            </div>

            {/* 已還款金額和每月應還款 */}
            <div className="grid grid-cols-2 gap-3">
              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-3">
                <p className="text-blue-200 text-xs mb-1">已還款金額</p>
                <p className="text-white text-xl font-bold">
                  ${currentData.paidAmount.toLocaleString()}
                </p>
              </div>
              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-3">
                <p className="text-blue-200 text-xs mb-1">每月應還款</p>
                <p className="text-white text-xl font-bold">
                  ${currentData.monthlyPayment.toLocaleString()}
                </p>
              </div>
            </div>
          </motion.div>

          {/* 首頁訊息 */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
          >
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-white font-semibold">首頁訊息</h3>
              
              {/* 分類標籤 */}
              <div className="flex gap-1.5">
                {categories.map((category) => (
                  <motion.button
                    key={category.id}
                    whileTap={{ scale: 0.95 }}
                    onClick={() => setActiveCategory(category.id)}
                    className={`px-3 py-1 rounded-lg text-xs font-medium transition-all ${
                      activeCategory === category.id
                        ? 'bg-gradient-to-r from-blue-500 to-cyan-500 text-white shadow-md shadow-blue-500/30'
                        : 'bg-white/10 text-blue-300 border border-white/10 hover:bg-white/20'
                    }`}
                  >
                    {category.label}
                  </motion.button>
                ))}
              </div>
            </div>
            
            <div className="space-y-3">
              {currentData.notifications.length === 0 ? (
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="bg-white/5 backdrop-blur-xl rounded-xl p-8 border border-white/10 flex flex-col items-center justify-center"
                >
                  <div className="w-20 h-20 rounded-full bg-white/5 flex items-center justify-center mb-4">
                    <DollarSign className="w-10 h-10 text-blue-300/50" />
                  </div>
                  <h4 className="text-white font-medium mb-2">目前無資料</h4>
                  <p className="text-blue-300 text-xs text-center">此分類下暫無相關貸款資訊</p>
                </motion.div>
              ) : (
                currentData.notifications.map((item, index) => (
                  <motion.div
                    key={item.id}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.3 + index * 0.05 }}
                    className="bg-white/5 backdrop-blur-xl rounded-xl p-4 border border-white/10 hover:bg-white/10 transition-all cursor-pointer"
                  >
                    <div className="flex items-start gap-3">
                      <div className={`w-2 h-2 rounded-full mt-2 flex-shrink-0 ${
                        item.type === 'reminder' ? 'bg-orange-400' :
                        item.type === 'success' ? 'bg-green-400' :
                        'bg-blue-400'
                      }`} />
                      <div className="flex-1">
                        <h4 className="text-white font-medium text-sm mb-1">{item.title}</h4>
                        <p className="text-blue-200 text-xs mb-2">{item.content}</p>
                        <p className="text-blue-300 text-xs">{item.date}</p>
                      </div>
                    </div>
                  </motion.div>
                ))
              )}
            </div>
          </motion.div>
        </div>

        {/* 底部導航欄 */}
        <BottomNav />
      </div>
    </div>
  );
}