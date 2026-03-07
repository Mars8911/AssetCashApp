<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Loan;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index()
    {
        // 1. 抓取統計數據
        $totalLoanAmount = \App\Models\Loan::sum('loan_amount');
        $totalRemaining = \App\Models\Loan::sum('remaining_amount');

        // 2. 抓取具體的案件清單 (包含關聯的 store 名稱)
        $loans = \App\Models\Loan::with('store')->get();

        return response()->json([
            'status' => 'success',
            'data' => [
                'summary' => [
                    'total_cases' => $loans->count(),
                    'total_loan_amount' => (float)$totalLoanAmount,
                    'total_remaining' => (float)$totalRemaining,
                ],
                // 把真實的貸款清單也噴出去
                'loans' => $loans
            ]
        ]);
    }
}
