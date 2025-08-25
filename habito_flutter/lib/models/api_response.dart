import 'package:equatable/equatable.dart';

class ApiResponse<T> extends Equatable {
  final bool success;
  final T? data;
  final String message;
  final List<String> errors;

  const ApiResponse({
    required this.success,
    this.data,
    this.message = '',
    this.errors = const [],
  });

  factory ApiResponse.success(T data, {String message = 'Success'}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      errors: const [],
    );
  }

  factory ApiResponse.error(String message, {List<String>? errors}) {
    return ApiResponse(
      success: false,
      data: null,
      message: message,
      errors: errors ?? [message],
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? true,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'] as String? ?? '',
      errors: json['errors'] != null
          ? List<String>.from(json['errors'] as List)
          : const [],
    );
  }

  @override
  List<Object?> get props => [success, data, message, errors];
}

class PaginatedResponse<T> extends Equatable {
  final List<T> items;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const PaginatedResponse({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final itemsList = json['items'] as List? ?? json['data'] as List? ?? [];
    return PaginatedResponse(
      items: itemsList.map((item) => fromJsonT(item as Map<String, dynamic>)).toList(),
      totalCount: json['total_count'] as int? ?? itemsList.length,
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      hasNext: json['has_next'] as bool? ?? false,
      hasPrevious: json['has_previous'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [items, totalCount, currentPage, totalPages, hasNext, hasPrevious];
}

enum LoadingState {
  initial,
  loading,
  loaded,
  error,
}

class Resource<T> extends Equatable {
  final LoadingState state;
  final T? data;
  final String? error;

  const Resource._({
    required this.state,
    this.data,
    this.error,
  });

  const Resource.initial() : this._(state: LoadingState.initial);

  const Resource.loading([T? data]) : this._(state: LoadingState.loading, data: data);

  const Resource.loaded(T data) : this._(state: LoadingState.loaded, data: data);

  const Resource.error(String error, [T? data]) : this._(
    state: LoadingState.error,
    error: error,
    data: data,
  );

  bool get isInitial => state == LoadingState.initial;
  bool get isLoading => state == LoadingState.loading;
  bool get isLoaded => state == LoadingState.loaded;
  bool get isError => state == LoadingState.error;

  @override
  List<Object?> get props => [state, data, error];
}