import 'package:flutter/material.dart';

IconData resolveIcon(String iconKey) {
  return switch (iconKey) {
    'person' => Icons.person,
    'notifications' => Icons.notifications_outlined,
    'insights' => Icons.insights,
    'savings' => Icons.savings,
    'bank' => Icons.account_balance,
    'goals' => Icons.track_changes,
    'restaurant' => Icons.restaurant,
    'housing' => Icons.house,
    'lifestyle' => Icons.spa,
    'subscription' => Icons.subscriptions,
    'utilities' => Icons.electric_bolt,
    'entertainment' => Icons.movie,
    'travel' => Icons.flight_takeoff,
    'bike' => Icons.pedal_bike,
    'celebration' => Icons.celebration,
    'bill' => Icons.receipt_long,
    'wifi' => Icons.wifi,
    'emi' => Icons.credit_score,
    'cash' => Icons.payments,
    'card' => Icons.credit_card,
    'upi' => Icons.account_balance_wallet,
    'shopping' => Icons.shopping_bag,
    'health' => Icons.health_and_safety,
    'gym' => Icons.fitness_center,
    'other' => Icons.more_horiz,
    'warning' => Icons.warning_amber_rounded,
    _ => Icons.circle,
  };
}
