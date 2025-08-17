import 'package:flutter/material.dart';

class OnboardingSlideData {
  final String title;
  final String description;
  final IconData icon;
  final String? image;

  const OnboardingSlideData({
    required this.title,
    required this.description,
    required this.icon,
    this.image,
  });
}

const List<OnboardingSlideData> onboardingSlides = [
  OnboardingSlideData(
    title: 'Turnirlarga qatnashing',
    description:
        'Professional o\'yinchilar bilan raqobatlashing va katta mukofotlarni qo\'lga kiriting',
    icon: Icons.emoji_events_rounded,
  ),
  OnboardingSlideData(
    title: 'Jamoangni yarating',
    description:
        'Do\'stlaringiz bilan jamoa tuzing va birgalikda g\'alaba qozoning',
    icon: Icons.group_rounded,
  ),
  OnboardingSlideData(
    title: 'Coaching oling',
    description:
        'Professional murabbiylardan saboq oling va o\'yiningizni yaxshilang',
    icon: Icons.school_rounded,
  ),
  OnboardingSlideData(
    title: 'Jamiyatga qo\'shiling',
    description:
        'Gaming jamiyatida yangi do\'stlar toping va tajriba almashing',
    icon: Icons.chat_bubble_rounded,
  ),
];
