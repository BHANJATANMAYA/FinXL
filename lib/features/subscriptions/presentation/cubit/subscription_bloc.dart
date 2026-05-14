import 'package:equatable/equatable.dart';
import 'package:finxl/core/models/subscription.dart';
import 'package:finxl/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:finxl/features/subscriptions/data/services/subscription_detection_service.dart';
import 'package:finxl/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();
  @override
  List<Object?> get props => [];
}

class LoadSubscriptions extends SubscriptionEvent {}

class DetectSubscriptions extends SubscriptionEvent {}

class AddSubscription extends SubscriptionEvent {
  final Subscription subscription;
  const AddSubscription(this.subscription);
  @override
  List<Object?> get props => [subscription];
}

class ToggleSubscriptionStatus extends SubscriptionEvent {
  final Subscription subscription;
  const ToggleSubscriptionStatus(this.subscription);
  @override
  List<Object?> get props => [subscription];
}

// State
class SubscriptionState extends Equatable {
  final List<Subscription> subscriptions;
  final List<SubscriptionCandidate> candidates;
  final bool isLoading;
  final String? errorMessage;

  const SubscriptionState({
    this.subscriptions = const [],
    this.candidates = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SubscriptionState copyWith({
    List<Subscription>? subscriptions,
    List<SubscriptionCandidate>? candidates,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SubscriptionState(
      subscriptions: subscriptions ?? this.subscriptions,
      candidates: candidates ?? this.candidates,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  double get totalMonthlyAmount {
    double total = 0;
    for (final sub in subscriptions) {
      if (!sub.isActive) continue;
      if (sub.recurrence == RecurrenceType.monthly) {
        total += sub.amount;
      } else if (sub.recurrence == RecurrenceType.yearly) {
        total += sub.amount / 12;
      }
    }
    return total;
  }

  @override
  List<Object?> get props => [subscriptions, candidates, isLoading, errorMessage];
}

// Cubit/Bloc
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _subscriptionRepository;
  final TransactionRepository _transactionRepository;
  final SubscriptionDetectionService _detectionService;

  SubscriptionBloc({
    required SubscriptionRepository subscriptionRepository,
    required TransactionRepository transactionRepository,
    required SubscriptionDetectionService detectionService,
  })  : _subscriptionRepository = subscriptionRepository,
        _transactionRepository = transactionRepository,
        _detectionService = detectionService,
        super(const SubscriptionState()) {
    on<LoadSubscriptions>(_onLoadSubscriptions);
    on<DetectSubscriptions>(_onDetectSubscriptions);
    on<AddSubscription>(_onAddSubscription);
    on<ToggleSubscriptionStatus>(_onToggleSubscriptionStatus);
  }

  Future<void> _onLoadSubscriptions(LoadSubscriptions event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final subs = await _subscriptionRepository.getSubscriptions();
      emit(state.copyWith(subscriptions: subs, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDetectSubscriptions(DetectSubscriptions event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final transactions = await _transactionRepository.getTransactions(limit: 1000);
      final candidates = _detectionService.detectCandidates(transactions);

      // Filter candidates that are already added
      final existingNames = state.subscriptions.map((s) => s.name.toLowerCase()).toSet();
      final filteredCandidates = candidates.where((c) => !existingNames.contains(c.name.toLowerCase())).toList();

      emit(state.copyWith(candidates: filteredCandidates, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddSubscription(AddSubscription event, Emitter<SubscriptionState> emit) async {
    try {
      await _subscriptionRepository.insertSubscription(event.subscription);
      add(LoadSubscriptions());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onToggleSubscriptionStatus(ToggleSubscriptionStatus event, Emitter<SubscriptionState> emit) async {
    try {
      final updated = event.subscription.copyWith(isActive: !event.subscription.isActive);
      await _subscriptionRepository.updateSubscription(updated);
      add(LoadSubscriptions());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
