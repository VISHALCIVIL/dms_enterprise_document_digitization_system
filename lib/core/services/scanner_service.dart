import 'dart:async';
import 'dart:math';

enum ScannerStatusState { disconnected, ready, scanning, paused, error }

class ScannerState {
  final ScannerStatusState state;
  final String deviceName;
  final int speedPpm;
  final int currentFileIndex;
  final int currentBatchTotalFiles;
  final int currentFilePages;
  final int totalPagesScanned;
  final double scanningProgress;
  final String? errorMessage;

  const ScannerState({
    required this.state,
    required this.deviceName,
    required this.speedPpm,
    required this.currentFileIndex,
    required this.currentBatchTotalFiles,
    required this.currentFilePages,
    required this.totalPagesScanned,
    required this.scanningProgress,
    this.errorMessage,
  });

  ScannerState copyWith({
    ScannerStatusState? state,
    String? deviceName,
    int? speedPpm,
    int? currentFileIndex,
    int? currentBatchTotalFiles,
    int? currentFilePages,
    int? totalPagesScanned,
    double? scanningProgress,
    String? errorMessage,
  }) {
    return ScannerState(
      state: state ?? this.state,
      deviceName: deviceName ?? this.deviceName,
      speedPpm: speedPpm ?? this.speedPpm,
      currentFileIndex: currentFileIndex ?? this.currentFileIndex,
      currentBatchTotalFiles: currentBatchTotalFiles ?? this.currentBatchTotalFiles,
      currentFilePages: currentFilePages ?? this.currentFilePages,
      totalPagesScanned: totalPagesScanned ?? this.totalPagesScanned,
      scanningProgress: scanningProgress ?? this.scanningProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

abstract class ScannerHardwareInterface {
  Stream<ScannerState> get stateStream;
  ScannerState get currentState;

  Future<void> startScan({required String batchId, int targetFiles = 125});
  Future<void> pauseScan();
  Future<void> resumeScan();
  Future<void> stopScan();
}

/// Simulated Hardware Scanner implementation for production testing & environment where physical TWAIN/WIA scanner DLL is not connected.
/// Simulates Canon DR-G2110 120 PPM high-speed feeder streaming.
class MockScannerService implements ScannerHardwareInterface {
  final _controller = StreamController<ScannerState>.broadcast();
  Timer? _scanTimer;

  ScannerState _state = const ScannerState(
    state: ScannerStatusState.ready,
    deviceName: 'Canon DR-G2110',
    speedPpm: 120,
    currentFileIndex: 14,
    currentBatchTotalFiles: 125,
    currentFilePages: 45,
    totalPagesScanned: 18450,
    scanningProgress: 0.78,
  );

  @override
  Stream<ScannerState> get stateStream => _controller.stream;

  @override
  ScannerState get currentState => _state;

  void _updateState(ScannerState newState) {
    _state = newState;
    _controller.add(_state);
  }

  @override
  Future<void> startScan({required String batchId, int targetFiles = 125}) async {
    if (_state.state == ScannerStatusState.scanning) return;

    _updateState(_state.copyWith(
      state: ScannerStatusState.scanning,
      currentBatchTotalFiles: targetFiles,
      scanningProgress: 0.05,
    ));

    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_state.state != ScannerStatusState.scanning) return;

      double nextProgress = _state.scanningProgress + 0.05;
      int nextPages = _state.currentFilePages + Random().nextInt(4) + 1;
      int nextTotalPages = _state.totalPagesScanned + 1;

      if (nextProgress >= 1.0) {
        int nextFile = _state.currentFileIndex + 1;
        if (nextFile > _state.currentBatchTotalFiles) {
          stopScan();
          return;
        }
        _updateState(_state.copyWith(
          currentFileIndex: nextFile,
          currentFilePages: 1,
          scanningProgress: 0.0,
          totalPagesScanned: nextTotalPages,
        ));
      } else {
        _updateState(_state.copyWith(
          currentFilePages: nextPages,
          scanningProgress: nextProgress,
          totalPagesScanned: nextTotalPages,
        ));
      }
    });
  }

  @override
  Future<void> pauseScan() async {
    _scanTimer?.cancel();
    _updateState(_state.copyWith(state: ScannerStatusState.paused));
  }

  @override
  Future<void> resumeScan() async {
    if (_state.state == ScannerStatusState.paused) {
      startScan(batchId: 'BATCH-AUG-042', targetFiles: _state.currentBatchTotalFiles);
    }
  }

  @override
  Future<void> stopScan() async {
    _scanTimer?.cancel();
    _updateState(_state.copyWith(
      state: ScannerStatusState.ready,
      scanningProgress: 1.0,
    ));
  }
}
