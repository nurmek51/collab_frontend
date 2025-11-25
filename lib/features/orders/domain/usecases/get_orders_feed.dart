import '../entities/feed_item.dart';
import '../repositories/orders_repository.dart';

/// Use case for getting orders feed for freelancers
class GetOrdersFeed {
  final OrdersRepository repository;

  const GetOrdersFeed(this.repository);

  /// Get orders feed with pagination
  Future<List<FeedItem>> call({int limit = 20, int offset = 0}) async {
    return await repository.getOrdersFeed(limit: limit, offset: offset);
  }
}
