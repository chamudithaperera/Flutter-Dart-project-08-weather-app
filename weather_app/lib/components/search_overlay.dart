import 'package:flutter/material.dart';

class SearchOverlay extends StatelessWidget {
  final TextEditingController searchController;
  final List<Map<String, dynamic>> searchSuggestions;
  final bool isSearchingSuggestions;
  final VoidCallback onClear;
  final Function(Map<String, dynamic>) onLocationTap;

  const SearchOverlay({
    super.key,
    required this.searchController,
    required this.searchSuggestions,
    required this.isSearchingSuggestions,
    required this.onClear,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search location...',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black),
                    onPressed: onClear,
                  ),
                ),
                autofocus: true,
              ),
            ),
          ),
          Expanded(
            child:
                isSearchingSuggestions && searchSuggestions.isNotEmpty
                    ? ListView.builder(
                      itemCount: searchSuggestions.length,
                      itemBuilder: (context, index) {
                        final location = searchSuggestions[index];
                        final state =
                            location['state'] != null
                                ? ', ${location['state']}'
                                : '';
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                            ),
                          ),
                          title: Text(
                            '${location['name']}$state',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            location['country'],
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                          onTap: () => onLocationTap(location),
                        );
                      },
                    )
                    : searchController.text.isNotEmpty
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No locations found',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    )
                    : const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Start typing to search locations',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
