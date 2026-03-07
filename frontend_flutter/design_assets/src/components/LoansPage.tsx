import { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';
import { motion } from 'motion/react';
import { BottomNav } from './BottomNav';

interface LoanData {
  id: number;
  collateralType: string;
  principalAmount: number;
  remainingAmount: number;
  monthlyPayment: number;
  repaymentDay: number | string; // 可以是數字（每月X號）或字串（每X天）
  collateralInfo: {
    applicationNumber?: string;
    licensePlate?: string;
    address?: string;
    productName?: string;
  };
}

export function LoansPage() {
  const [showAll, setShowAll] = useState(false);
  const [expandedLoan, setExpandedLoan] = useState<number | null>(null);

  // 模擬資料
  const loans: LoanData[] = [
    {
      id: 1,
      collateralType: '汽車',
      principalAmount: 1234567,
      remainingAmount: 1234566,
      monthlyPayment: 92592,
      repaymentDay: 5,
      collateralInfo: {
        applicationNumber: '20260101-001',
        licensePlate: 'ABC-1234',
      },
    },
    {
      id: 2,
      collateralType: '房屋',
      principalAmount: 8500000,
      remainingAmount: 7823456,
      monthlyPayment: 45678,
      repaymentDay: '每 30 天',
      collateralInfo: {
        applicationNumber: '20260115-002',
        address: '台北市信義區信義路五段7號',
      },
    },
    {
      id: 3,
      collateralType: '機車',
      principalAmount: 150000,
      remainingAmount: 98750,
      monthlyPayment: 8500,
      repaymentDay: 15,
      collateralInfo: {
        applicationNumber: '20260201-003',
        licensePlate: 'XYZ-9876',
      },
    },
    {
      id: 4,
      collateralType: '土地',
      principalAmount: 5600000,
      remainingAmount: 5234500,
      monthlyPayment: 16345,
      repaymentDay: '每 60 天',
      collateralInfo: {
        applicationNumber: '20260210-004',
        address: '新北市板橋區中山路一段161號',
      },
    },
  ];

  const displayedLoans = showAll ? loans : loans.slice(0, 3);
  const hiddenCount = loans.length - 3;

  const formatNumber = (num: number) => {
    return num.toLocaleString('zh-TW');
  };

  const toggleExpand = (id: number) => {
    setExpandedLoan(expandedLoan === id ? null : id);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900 flex justify-center">
      <div className="w-full max-w-[393px] relative flex flex-col h-screen">
        {/* 頂部區域 */}
        <div className="bg-slate-800/50 backdrop-blur-xl border-b border-white/10 p-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-white text-xl font-bold">會員中心</h1>
              <p className="text-blue-300 text-xs">王小明的借貸資訊</p>
            </div>
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center text-white font-bold shadow-lg shadow-blue-500/30">
              王
            </div>
          </div>
        </div>

        {/* 內容區域 */}
        <div className="flex-1 overflow-y-auto pb-20 px-4 pt-4">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white/5 backdrop-blur-xl rounded-2xl border border-white/10 overflow-hidden shadow-xl"
          >
            {/* 表格 */}
            <div className="overflow-x-auto">
              <table className="w-full text-xs">
                <thead>
                  <tr className="bg-gradient-to-r from-blue-500/30 to-cyan-500/30 border-b border-white/10">
                    <th className="p-2 text-white font-semibold text-left whitespace-nowrap">筆</th>
                    <th className="p-2 text-white font-semibold text-left whitespace-nowrap">擔保品</th>
                    <th className="p-2 text-white font-semibold text-left whitespace-nowrap">借貸金額</th>
                    <th className="p-2 text-white font-semibold text-left whitespace-nowrap">月還款金額</th>
                    <th className="p-2 text-white font-semibold text-left whitespace-nowrap">還款日</th>
                  </tr>
                </thead>
                <tbody>
                  {displayedLoans.map((loan, index) => (
                    <motion.tr
                      key={loan.id}
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.05 }}
                      className="border-b border-white/5 hover:bg-white/5 transition-all"
                    >
                      <td className="p-2">
                        <span className="text-white font-bold">{loan.id}</span>
                      </td>
                      <td className="p-2">
                        <span className="text-green-300 font-medium">{loan.collateralType}</span>
                      </td>
                      <td className="p-2 text-white whitespace-nowrap">
                        <div className="space-y-1">
                          <div>
                            <div className="text-[10px] text-blue-300">本金</div>
                            <div className="font-mono">{formatNumber(loan.principalAmount)}</div>
                          </div>
                          <div>
                            <div className="text-[10px] text-blue-300">尚餘</div>
                            <div className="font-mono">{formatNumber(loan.remainingAmount)}</div>
                          </div>
                        </div>
                      </td>
                      <td className="p-2 text-white font-mono whitespace-nowrap">
                        NT:{formatNumber(loan.monthlyPayment)}
                      </td>
                      <td className="p-2 text-white whitespace-nowrap">
                        {typeof loan.repaymentDay === 'number'
                          ? `每月${loan.repaymentDay}號`
                          : loan.repaymentDay}
                      </td>
                    </motion.tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Show More Button */}
            {loans.length > 3 && (
              <div className="p-4 border-t border-white/10">
                <motion.button
                  whileTap={{ scale: 0.98 }}
                  onClick={() => setShowAll(!showAll)}
                  className="w-full bg-gradient-to-r from-red-500/80 to-red-600/80 hover:from-red-500 hover:to-red-600 text-white rounded-xl py-3 font-bold text-sm transition-all shadow-lg hover:shadow-red-500/50 flex items-center justify-center gap-2"
                >
                  {showAll ? (
                    <>
                      <ChevronUp className="w-4 h-4" />
                      <span>收合</span>
                    </>
                  ) : (
                    <>
                      <span>SHOW {loans.length} 筆</span>
                      <span className="text-red-100">其餘隱藏</span>
                      <ChevronDown className="w-4 h-4" />
                    </>
                  )}
                </motion.button>
              </div>
            )}
          </motion.div>

          {/* 統計卡片 */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="mt-4 grid grid-cols-2 gap-3"
          >
            <div className="bg-gradient-to-br from-blue-500/20 to-cyan-500/20 backdrop-blur-xl rounded-xl p-3 border border-white/10">
              <div className="text-blue-300 text-xs mb-1">總借貸筆數</div>
              <div className="text-white text-2xl font-bold">{loans.length}</div>
            </div>
            <div className="bg-gradient-to-br from-purple-500/20 to-pink-500/20 backdrop-blur-xl rounded-xl p-3 border border-white/10">
              <div className="text-blue-300 text-xs mb-1">總月繳金額</div>
              <div className="text-white text-lg font-bold font-mono">
                NT:{formatNumber(loans.reduce((sum, loan) => sum + loan.monthlyPayment, 0))}
              </div>
            </div>
          </motion.div>
        </div>

        {/* 底部導航欄 */}
        <BottomNav />
      </div>
    </div>
  );
}