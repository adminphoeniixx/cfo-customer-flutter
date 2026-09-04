/// Laravel's standard pagination envelope, generic over the item type.
class Paginated<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int? total;
  final int? perPage;

  Paginated({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    this.total,
    this.perPage,
  });

  bool get hasMore => currentPage < lastPage;

  factory Paginated.fromJson(Map<String, dynamic> j, T Function(Map<String, dynamic>) fromJson) => Paginated<T>(
        data: (j['data'] as List? ?? []).map((e) => fromJson(Map<String, dynamic>.from(e))).toList(),
        currentPage: j['current_page'] is int ? j['current_page'] : int.tryParse('${j['current_page']}') ?? 1,
        lastPage: j['last_page'] is int ? j['last_page'] : int.tryParse('${j['last_page']}') ?? 1,
        total: j['total'] is int ? j['total'] : int.tryParse('${j['total']}'),
        perPage: j['per_page'] is int ? j['per_page'] : int.tryParse('${j['per_page']}'),
      );
}
