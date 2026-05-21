// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/provider_dashboard_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';

// ---- small helpers -------------------------------------------------------

String _formatCurrency(double amount, String symbol) {
  // Match the existing app convention: "$ 1,234.50".
  final whole = amount.truncate();
  final cents = ((amount - whole) * 100).round().abs().toString().padLeft(2, '0');
  final wholeStr = whole.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
  return '$symbol $wholeStr.$cents';
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
    case 'check_out':
      return const Color(0xff27AE60);
    case 'cancelled':
    case 'canceled':
      return const Color(0xffEB5757);
    case 'pending':
      return const Color(0xffF2994A);
    default:
      return blueColor;
  }
}

/// Landing screen shown to users whose `user_type == "provider"`.
///
/// This is intentionally a lightweight scaffold: it surfaces the provider's
/// agency info plus placeholder cards for bookings received, earnings, and
/// reviews. Each card is a hook for a future real-data fetch — the structure
/// is in place so wiring them up later only requires swapping the static
/// numbers for controller-backed values.
class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  late final ProviderDashboardController controller;

  @override
  void initState() {
    super.initState();
    // Tag-bind so we don't collide with any future second instance.
    controller = Get.put(ProviderDashboardController(), tag: 'provider_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final notifire = Provider.of<ColorNotifire>(context, listen: true);
    final user = getData.read("UserLogin") ?? const {};
    final name = (user["name"] ?? "Provider").toString();
    final agency = (user["agency_name"] ?? "").toString();
    final serviceType = (user["service_type"] ?? "").toString();

    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.fetch(),
          child: GetBuilder<ProviderDashboardController>(
            tag: 'provider_dashboard',
            builder: (c) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----- Greeting -----
                  Text(
                    "Welcome back,".tr,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      color: notifire.getgreycolor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      color: notifire.getwhiteblackcolor,
                      fontSize: 24,
                    ),
                  ),
                  if (agency.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      agency + (serviceType.isNotEmpty ? "  ·  ${serviceType.tr}" : ""),
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                        color: notifire.getgreycolor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // ----- Error banner -----
                  if (c.errorMessage != null && !c.isLoading)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xffEB5757).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xffEB5757).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xffEB5757), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c.errorMessage!,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyMedium,
                                fontSize: 12,
                                color: notifire.getwhiteblackcolor,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: c.fetch,
                            child: Text("Retry".tr,
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  color: blueColor,
                                  fontSize: 12,
                                )),
                          ),
                        ],
                      ),
                    ),

                  // ----- KPI cards -----
                  LayoutBuilder(builder: (context, lb) {
                    final isWide = lb.maxWidth >= 700;
                    final cards = [
                      _KpiCard(
                        notifire: notifire,
                        icon: Icons.calendar_month_outlined,
                        label: "Bookings this week".tr,
                        value: c.isLoading ? '—' : c.bookingsThisWeek.toString(),
                        sub: c.isLoading
                            ? null
                            : "${c.bookingsTotal} ${'total'.tr}",
                        color: blueColor,
                      ),
                      _KpiCard(
                        notifire: notifire,
                        icon: Icons.payments_outlined,
                        label: "Earnings (MTD)".tr,
                        value: c.isLoading
                            ? '—'
                            : _formatCurrency(c.earningsMtd, c.currency),
                        color: const Color(0xff27AE60),
                      ),
                      _KpiCard(
                        notifire: notifire,
                        icon: Icons.star_outline,
                        label: "Average rating".tr,
                        value: c.isLoading
                            ? '—'
                            : (c.avgRating == null
                                ? "No reviews".tr
                                : c.avgRating!.toStringAsFixed(1)),
                        color: const Color(0xffF2C94C),
                      ),
                    ];
                    if (isWide) {
                      return Row(
                        children: cards
                            .map((card) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: card,
                                  ),
                                ))
                            .toList(),
                      );
                    }
                    return Column(
                      children: cards
                          .map((card) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: card,
                              ))
                          .toList(),
                    );
                  }),

                  const SizedBox(height: 24),

                  // ----- Recent bookings -----
                  Row(
                    children: [
                      Text(
                        "Recent bookings".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          color: notifire.getwhiteblackcolor,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      if (!c.isLoading && c.recentBookings.isNotEmpty)
                        TextButton(
                          onPressed: () =>
                              Get.toNamed(Routes.mybookingScreen),
                          style: TextButton.styleFrom(
                              foregroundColor: blueColor,
                              padding: EdgeInsets.zero),
                          child: Text("See all".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 12,
                              )),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (c.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (c.recentBookings.isEmpty)
                    _EmptyBookings(notifire: notifire)
                  else
                    ...c.recentBookings.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _BookingRow(
                            notifire: notifire,
                            booking: b,
                            currency: c.currency,
                          ),
                        )),

                  const SizedBox(height: 24),

                  // ----- Quick actions -----
                  Text(
                    "Quick actions".tr,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      color: notifire.getwhiteblackcolor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    notifire: notifire,
                    icon: Icons.add_business_outlined,
                    title: "Add a new service".tr,
                    subtitle: "Publish a homecare or property listing.".tr,
                    onTap: () =>
                        Get.toNamed(Routes.membershipScreen),
                  ),
                  const SizedBox(height: 8),
                  _ActionTile(
                    notifire: notifire,
                    icon: Icons.list_alt_outlined,
                    title: "My listings".tr,
                    subtitle: c.totalListings == 0
                        ? "No listings yet — add your first service.".tr
                        : "${c.totalListings} ${'active listings'.tr}",
                    onTap: () {
                      Get.snackbar(
                        "Listings".tr,
                        "Listings management UI is coming soon.".tr,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _ActionTile(
                    notifire: notifire,
                    icon: Icons.account_balance_wallet_outlined,
                    title: "Request payout".tr,
                    subtitle: c.earningsMtd > 0
                        ? "${_formatCurrency(c.earningsMtd, c.currency)} ${'available this month'.tr}"
                        : "Withdraw available earnings to your account.".tr,
                    onTap: () => Get.toNamed(Routes.walletScreen),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  final ColorNotifire notifire;
  const _EmptyBookings({required this.notifire});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifire.getboxcolor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifire.getborderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              size: 36, color: notifire.getgreycolor),
          const SizedBox(height: 8),
          Text(
            "No bookings yet".tr,
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              fontSize: 14,
              color: notifire.getwhiteblackcolor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Bookings will appear here once families reach out.".tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 12,
              color: notifire.getgreycolor,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  final ColorNotifire notifire;
  final RecentBooking booking;
  final String currency;

  const _BookingRow({
    required this.notifire,
    required this.booking,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notifire.getboxcolor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifire.getborderColor),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: blueColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              booking.type == 'homecare'
                  ? Icons.medical_services_outlined
                  : Icons.home_outlined,
              color: blueColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.title.isEmpty ? "Booking".tr : booking.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    fontSize: 13,
                    color: notifire.getwhiteblackcolor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (booking.customerName.isNotEmpty) booking.customerName,
                    if (booking.bookDate.isNotEmpty) booking.bookDate,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyMedium,
                    fontSize: 11,
                    color: notifire.getgreycolor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(booking.amount, currency),
                style: TextStyle(
                  fontFamily: FontFamily.gilroyBold,
                  fontSize: 13,
                  color: notifire.getwhiteblackcolor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.status.isEmpty ? '—' : booking.status.tr,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    fontSize: 10,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final ColorNotifire notifire;
  final IconData icon;
  final String label;
  final String value;
  final String? sub;
  final Color color;

  const _KpiCard({
    required this.notifire,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifire.getboxcolor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: notifire.getborderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              fontSize: 22,
              color: notifire.getwhiteblackcolor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 12,
              color: notifire.getgreycolor,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(
              sub!,
              style: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final ColorNotifire notifire;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.notifire,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notifire.getboxcolor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: notifire.getborderColor),
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: blueColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: blueColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      fontSize: 14,
                      color: notifire.getwhiteblackcolor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      fontSize: 12,
                      color: notifire.getgreycolor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: notifire.getgreycolor),
          ],
        ),
      ),
    );
  }
}
