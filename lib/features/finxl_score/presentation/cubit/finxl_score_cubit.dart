import 'package:equatable/equatable.dart';
import 'package:finxl/features/bills/domain/repositories/bills_repository.dart';
import 'package:finxl/features/budget/domain/repositories/budget_repository.dart';
import 'package:finxl/features/finxl_score/data/services/finxl_score_service.dart';
import 'package:finxl/features/finxl_score/domain/entities/finxl_score.dart';
import 'package:finxl/features/goals/domain/repositories/goals_repository.dart';
import 'package:finxl/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:finxl/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// State
class FinXLScoreState extends Equatable {
  final FinXLScore? score;
  final bool isLoading;
  final String? errorMessage;

  const FinXLScoreState({
    this.score,
    this.isLoading = false,
    this.errorMessage,
  });

  FinXLScoreState copyWith({
    FinXLScore? score,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FinXLScoreState(
      score: score ?? this.score,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [score, isLoading, errorMessage];
}

// Cubit
class FinXLScoreCubit extends Cubit<FinXLScoreState> {
  final FinXLScoreService _scoreService;
  final TransactionRepository _transactionRepository;
  final BudgetRepository _budgetRepository;
  final GoalsRepository _goalsRepository;
  final SubscriptionRepository _subscriptionRepository;

  FinXLScoreCubit({
    required FinXLScoreService scoreService,
    required TransactionRepository transactionRepository,
    required BudgetRepository budgetRepository,
    required GoalsRepository goalsRepository,
    required SubscriptionRepository subscriptionRepository,
  })  : _scoreService = scoreService,
        _transactionRepository = transactionRepository,
        _budgetRepository = budgetRepository,
        _goalsRepository = goalsRepository,
        _subscriptionRepository = subscriptionRepository,
        super(const FinXLScoreState());

  Future<void> calculateScore() async {
    emit(state.copyWith(isLoading: true));
    try {
      final transactions = await _transactionRepository.getTransactions(limit: 1000);
      final budgets = await _budgetRepository.getBudgets();
      final goals = await _goalsRepository.getGoals();
      final subscriptions = await _subscriptionRepository.getSubscriptions();

      final score = _scoreService.calculateScore(
        transactions: transactions,
        budgets: budgets,
        goals: goals,
        subscriptions: subscriptions,
      );

      emit(state.copyWith(score: score, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
