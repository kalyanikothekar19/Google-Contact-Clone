import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/contact_bloc.dart';
import '../bloc/contact_event.dart';
import '../bloc/contact_state.dart';
import '../widgets/contact_avatar.dart';
import 'contact_profile_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final bool isActive;
  const FavoritesScreen({super.key, this.isActive = true});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void didUpdateWidget(covariant FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isActive && oldWidget.isActive) {
      _searchController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => searchQuery = '');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    context.read<ContactBloc>().add(LoadContacts());
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final screenWidth = size.width;
    final screenHeight = size.height;

    final double titleFontSize = screenWidth * 0.042;
    final double subtitleFontSize = screenWidth * 0.035;
    final double vPadding = screenHeight * 0.01;
    final double hPadding = screenWidth * 0.04;
    final double iconSize = screenWidth * 0.06;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search favorites',
                hintStyle: const TextStyle(fontSize: 16),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 45, minHeight: 40),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(Icons.search, size: 25),
                ),
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 50, minHeight: 40),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    child: const Text(
                      'K',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 241, 235, 235),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) =>
                  setState(() => searchQuery = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: BlocBuilder<ContactBloc, ContactState>(
              builder: (context, state) {
                if (state is ContactLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ContactError) {
                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: screenHeight * 0.3),
                        Center(child: Text(state.message)),
                      ],
                    ),
                  );
                }

                if (state is ContactLoaded) {
                  var favs = state.favorites;

                  if (favs.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: screenHeight * 0.25),
                          Icon(Icons.star_border,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No favorites yet.\nTap the star on a contact to add one.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  if (searchQuery.isNotEmpty) {
                    favs = favs
                        .where(
                            (c) => c.name.toLowerCase().contains(searchQuery))
                        .toList();
                  }

                  if (favs.isEmpty && searchQuery.isNotEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: screenHeight * 0.3),
                        const Center(
                            child: Text('No matching favorites found.')),
                      ],
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: favs.length,
                      itemBuilder: (context, index) {
                        final contact = favs[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            dense: true,
                            visualDensity: const VisualDensity(
                                horizontal: 0, vertical: -4),
                            minVerticalPadding: 0,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: hPadding, vertical: vPadding),
                            leading: ContactAvatar(
                                name: contact.name,
                                photoPath: contact.photoPath),
                            title: Text(
                              contact.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: titleFontSize,
                                  color: Colors.black),
                            ),
                            subtitle: Text(
                              contact.phone,
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: subtitleFontSize),
                            ),
                            trailing: IconButton(
                              iconSize: iconSize,
                              icon: const Icon(Icons.star, color: Colors.amber),
                              onPressed: () {
                                context
                                    .read<ContactBloc>()
                                    .add(ToggleFavorite(contact));
                              },
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ContactProfileScreen(contact: contact),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
