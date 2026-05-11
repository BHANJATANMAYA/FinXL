import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/features/sms_detection/data/services/sms_detection_service.dart';
import 'package:finxl/features/sms_detection/data/services/sms_parser_engine.dart';
import 'package:finxl/features/sms_detection/data/services/sms_transaction_mapper.dart';
import 'package:finxl/features/sms_detection/domain/entities/detected_sms_message.dart';
import 'package:finxl/features/sms_detection/domain/entities/sms_transaction_candidate.dart';
import 'package:finxl/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SmsDetectionBloc extends Cubit<SmsDetectionState> {
  SmsDetectionBloc({
    required SmsDetectionService detectionService,
    required SmsParserEngine parserEngine,
    required SmsTransactionMapper transactionMapper,
    required TransactionRepository transactionRepository,
  }) : _detectionService = detectionService,
       _parserEngine = parserEngine,
       _transactionMapper = transactionMapper,
       _transactionRepository = transactionRepository,
       super(const SmsDetectionState());

  final SmsDetectionService _detectionService;
  final SmsParserEngine _parserEngine;
  final SmsTransactionMapper _transactionMapper;
  final TransactionRepository _transactionRepository;
  StreamSubscription? _smsSubscription;

  Future<void> enable() async {
    emit(
      state.copyWith(
        status: LoadStatus.loading,
        errorMessage: null,
        userConsented: true,
      ),
    );

    if (!_detectionService.isSupported) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          userConsented: false,
          parsingError: true,
          errorMessage: 'Smart SMS Detection is available on Android only.',
        ),
      );
      return;
    }

    final granted = await _detectionService.requestPermission();
    if (!granted) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          permissionGranted: false,
          userConsented: false,
          errorMessage: 'SMS permission was not granted.',
        ),
      );
      return;
    }

    await _detectionService.startListening();
    await _smsSubscription?.cancel();
    _smsSubscription = _detectionService.messages.listen(_handleSms);
    emit(
      state.copyWith(
        status: LoadStatus.success,
        permissionGranted: true,
        listening: true,
        savedTransaction: false,
        errorMessage: null,
      ),
    );
  }

  Future<void> disable() async {
    await _smsSubscription?.cancel();
    _smsSubscription = null;
    await _detectionService.stopListening();
    emit(
      state.copyWith(
        userConsented: false,
        listening: false,
        reviewPending: false,
        pendingCandidate: null,
        clearPendingCandidate: true,
      ),
    );
  }

  Future<void> confirmPending() async {
    final candidate = state.pendingCandidate;
    if (candidate == null) return;
    emit(state.copyWith(status: LoadStatus.loading, errorMessage: null));
    try {
      await _transactionRepository.addTransaction(
        _transactionMapper.toTransaction(candidate),
      );
      emit(
        state.copyWith(
          status: LoadStatus.success,
          transactionDetected: false,
          reviewPending: false,
          savedTransaction: true,
          pendingCandidate: null,
          clearPendingCandidate: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: 'Unable to save auto-detected transaction.',
        ),
      );
    }
  }

  void dismissPending() {
    emit(
      state.copyWith(
        transactionDetected: false,
        reviewPending: false,
        savedTransaction: false,
        pendingCandidate: null,
        clearPendingCandidate: true,
      ),
    );
  }

  void simulateIncomingSms(String body) {
    _handleSmsMessage(body, DateTime.now(), sender: 'FINXL-DEMO');
  }

  void _handleSms(dynamic message) {
    if (message == null) return;
    final candidate = _parserEngine.parse(message);
    if (candidate == null) return;
    emit(
      state.copyWith(
        transactionDetected: true,
        reviewPending: true,
        parsingError: false,
        savedTransaction: false,
        pendingCandidate: candidate,
      ),
    );
  }

  void _handleSmsMessage(String body, DateTime receivedAt, {String? sender}) {
    final candidate = _parserEngine.parse(
      DetectedSmsMessage(body: body, receivedAt: receivedAt, sender: sender),
    );
    if (candidate == null) {
      emit(
        state.copyWith(
          parsingError: true,
          errorMessage: 'No transaction details found in this SMS.',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        transactionDetected: true,
        reviewPending: true,
        parsingError: false,
        savedTransaction: false,
        pendingCandidate: candidate,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _smsSubscription?.cancel();
    _detectionService.dispose();
    return super.close();
  }
}

class SmsDetectionState extends Equatable {
  const SmsDetectionState({
    this.status = LoadStatus.initial,
    this.permissionGranted = false,
    this.listening = false,
    this.transactionDetected = false,
    this.reviewPending = false,
    this.parsingError = false,
    this.userConsented = false,
    this.savedTransaction = false,
    this.pendingCandidate,
    this.errorMessage,
  });

  final LoadStatus status;
  final bool permissionGranted;
  final bool listening;
  final bool transactionDetected;
  final bool reviewPending;
  final bool parsingError;
  final bool userConsented;
  final bool savedTransaction;
  final SmsTransactionCandidate? pendingCandidate;
  final String? errorMessage;

  SmsDetectionState copyWith({
    LoadStatus? status,
    bool? permissionGranted,
    bool? listening,
    bool? transactionDetected,
    bool? reviewPending,
    bool? parsingError,
    bool? userConsented,
    bool? savedTransaction,
    SmsTransactionCandidate? pendingCandidate,
    bool clearPendingCandidate = false,
    String? errorMessage,
  }) {
    return SmsDetectionState(
      status: status ?? this.status,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      listening: listening ?? this.listening,
      transactionDetected: transactionDetected ?? this.transactionDetected,
      reviewPending: reviewPending ?? this.reviewPending,
      parsingError: parsingError ?? this.parsingError,
      userConsented: userConsented ?? this.userConsented,
      savedTransaction: savedTransaction ?? this.savedTransaction,
      pendingCandidate: clearPendingCandidate
          ? null
          : pendingCandidate ?? this.pendingCandidate,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    permissionGranted,
    listening,
    transactionDetected,
    reviewPending,
    parsingError,
    userConsented,
    savedTransaction,
    pendingCandidate,
    errorMessage,
  ];
}
