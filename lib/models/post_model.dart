class PostInListDto {
  final String id;
  final String? name;
  final String? slug;
  final String? description;
  final String? categoryId;
  final String? thumbnail;
  final int viewCount;
  final String? dateCreatedAt;

  PostInListDto({
    required this.id,
    this.name,
    this.slug,
    this.description,
    this.categoryId,
    this.thumbnail,
    this.viewCount = 0,
    this.dateCreatedAt,
  });

  factory PostInListDto.fromJson(Map<String, dynamic> json) {
    return PostInListDto(
      id: json['id'] ?? '',
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      categoryId: json['categoryId'],
      thumbnail: json['thumbnail'],
      viewCount: json['viewCount'] ?? 0,
      dateCreatedAt: json['dateCreatedAt'],
    );
  }
}

class PostPagingResult {
  final int currentPage;
  final int pageCount;
  final int pageSize;
  final int totalCount;
  final List<PostInListDto> results;

  PostPagingResult({
    required this.currentPage,
    required this.pageCount,
    required this.pageSize,
    required this.totalCount,
    required this.results,
  });


  factory PostPagingResult.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List?;
    List<PostInListDto> postList = list != null
        ? list.map((i) => PostInListDto.fromJson(i)).toList()
        : [];

    return PostPagingResult(
      currentPage: json['currentPage'] ?? 1,
      pageCount: json['pageCount'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['totalCount'] ?? 0,
      results: postList,
    );
  }
}