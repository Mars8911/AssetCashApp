<?php

namespace App\Services;

use Carbon\Carbon;

/**
 * 貸款利息計算核心服務
 *
 * 支援兩種還款方式：
 *   - interest_only (A 純繳息)：每期只繳利息，本金不變
 *   - amortization  (B 本利攤)：等額本息，每期固定還款
 *
 * 利息收取時機：
 *   - 前扣 N 個月：放款時預先扣除 N 期還款，borrower 實收金額較少
 *   - 後收：每期到期後收取
 *
 * 還款週期格式（repayment_day 欄位）：
 *   - "30天"         → 每隔 30 日（以貸款起始日為基準往後滾）
 *   - "1" ~ "31"    → 每月固定第 N 日
 *
 * 會員等級：一般 → 優質會員（6期正常繳息）→ VIP（12期正常繳息）
 */
class LoanCalculationService
{
    // ─────────────────────────────────────────────
    // 基礎利率 / 本金輔助
    // ─────────────────────────────────────────────

    /**
     * 折抵後有效利率（表定利率 - 會員折扣，下限 0）
     */
    public function effectiveRatePercent(float $statedRatePercent, float $discountPercent): float
    {
        return max(0, round($statedRatePercent - max(0, $discountPercent), 4));
    }

    /**
     * 計算每期所用本金：尚餘 > 0 用尚餘，否則用借貸金額
     */
    public function principalForSchedule(float $remainingAmount, float $loanAmount): string
    {
        $p = $remainingAmount > 0 ? $remainingAmount : $loanAmount;

        return number_format(max(0, $p), 2, '.', '');
    }

    // ─────────────────────────────────────────────
    // 每期應繳金額
    // ─────────────────────────────────────────────

    /**
     * 計算每期應繳金額
     *
     * @param  string  $repaymentType  'interest_only' | 'amortization'
     * @param  string  $principal      尚餘本金（bcmath 字串）
     * @param  float   $effectiveRatePercent  折抵後每期利率 %
     * @param  int     $periods        期數（純繳息時傳 0 即可）
     */
    public function calculateMonthlyPayment(
        string $repaymentType,
        string $principal,
        float $effectiveRatePercent,
        int $periods
    ): string {
        if (bccomp($principal, '0', 2) <= 0) {
            return '0.00';
        }

        if ($repaymentType === 'interest_only') {
            return $this->interestOnlyPerPeriod($principal, $effectiveRatePercent);
        }

        if ($periods <= 0) {
            return '0.00';
        }

        return $this->amortizationEqualPayment($principal, $effectiveRatePercent, $periods);
    }

    // ─────────────────────────────────────────────
    // 前扣計算
    // ─────────────────────────────────────────────

    /**
     * 計算前扣總金額：月還款金額 × 前扣期數
     *
     * 放款實際撥付 = 借貸金額 - prepaid_amount
     *
     * @param  string  $monthlyPayment  每期還款金額（bcmath 字串）
     * @param  int     $prepaidMonths   前扣期數（0 = 後收，不前扣）
     */
    public function calculatePrepaidAmount(string $monthlyPayment, int $prepaidMonths): string
    {
        if ($prepaidMonths <= 0) {
            return '0.00';
        }

        return bcmul($monthlyPayment, (string) $prepaidMonths, 2);
    }

    /**
     * 放款實際撥付金額 = 借貸金額 - 前扣金額
     */
    public function calculateNetDisbursement(string $loanAmount, string $prepaidAmount): string
    {
        $net = bcsub($loanAmount, $prepaidAmount, 2);

        return bccomp($net, '0', 2) >= 0 ? $net : '0.00';
    }

    // ─────────────────────────────────────────────
    // 下期繳款日計算
    // ─────────────────────────────────────────────

    /**
     * 計算下一個繳款日
     *
     * @param  Carbon       $loanDate      貸款起始日
     * @param  string       $repaymentDay  還款週期設定：
     *                                     "30天" = 每 30 日
     *                                     "1"~"31" = 每月幾日
     * @param  int          $prepaidMonths 前扣期數（下期從 prepaidMonths+1 期開始）
     * @param  Carbon|null  $fromDate      計算基準日，預設今天
     */
    public function calculateNextPaymentDate(
        Carbon $loanDate,
        string $repaymentDay,
        int $prepaidMonths = 0,
        ?Carbon $fromDate = null
    ): Carbon {
        $from = $fromDate ? $fromDate->copy() : Carbon::today();

        if ($repaymentDay === '30天') {
            return $this->nextPaymentDateBy30Days($loanDate, $prepaidMonths, $from);
        }

        $day = (int) $repaymentDay;
        if ($day >= 1 && $day <= 31) {
            return $this->nextPaymentDateByMonthDay($loanDate, $day, $prepaidMonths, $from);
        }

        // 格式不明：fallback 以貸款日 +1 個月
        return $loanDate->copy()->addMonthNoOverflow();
    }

    // ─────────────────────────────────────────────
    // 完整攤還計畫（本利攤）
    // ─────────────────────────────────────────────

    /**
     * 產生等額本息完整攤還計畫
     *
     * 回傳陣列，每筆代表一期：
     * [
     *   'period'    => 1,
     *   'date'      => '2026-04-01',
     *   'payment'   => '44096.00',   // 每期固定還款
     *   'interest'  => '40000.00',   // 本期利息
     *   'principal' => '4096.00',    // 本期還本
     *   'remaining' => '1995904.00', // 期末餘額
     *   'prepaid'   => true,         // 是否屬於前扣期
     * ]
     *
     * @param  Carbon  $loanDate
     * @param  string  $principal       借貸金額（bcmath 字串）
     * @param  float   $ratePercent     每期利率 %
     * @param  int     $periods         總期數
     * @param  string  $repaymentDay    "30天" 或 "1"~"31"
     * @param  int     $prepaidMonths   前扣期數
     */
    public function generateAmortizationSchedule(
        Carbon $loanDate,
        string $principal,
        float $ratePercent,
        int $periods,
        string $repaymentDay,
        int $prepaidMonths = 0
    ): array {
        if ($periods <= 0 || bccomp($principal, '0', 2) <= 0) {
            return [];
        }

        $payment = $this->amortizationEqualPayment($principal, $ratePercent, $periods);
        $r       = bcdiv((string) $ratePercent, '100', 14);
        $balance = $principal;
        $schedule = [];

        for ($i = 1; $i <= $periods; $i++) {
            $interest   = bcmul($balance, $r, 2);
            $principalPortion = bcsub($payment, $interest, 2);

            // 最後一期用尾數修正（避免累積誤差）
            if ($i === $periods) {
                $principalPortion = $balance;
                $interest         = bcsub($payment, $principalPortion, 2);
            }

            $balance  = bcsub($balance, $principalPortion, 2);
            $balance  = bccomp($balance, '0', 2) < 0 ? '0.00' : $balance;

            $date = $this->nthPaymentDate($loanDate, $repaymentDay, $i);

            $schedule[] = [
                'period'    => $i,
                'date'      => $date->toDateString(),
                'payment'   => $payment,
                'interest'  => $interest,
                'principal' => $principalPortion,
                'remaining' => $balance,
                'prepaid'   => $i <= $prepaidMonths,
            ];
        }

        return $schedule;
    }

    /**
     * 產生純繳息計畫（每期只繳利息，本金不動）
     *
     * @param  Carbon  $loanDate
     * @param  string  $principal
     * @param  float   $ratePercent
     * @param  int     $contractMonths  合約月數（0 = 無限期，回傳 12 期供預覽）
     * @param  string  $repaymentDay
     * @param  int     $prepaidMonths
     */
    public function generateInterestOnlySchedule(
        Carbon $loanDate,
        string $principal,
        float $ratePercent,
        int $contractMonths,
        string $repaymentDay,
        int $prepaidMonths = 0
    ): array {
        $totalPeriods = $contractMonths > 0 ? $contractMonths : 12;
        $interest     = $this->interestOnlyPerPeriod($principal, $ratePercent);
        $schedule     = [];

        for ($i = 1; $i <= $totalPeriods; $i++) {
            $date = $this->nthPaymentDate($loanDate, $repaymentDay, $i);

            $schedule[] = [
                'period'    => $i,
                'date'      => $date->toDateString(),
                'payment'   => $interest,
                'interest'  => $interest,
                'principal' => '0.00',
                'remaining' => $principal,
                'prepaid'   => $i <= $prepaidMonths,
            ];
        }

        return $schedule;
    }

    // ─────────────────────────────────────────────
    // 會員等級升級評估
    // ─────────────────────────────────────────────

    /**
     * 依正常繳息期數判斷應有的會員等級
     *
     * 規則（PDF 繳款積分制度）：
     *   - >= 12 期正常繳息 → VIP
     *   - >= 6  期正常繳息 → 優質會員
     *   - 其他            → 一般
     *
     * @param  int  $consecutiveOnTimeCount  連續正常繳息期數
     */
    public function evaluateMemberLevel(int $consecutiveOnTimeCount): string
    {
        if ($consecutiveOnTimeCount >= 12) {
            return 'VIP';
        }
        if ($consecutiveOnTimeCount >= 6) {
            return '優質會員';
        }

        return '一般';
    }

    /**
     * 計算某會員所有貸款的最大連續正常繳息期數
     *
     * @param  \Illuminate\Database\Eloquent\Collection  $repayments  已依 payment_date asc 排序
     */
    public function countConsecutiveOnTimePayments(iterable $repayments): int
    {
        $max     = 0;
        $current = 0;

        foreach ($repayments as $repayment) {
            if ($repayment->status === '準時') {
                $current++;
                $max = max($max, $current);
            } else {
                $current = 0;
            }
        }

        return $max;
    }

    // ─────────────────────────────────────────────
    // Private helpers
    // ─────────────────────────────────────────────

    private function interestOnlyPerPeriod(string $principal, float $ratePercent): string
    {
        return bcmul($principal, bcdiv((string) $ratePercent, '100', 12), 2);
    }

    /**
     * 等額本息每期應繳：P × r × (1+r)^n / ((1+r)^n - 1)
     */
    private function amortizationEqualPayment(string $principal, float $ratePercent, int $n): string
    {
        $r = bcdiv((string) $ratePercent, '100', 14);

        if (bccomp($r, '0', 14) === 0) {
            return bcdiv($principal, (string) $n, 2);
        }

        $onePlusR = bcadd('1', $r, 14);
        $pow      = '1';
        for ($i = 0; $i < $n; $i++) {
            $pow = bcmul($pow, $onePlusR, 14);
        }

        $den = bcsub($pow, '1', 14);
        if (bccomp($den, '0', 14) === 0) {
            return '0.00';
        }

        $numerator = bcmul(bcmul($principal, $r, 14), $pow, 14);

        return bcdiv($numerator, $den, 2);
    }

    /**
     * 第 N 期的繳款日（從貸款起始日起算）
     */
    private function nthPaymentDate(Carbon $loanDate, string $repaymentDay, int $n): Carbon
    {
        if ($repaymentDay === '30天') {
            return $loanDate->copy()->addDays(30 * $n);
        }

        $day  = (int) $repaymentDay;
        $base = $loanDate->copy()->addMonthsNoOverflow($n);

        // 若該月沒有指定日（例如 2 月沒有 31 日），使用當月最後一天
        $maxDay = $base->daysInMonth;

        return $base->day(min($day, $maxDay));
    }

    /**
     * 每 30 日週期的下一個繳款日
     * 從貸款日往前扣後往後滾，找第一個 > $from 的日期
     */
    private function nextPaymentDateBy30Days(Carbon $loanDate, int $prepaidMonths, Carbon $from): Carbon
    {
        // 前扣期已繳，從第 prepaidMonths+1 期開始
        $period = $prepaidMonths + 1;
        $next   = $loanDate->copy()->addDays(30 * $period);

        while ($next->lte($from)) {
            $period++;
            $next = $loanDate->copy()->addDays(30 * $period);
        }

        return $next;
    }

    /**
     * 每月固定日的下一個繳款日
     */
    private function nextPaymentDateByMonthDay(
        Carbon $loanDate,
        int $day,
        int $prepaidMonths,
        Carbon $from
    ): Carbon {
        // 前扣期已繳，下一個到期日不得早於 loanDate + prepaidMonths 個月
        $earliestDue = $loanDate->copy()->addMonthsNoOverflow($prepaidMonths + 1);
        $maxDay      = $earliestDue->daysInMonth;
        $earliestDue->day(min($day, $maxDay));

        // 若 earliestDue 已超過基準日，直接回傳
        if ($earliestDue->gt($from)) {
            return $earliestDue;
        }

        // 否則從 $from 往後找第一個符合日的月份
        $next = $from->copy()->day(1); // 避免月底日溢出
        $next->day(min($day, $next->daysInMonth));

        if ($next->lte($from)) {
            $next->addMonthNoOverflow();
            $next->day(min($day, $next->daysInMonth));
        }

        return $next;
    }
}
