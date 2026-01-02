import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/api_service.dart';

class DailyBonusDialog extends StatefulWidget {
  final DailyBonusInfo bonusInfo;
  final VoidCallback? onClaimed;

  const DailyBonusDialog({
    super.key,
    required this.bonusInfo,
    this.onClaimed,
  });

  @override
  State<DailyBonusDialog> createState() => _DailyBonusDialogState();
}

class _DailyBonusDialogState extends State<DailyBonusDialog>
    with SingleTickerProviderStateMixin {
  bool _isClaiming = false;
  bool _isClaimed = false;
  int _claimedAmount = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.bgDark,
              AppColors.bgDark.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            const SizedBox(height: 8),

            // Gift icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: Colors.white,
                size: 50,
              ),
            )
                .animate()
                .scale(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                )
                .then()
                .shake(),

            const SizedBox(height: 24),

            // Title
            Text(
              'Kunlik Bonus!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 400))
                .slideY(begin: -0.2, end: 0),

            const SizedBox(height: 8),

            // Streak info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.bonusInfo.streak} kun ketma-ket',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 400))
                .slideY(begin: -0.2, end: 0),

            const SizedBox(height: 24),

            // Bonus amount
            if (_isClaimed)
              Column(
                children: [
                  Text(
                    '+$_claimedAmount',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 48,
                        ),
                  )
                      .animate()
                      .scale(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 8),
                  Text(
                    'Tanga',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    '+${widget.bonusInfo.bonusAmount}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 48,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tanga',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            // Claim button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isClaiming || _isClaimed
                    ? null
                    : () => _claimBonus(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isClaiming
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : _isClaimed
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Bonus olindi!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Bonus olish',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
              ),
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 400))
                .slideY(begin: 0.2, end: 0),

            if (widget.bonusInfo.longestStreak > 0) ...[
              const SizedBox(height: 16),
              Text(
                'Eng uzun ketma-ketlik: ${widget.bonusInfo.longestStreak} kun',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _claimBonus() async {
    setState(() {
      _isClaiming = true;
    });

    try {
      final response = await ApiService().claimDailyBonus();

      if (response.success) {
        setState(() {
          _isClaimed = true;
          _claimedAmount = response.bonusAmount;
          _isClaiming = false;
        });

        // 2 soniya kutib, dialog'ni yopish
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop();
          widget.onClaimed?.call();
        }
      } else {
        setState(() {
          _isClaiming = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Bonus olishda xatolik'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isClaiming = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik yuz berdi: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}

