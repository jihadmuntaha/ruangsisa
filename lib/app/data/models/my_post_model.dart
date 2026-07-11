class MyPostModel {
  final int id;
  final String title;
  final String description;
  final String images;
  final String postType;
  final int price;
  final String barterWishlist;
  final String status;
  final String createdAt;

  MyPostModel({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.postType,
    required this.price,
    required this.barterWishlist,
    required this.status,
    required this.createdAt,
  });

  factory MyPostModel.fromJson(Map<String, dynamic> json) {
    return MyPostModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      images: json['images'] ?? '',
      postType: json['post_type'] ?? 'Lainnya',
      price: json['price'] ?? 0,
      barterWishlist: json['barter_wishlist'] ?? '',
      status: json['status'] ?? 'Aktif',
      createdAt: json['created_at'] ?? '',
    );
  }
}
