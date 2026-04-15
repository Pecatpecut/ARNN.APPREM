import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/claims_service.dart';

class AdminGaransiPage extends StatefulWidget {
  const AdminGaransiPage({super.key});

  @override
  State<AdminGaransiPage> createState() => _AdminGaransiPageState();
}

class _AdminGaransiPageState extends State<AdminGaransiPage> {
  final ClaimsService _service = ClaimsService();

  List claims = [];
  bool isLoading = true;

  String selectedFilter = "all";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      final data = await _service.getClaims();

      setState(() {
        claims = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR GARANSI: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

List get filteredClaims {
  return claims.where((c) {
    final statusMatch =
        selectedFilter == "all" || c['status'] == selectedFilter;

    final searchMatch = (c['orders']?['product_name'] ?? '')
        .toString()
        .toLowerCase()
        .contains(searchQuery.toLowerCase());

    return statusMatch && searchMatch;
  }).toList();
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      /// 🔥 APPBAR ADMIN
      appBar: null,

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primary.withValues(alpha: 0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(AppConstants.padding),
                  children: [

                    /// 🔥 HEADER (KAYAK DASHBOARD)
      Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    /// 🔥 NAVBAR (ARINI STORE)
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
              child: Icon(Icons.grid_view,
                  color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Text(
              "Arini Store",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),

        const CircleAvatar(
          radius: 18,
          child: Icon(Icons.person),
        ),
      ],
    ),

    const SizedBox(height: 25),

    /// 🔥 TITLE BESAR
    Text(
      "Warranty Claims",
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),

    const SizedBox(height: 20),

    /// 🔥 SEARCH
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface.withValues(alpha: 0.6),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: const InputDecoration(
          hintText: "Search product...",
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
      ),
    ),

    const SizedBox(height: 20),
  ],
),

                          /// 🔥 FILTER SECTION
                          _filterSection(),

                          const SizedBox(height: 20),

                          /// 🔥 LIST CLAIM
                          if (filteredClaims.isEmpty)
                            _emptyState()
                          else
                            ...filteredClaims.map((c) => _card(c)),
                        ],
                      ),
              ),
            ),
          );
        }

        /// 🔥 FILTER UI
        Widget _filterSection() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _filterChip("All", "all"),
              _filterChip("Pending", "pending"),
              _filterChip("Approved", "approved"),
              _filterChip("Rejected", "rejected"),
            ],
          );
        }

        Widget _filterChip(String label, String value) {
          final theme = Theme.of(context);
          final isActive = selectedFilter == value;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = value;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface.withValues(alpha: 0.6),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        /// 🔥 EMPTY STATE
        Widget _emptyState() {
          final theme = Theme.of(context);

          return Center(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Icon(
                  Icons.inbox_outlined,
                  size: 60,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 10),
                Text(
                  "Tidak ada data",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        }

        /// 🔥 CARD
        
        Widget _card(Map c) {
        final theme = Theme.of(context);

        final status = c['status'] ?? 'pending';
        final order = c['orders'] ?? {};

        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),

            gradient: LinearGradient(
              colors: theme.brightness == Brightness.dark
                  ? [
                      const Color(0xFF1B1B2F),
                      const Color(0xFF1F1F3A),
                    ]
                  : [
                      theme.colorScheme.primary.withValues(alpha: 0.08),
                      theme.colorScheme.surface,
                    ],
            ),

            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

        /// 🔥 HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              order['product_name'] ?? 'Unknown Product',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            _statusBadge(status),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          "Sharing 1PTU • ${order['variant_type'] ?? '-'}",
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),

        const SizedBox(height: 15),

        /// 🔥 PROBLEM BOX
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.brightness == Brightness.dark
                ? Colors.black
                : theme.colorScheme.surface,
          ),
          child: Text(
            c['problem_description'] ?? '-',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// 🔥 IMAGE
        if (c['proof_image'] != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              c['proof_image'],
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

        const SizedBox(height: 12),

        /// 🔥 FOOTER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 12),
                const SizedBox(width: 6),
                Text(
                  "User",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/admin-garansi-detail',
                  arguments: c,
                );
              },
              child: Text(
                "Action Details →",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ],
    ),
  );
}

  /// 🔥 STATUS BADGE
  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}