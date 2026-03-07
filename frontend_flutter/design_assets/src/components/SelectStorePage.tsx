import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Store, Check, ArrowRight, MapPin } from 'lucide-react';
import { motion } from 'motion/react';

export function SelectStorePage() {
  const navigate = useNavigate();
  const [selectedStore, setSelectedStore] = useState<string | null>(null);

  const stores = [
    {
      id: 'A',
      name: 'A店家',
      location: '台北市信義區',
      color: 'from-blue-500 to-blue-600',
      description: '總部旗艦店',
    },
    {
      id: 'B',
      name: 'B店家',
      location: '台北市大安區',
      color: 'from-cyan-500 to-cyan-600',
      description: '大安分店',
    },
    {
      id: 'C',
      name: 'C店家',
      location: '新北市板橋區',
      color: 'from-teal-500 to-teal-600',
      description: '板橋分店',
    },
    {
      id: 'D',
      name: 'D店家',
      location: '台中市西屯區',
      color: 'from-sky-500 to-sky-600',
      description: '台中分店',
    },
  ];

  const handleContinue = () => {
    if (selectedStore) {
      navigate('/home');
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900 flex items-center justify-center p-4">
      {/* 背景裝飾元素 */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-20 left-10 w-40 h-40 bg-blue-500 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-pulse"></div>
        <div className="absolute bottom-20 right-10 w-40 h-40 bg-cyan-500 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-pulse delay-1000"></div>
      </div>

      {/* 選擇店家卡片 */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="relative w-full max-w-[393px]"
      >
        {/* Logo 區域 */}
        <div className="text-center mb-8">
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ delay: 0.2, type: "spring", stiffness: 200 }}
            className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-br from-blue-500 to-cyan-500 mb-4 shadow-lg shadow-blue-500/50"
          >
            <Store className="w-8 h-8 text-white" />
          </motion.div>
          <h1 className="text-3xl font-bold text-white mb-2">選擇管理店家</h1>
          <p className="text-blue-200 text-sm">請選擇您所屬的店家</p>
        </div>

        {/* 店家選擇卡片 */}
        <div className="bg-white/10 backdrop-blur-xl rounded-3xl p-6 shadow-2xl border border-white/20">
          <div className="space-y-3 mb-6">
            {stores.map((store, index) => (
              <motion.div
                key={store.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.1 }}
                onClick={() => setSelectedStore(store.id)}
                className={`relative p-4 rounded-xl cursor-pointer transition-all border-2 ${
                  selectedStore === store.id
                    ? 'border-cyan-400 bg-white/10'
                    : 'border-white/10 bg-white/5 hover:bg-white/10'
                }`}
              >
                <div className="flex items-center gap-3">
                  {/* 店家圖標 */}
                  <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${store.color} flex items-center justify-center shadow-lg flex-shrink-0`}>
                    <Store className="w-6 h-6 text-white" />
                  </div>

                  {/* 店家資訊 */}
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <h3 className="text-white font-semibold">{store.name}</h3>
                      <span className="text-xs bg-blue-500/20 text-blue-300 px-2 py-0.5 rounded-full border border-blue-500/30">
                        {store.id}
                      </span>
                    </div>
                    <p className="text-blue-200 text-xs mt-1">{store.description}</p>
                    <div className="flex items-center gap-1 text-blue-300 text-xs mt-1">
                      <MapPin className="w-3 h-3" />
                      <span>{store.location}</span>
                    </div>
                  </div>

                  {/* 選中標記 */}
                  {selectedStore === store.id && (
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      className="flex-shrink-0 w-6 h-6 rounded-full bg-gradient-to-br from-cyan-400 to-cyan-500 flex items-center justify-center"
                    >
                      <Check className="w-4 h-4 text-white" />
                    </motion.div>
                  )}
                </div>
              </motion.div>
            ))}
          </div>

          {/* 繼續按鈕 */}
          <motion.button
            whileHover={{ scale: selectedStore ? 1.02 : 1 }}
            whileTap={{ scale: selectedStore ? 0.98 : 1 }}
            onClick={handleContinue}
            disabled={!selectedStore}
            className={`w-full rounded-xl py-3 font-semibold flex items-center justify-center gap-2 transition-all ${
              selectedStore
                ? 'bg-gradient-to-r from-blue-500 to-cyan-500 text-white hover:shadow-lg hover:shadow-blue-500/50'
                : 'bg-white/5 text-blue-300 cursor-not-allowed'
            }`}
          >
            {selectedStore ? '完成設定' : '請選擇店家'}
            {selectedStore && <ArrowRight className="w-5 h-5" />}
          </motion.button>

          {/* 提示文字 */}
          <p className="text-center text-blue-300 text-xs mt-4">
            選擇後，您將由該店家進行管理
          </p>
        </div>

        {/* 已選擇提示 */}
        {selectedStore && (
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="mt-4 text-center"
          >
            <p className="text-cyan-400 text-sm">
              ✓ 已選擇 {stores.find(s => s.id === selectedStore)?.name}
            </p>
          </motion.div>
        )}
      </motion.div>
    </div>
  );
}