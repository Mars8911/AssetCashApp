<?php

namespace App\Services;

/**
 * 貸款每期應繳金額（尚餘、利率為「每期利率 %」、本利攤為等額本息）。
 * 會員折抵自「表定利率」扣除，結果不低於 0。
 */
class LoanCalculationService
{
    public function effectiveRatePercent(float $statedRatePercent, float $discountPercent): float
    {
        $discount = max(0, $discountPercent);

        return max(0, round($statedRatePercent - $discount, 4));
    }

    /**
     * 計算每期應繳所用本金：尚餘大於 0 用尚餘，否則用借貸金額（尚未填尚餘或新案時）。
     */
    public function principalForSchedule(float $remainingAmount, float $loanAmount): string
    {
        $p = $remainingAmount > 0 ? $remainingAmount : $loanAmount;

        return number_format(max(0, $p), 2, '.', '');
    }

    /**
     * @param  string  $principal  尚餘本金（字串以利 bcmath）
     * @param  float  $effectiveRatePercent  折抵後每期利率 %
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

    private function interestOnlyPerPeriod(string $principal, float $ratePercent): string
    {
        return bcmul($principal, bcdiv((string) $ratePercent, '100', 12), 2);
    }

    /**
     * 等額本息：每期利率 r = 利率% / 100，n 期。
     */
    private function amortizationEqualPayment(string $principal, float $ratePercent, int $n): string
    {
        $r = bcdiv((string) $ratePercent, '100', 14);
        if (bccomp($r, '0', 14) === 0) {
            return bcdiv($principal, (string) $n, 2);
        }

        $onePlusR = bcadd('1', $r, 14);
        $pow = '1';
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
}
