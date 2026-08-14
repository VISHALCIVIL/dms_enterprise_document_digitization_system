class BatchModel {
  final String id;
  final String batchNumber;
  final String projectId;
  final String areaId;
  final String departmentId;
  final String operatorId;
  final int totalFiles;
  final int totalPages;
  final String status; // OPEN, PROCESSING, COMPLETED, FAILED
  final int createdAt;

  const BatchModel({
    required this.id,
    required this.batchNumber,
    required this.projectId,
    required this.areaId,
    required this.departmentId,
    required this.operatorId,
    this.totalFiles = 0,
    this.totalPages = 0,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'batchNumber': batchNumber,
      'projectId': projectId,
      'areaId': areaId,
      'departmentId': departmentId,
      'operatorId': operatorId,
      'totalFiles': totalFiles,
      'totalPages': totalPages,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory BatchModel.fromFirestoreMap(Map<String, dynamic> map) {
    return BatchModel(
      id: map['id'] as String,
      batchNumber: map['batchNumber'] as String,
      projectId: map['projectId'] as String,
      areaId: map['areaId'] as String,
      departmentId: map['departmentId'] as String,
      operatorId: map['operatorId'] as String,
      totalFiles: map['totalFiles'] as int? ?? 0,
      totalPages: map['totalPages'] as int? ?? 0,
      status: map['status'] as String? ?? 'OPEN',
      createdAt: map['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
