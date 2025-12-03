// lib/features/matches/presentation/pages/submit_result_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../bloc/match_result_bloc.dart';

class SubmitResultPage extends StatefulWidget {
  final ActiveMatch match;

  const SubmitResultPage({super.key, required this.match});

  @override
  State<SubmitResultPage> createState() => _SubmitResultPageState();
}

class _SubmitResultPageState extends State<SubmitResultPage> {
  int _myScore = 0;
  int _opponentScore = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MatchResultBloc(),
      child: BlocConsumer<MatchResultBloc, MatchResultState>(
        listener: (context, state) {
          if (state is MatchResultSuccess) {
            HapticFeedback.mediumImpact();
            _showSuccessDialog(context, state.response);
          } else if (state is MatchResultError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A0E1A),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'NATIJA YUBORISH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Opponent info card
                  _buildOpponentCard(),
                  const SizedBox(height: 32),

                  // Score input
                  _buildScoreInput(),
                  const SizedBox(height: 32),

                  // Submit button
                  _buildSubmitButton(context, state),
                  const SizedBox(height: 16),

                  // Warning text
                  Text(
                    'Diqqat: Noto\'g\'ri natija yuborish ban olishingizga sabab bo\'lishi mumkin!',
                    style: TextStyle(
                      color: Colors.orange.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOpponentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1F3A), Color(0xFF252B4A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6C5CE7).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Opponent avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.match.opponent.avatarUrl != null &&
                    widget.match.opponent.avatarUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      widget.match.opponent.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    ),
                  )
                : _buildDefaultAvatar(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Raqib',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.match.opponent.nickname,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getModeName(widget.match.mode),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreInput() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1F3A), Color(0xFF252B4A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6C5CE7).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'O\'yin natijasi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Score selectors
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // My score
              _buildScoreSelector(
                label: 'Sizning gol',
                score: _myScore,
                color: const Color(0xFF00D26A),
                onIncrement: () => setState(() {
                  if (_myScore < 99) _myScore++;
                }),
                onDecrement: () => setState(() {
                  if (_myScore > 0) _myScore--;
                }),
              ),

              // VS
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              // Opponent score
              _buildScoreSelector(
                label: 'Raqib gol',
                score: _opponentScore,
                color: const Color(0xFFFF6B6B),
                onIncrement: () => setState(() {
                  if (_opponentScore < 99) _opponentScore++;
                }),
                onDecrement: () => setState(() {
                  if (_opponentScore > 0) _opponentScore--;
                }),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Result preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _getResultColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getResultColor().withOpacity(0.3),
              ),
            ),
            child: Text(
              _getResultText(),
              style: TextStyle(
                color: _getResultColor(),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSelector({
    required String label,
    required int score,
    required Color color,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              // Increment button
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onIncrement();
                },
                icon: Icon(Icons.add, color: color),
              ),
              // Score display
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '$score',
                  style: TextStyle(
                    color: color,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Decrement button
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onDecrement();
                },
                icon: Icon(Icons.remove, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, MatchResultState state) {
    final isLoading = state is MatchResultSubmitting;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                HapticFeedback.mediumImpact();
                _showConfirmDialog(context);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C5CE7),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF6C5CE7).withOpacity(0.5),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Natijani yuborish',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFF6C5CE7).withOpacity(0.5)),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF6C5CE7), size: 28),
            SizedBox(width: 12),
            Text(
              'Natijani tasdiqlash',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Natija: $_myScore - $_opponentScore',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getResultText(),
              style: TextStyle(
                color: _getResultColor(),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bu natijani yuborishni tasdiqlaysizmi?',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Bekor qilish',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<MatchResultBloc>().add(
                    MatchResultSubmitted(
                      matchId: widget.match.id,
                      myScore: _myScore,
                      opponentScore: _opponentScore,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Tasdiqlash'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, MatchResultResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFF00D26A).withOpacity(0.5)),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF00D26A), size: 28),
            SizedBox(width: 12),
            Text(
              'Natija yuborildi!',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              response.message,
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
            if (response.ratingChange != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: response.ratingChange! >= 0
                      ? const Color(0xFF00D26A).withOpacity(0.1)
                      : const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      response.ratingChange! >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: response.ratingChange! >= 0
                          ? const Color(0xFF00D26A)
                          : const Color(0xFFFF6B6B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${response.ratingChange! >= 0 ? '+' : ''}${response.ratingChange} Rating',
                      style: TextStyle(
                        color: response.ratingChange! >= 0
                            ? const Color(0xFF00D26A)
                            : const Color(0xFFFF6B6B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context); // Return to active matches
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D26A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        widget.match.opponent.nickname.isNotEmpty
            ? widget.match.opponent.nickname[0].toUpperCase()
            : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getResultColor() {
    if (_myScore > _opponentScore) {
      return const Color(0xFF00D26A);
    } else if (_myScore < _opponentScore) {
      return const Color(0xFFFF6B6B);
    } else {
      return const Color(0xFFFFB800);
    }
  }

  String _getResultText() {
    if (_myScore > _opponentScore) {
      return 'G\'ALABA! 🏆';
    } else if (_myScore < _opponentScore) {
      return 'MAG\'LUBIYAT 😔';
    } else {
      return 'DURRANG 🤝';
    }
  }

  String _getModeName(String mode) {
    switch (mode.toLowerCase()) {
      case 'friendly':
        return "Do'stona o'yin";
      case 'ranked':
        return 'Reytingli';
      case 'bet':
        return 'Stavkali';
      default:
        return mode;
    }
  }
}
