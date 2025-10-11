// // lib/core/utils/pagination_helper.dart
// class PaginationHelper<T> {
//   final Future<List<T>> Function(int page, int limit) fetchData;
  
//   List<T> items = [];
//   int currentPage = 1;
//   bool hasMore = true;
//   bool isLoading = false;
  
//   Future<void> loadMore() async {
//     if (isLoading || !hasMore) return;
    
//     isLoading = true;
//     final newItems = await fetchData(currentPage, 20);
    
//     items.addAll(newItems);
//     hasMore = newItems.length == 20;
//     currentPage++;
//     isLoading = false;
//   }
// }