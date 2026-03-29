import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ---------------------------------------------------------------------------
// DATA MODEL (unchanged)
// ---------------------------------------------------------------------------

class RoomEntity {
  final int id;
  final String roomName;
  final String? roomIntro;
  final String? coverUrl;
  final int visitorsCount;
  final String? countryFlag;
  final bool isLive;
  final bool hasPassword;
  final String? ownerName;
  final String? ownerAvatarUrl;

  const RoomEntity({
    required this.id,
    required this.roomName,
    this.roomIntro,
    this.coverUrl,
    this.visitorsCount = 0,
    this.countryFlag,
    this.isLive = false,
    this.hasPassword = false,
    this.ownerName,
    this.ownerAvatarUrl,
  });
}

final sampleRooms = [
  RoomEntity(
    id: 1,
    roomName: 'Welcome to the Super Amazing Party Room 🎉🎉🎉',
    roomIntro: 'Join us for music and fun! Everyone is welcome.',
    coverUrl: 'https://picsum.photos/200/200',
    visitorsCount: 1234,
    countryFlag: '🇺🇸',
    isLive: true,
    hasPassword: false,
    ownerName: 'DJ_Master',
    ownerAvatarUrl: 'https://picsum.photos/50/50',
  ),
  RoomEntity(
    id: 2,
    roomName: 'Chill Zone',
    roomIntro: null,
    coverUrl: null,
    visitorsCount: 0,
    countryFlag: '🇹🇷',
    isLive: false,
    hasPassword: true,
    ownerName: 'Relaxer',
  ),
  RoomEntity(
    id: 3,
    roomName: 'Gaming Arena - Competitive Matches Every Hour - Join Now!',
    roomIntro:
    'Competitive gaming room with hourly tournaments and prizes for top players',
    coverUrl: 'https://picsum.photos/200/201',
    visitorsCount: 56789,
    countryFlag: null,
    isLive: true,
    hasPassword: false,
  ),
];

// ---------------------------------------------------------------------------
// SCREEN
// ---------------------------------------------------------------------------

class RoomCardList extends StatelessWidget {
  const RoomCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sampleRooms.length,
        itemBuilder: (context, index) {
          final room = sampleRooms[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RoomCard(room: room),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ROOM CARD
// ---------------------------------------------------------------------------

class RoomCard extends StatelessWidget {
  final RoomEntity room;

  const RoomCard({
    super.key,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedRoomImage(
              imageUrl: room.coverUrl,
              isLive: room.isLive,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          room.roomName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _VisitorCount(count: room.visitorsCount),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (room.roomIntro?.trim().isNotEmpty ?? false)
                        ? room.roomIntro!.trim()
                        : 'No description available',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.greyText,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (room.countryFlag != null &&
                          room.countryFlag!.trim().isNotEmpty)
                        Text(
                          room.countryFlag!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      if (room.hasPassword)
                        const _StatusChip(
                          icon: Icons.lock,
                          label: 'Private',
                        ),
                      if ((room.ownerName?.trim().isNotEmpty ?? false))
                        Text(
                          'by ${room.ownerName!.trim()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// REUSABLE CACHED IMAGE WIDGET
// ---------------------------------------------------------------------------

class CachedRoomImage extends StatelessWidget {
  final String? imageUrl;
  final bool isLive;

  const CachedRoomImage({
    super.key,
    required this.imageUrl,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 88;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned.fill(
              child: _buildImage(),
            ),
            if (isLive)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _ImagePlaceholder(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey.shade500,
          size: 28,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: const _ImagePlaceholder(),
      ),
      errorWidget: (context, url, error) => _ImagePlaceholder(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.grey.shade500,
          size: 28,
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final Widget? child;

  const _ImagePlaceholder({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// VISITOR COUNT
// ---------------------------------------------------------------------------

class _VisitorCount extends StatelessWidget {
  final int count;

  const _VisitorCount({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.visibility_outlined,
          size: 14,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          _formatCount(count),
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    }
    return value.toString();
  }
}

// ---------------------------------------------------------------------------
// STATUS CHIP
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// COLORS
// ---------------------------------------------------------------------------

class AppColors {
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const greyText = Color(0xFFa5a7a4);
  static const primary = Color(0xFF32e5ac);
  static const shimmerBase = Color(0xFFE0E0E0);
  static const shimmerHighlight = Color(0xFFF5F5F5);
}