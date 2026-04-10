<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Loan;
use App\Models\User;
use App\Services\LoanCalculationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class LoanController extends Controller
{
    /**
     * 預覽月還款金額（供管理後台即時顯示，與儲存時計算邏輯一致）
     */
    public function previewMonthlyPayment(Request $request, int $memberId, LoanCalculationService $calculator): JsonResponse
    {
        $admin = $request->user();
        if ($admin->isShareholder()) {
            return response()->json(['message' => '股東管理者僅可檢視會員資訊，不可編輯'], 403);
        }

        $member = User::where('role', 'member')->findOrFail($memberId);

        if ($admin->isStoreManager() && $member->store_id !== $admin->store_id) {
            abort(403);
        }

        $validated = $request->validate([
            'remaining_amount' => ['nullable', 'numeric', 'min:0'],
            'loan_amount' => ['nullable', 'numeric', 'min:0'],
            'interest_rate' => ['nullable', 'numeric', 'min:0'],
            'loan_periods' => ['nullable', 'integer', 'min:0'],
            'repayment_type' => ['required', Rule::in(['interest_only', 'amortization'])],
        ]);

        $discount = (float) ($member->interest_discount_percent ?? 0);
        $stated = (float) ($validated['interest_rate'] ?? 0);
        $effective = $calculator->effectiveRatePercent($stated, $discount);

        $principal = $calculator->principalForSchedule(
            (float) ($validated['remaining_amount'] ?? 0),
            (float) ($validated['loan_amount'] ?? 0)
        );
        $periods = (int) ($validated['loan_periods'] ?? 0);
        if ($validated['repayment_type'] === 'interest_only') {
            $periods = 0;
        }

        $monthly = $calculator->calculateMonthlyPayment(
            $validated['repayment_type'],
            $principal,
            $effective,
            $periods
        );

        return response()->json([
            'monthly_payment' => (float) $monthly,
            'effective_interest_rate_percent' => $effective,
        ]);
    }

    /**
     * 新增貸款案件（股東僅可檢視，不可編輯）
     */
    public function store(Request $request, int $memberId): JsonResponse
    {
        $admin = $request->user();
        if ($admin->isShareholder()) {
            return response()->json(['message' => '股東管理者僅可檢視會員資訊，不可編輯'], 403);
        }
        $member = \App\Models\User::where('role', 'member')->findOrFail($memberId);

        if ($admin->isStoreManager() && $member->store_id !== $admin->store_id) {
            abort(403);
        }

        if (! $member->store_id) {
            return response()->json(['message' => '會員未歸屬店家'], 422);
        }

        $repaymentType = $request->input('repayment_type', 'amortization');
        if (! in_array($repaymentType, ['interest_only', 'amortization'], true)) {
            return response()->json(['message' => '還款方式必須為純繳息或本利攤'], 422);
        }

        $loan = Loan::create([
            'user_id' => $member->id,
            'store_id' => $member->store_id,
            'loan_amount' => 0,
            'remaining_amount' => 0,
            'interest_rate' => 0,
            'repayment_type' => $repaymentType,
        ]);

        return response()->json(['message' => 'ok', 'loan' => $loan->fresh()]);
    }

    /**
     * 更新貸款案件（股東僅可檢視，不可編輯）
     */
    public function update(Request $request, int $id, LoanCalculationService $calculator): JsonResponse
    {
        $admin = $request->user();
        if ($admin->isShareholder()) {
            return response()->json(['message' => '股東管理者僅可檢視會員資訊，不可編輯'], 403);
        }
        $loan = Loan::with('store')->findOrFail($id);

        if ($admin->isStoreManager() && $loan->store_id !== $admin->store_id) {
            abort(403);
        }

        $validated = $request->validate([
            'collateral_type' => ['nullable', Rule::in(['汽車', '機車', '汽車機車', '房屋', '土地', '房屋土地', '其他'])],
            'collateral_info' => ['nullable', 'string'],
            'loan_amount' => ['sometimes', 'numeric', 'min:0'],
            'remaining_amount' => ['sometimes', 'numeric', 'min:0'],
            'interest_rate' => ['nullable', 'numeric', 'min:0'],
            'repayment_day' => ['nullable', 'string', 'max:50'],
            'interest_collection' => ['nullable', 'string', 'max:50'],
            'loan_periods' => ['nullable', 'integer', 'min:0'],
            'contract_months' => ['nullable', 'integer', 'min:0'],
        ]);

        $loan->fill($validated);
        $loan->load('user');

        $discount = (float) ($loan->user?->interest_discount_percent ?? 0);
        $stated = (float) ($loan->interest_rate ?? 0);
        $effective = $calculator->effectiveRatePercent($stated, $discount);
        $principal = $calculator->principalForSchedule(
            (float) ($loan->remaining_amount ?? 0),
            (float) ($loan->loan_amount ?? 0)
        );
        $periods = $loan->repayment_type === 'amortization' ? (int) ($loan->loan_periods ?? 0) : 0;
        $monthly = $calculator->calculateMonthlyPayment(
            (string) $loan->repayment_type,
            $principal,
            $effective,
            $periods
        );
        $loan->monthly_payment = (float) $monthly;
        $loan->save();

        return response()->json(['message' => 'ok', 'loan' => $loan->fresh()]);
    }

    /**
     * 刪除貸款案件（股東僅可檢視，不可編輯）
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();
        if ($admin->isShareholder()) {
            return response()->json(['message' => '股東管理者僅可檢視會員資訊，不可編輯'], 403);
        }
        $loan = Loan::findOrFail($id);

        if ($admin->isStoreManager() && $loan->store_id !== $admin->store_id) {
            abort(403);
        }

        $loan->delete();

        return response()->json(['message' => 'ok']);
    }
}
