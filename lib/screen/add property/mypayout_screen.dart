// ignore_for_file: prefer_const_constructors, unnecessary_brace_in_string_interps, sort_child_properties_last, non_constant_identifier_names, prefer_const_literals_to_create_immutables

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/dashboard_controller.dart';
import 'package:gotocarefinder/controller/payout_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_screen.dart';

class MyPayoutScreen extends StatefulWidget {
  const MyPayoutScreen({super.key});

  @override
  State<MyPayoutScreen> createState() => _MyPayoutScreenState();
}

const List<String> payType = ["UPI", "BANK Transfer", "Paypal"];

class _MyPayoutScreenState extends State<MyPayoutScreen> {
  final DashBoardController dashBoardController = Get.find();
  final PayOutController payOutController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectType;

  late ColorNotifire notifire;

  Future<void> getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    notifire.setIsDark = prefs.getBool("setIsDark") ?? false;
  }

  @override
  void initState() {
    super.initState();
    payOutController.getPayOutList();
    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    final media = MediaQuery.of(context);
    final isWide = media.size.width >= 900;
    final horizontalPad = isWide ? 24.0 : 12.0;

    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        leading: BackButton(
          color: notifire.getwhiteblackcolor,
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Payout".tr,
          style: TextStyle(
            color: notifire.getwhiteblackcolor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 17,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await payOutController.getPayOutList();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wallet header — flexible height & cover image
                      _WalletHeader(
                        notifire: notifire,
                        total: "${currency}${dashBoardController.payOut}",
                      ),

                      SizedBox(height: 12),
                      Padding(
                        padding: EdgeInsets.only(left: isWide ? 4 : 8),
                        child: Text(
                          "History".tr,
                          style: TextStyle(
                            fontSize: 17,
                            color: notifire.getwhiteblackcolor,
                            fontFamily: FontFamily.gilroyMedium,
                          ),
                        ),
                      ),

                      // History list
                      Expanded(
                        child: GetBuilder<PayOutController>(builder: (_) {
                          if (!payOutController.isLoading) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final list = payOutController.payoutInfo?.payoutlist ?? [];
                          if (list.isEmpty) {
                            return _EmptyHistory(notifire: notifire);
                          }

                          return Scrollbar(
                            thumbVisibility: isWide,
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                              itemCount: list.length,
                              separatorBuilder: (_, __) => SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final item = list[index];
                                final isPending = (item.status ?? "").toLowerCase() == "pending";
                                final statusColor = isPending ? Colors.red : Color(0xFF398B2B);

                                return InkWell(
                                  onTap: () => _openPayoutDetails(context, index, statusColor),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: notifire.getborderColor),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      leading: Container(
                                        height: 56,
                                        width: 56,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: Color(0xFFf6f7f9),
                                        ),
                                        child: Image.asset("assets/images/Wallet.png", color: blueColor),
                                      ),
                                      title: Text(
                                        item.rDate.toString() ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: notifire.getwhiteblackcolor,
                                          fontFamily: FontFamily.gilroyBold,
                                        ),
                                      ),
                                      subtitle: Wrap(
                                        spacing: 10,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            item.rType.toString() ?? "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: notifire.getwhiteblackcolor,
                                              fontFamily: FontFamily.gilroyMedium,
                                            ),
                                          ),
                                          Text(
                                            item.status ?? "",
                                            style: TextStyle(
                                              color: statusColor,
                                              fontFamily: FontFamily.gilroyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Text(
                                        "${item.amt}$currency",
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyBold,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      ),

                      // Request button
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: GestButton(
                            Width: double.infinity,
                            height: 50,
                            buttoncolor: blueColor,
                            margin: EdgeInsets.symmetric(horizontal: isWide ? 120 : 12),
                            buttontext: "Request".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              color: WhiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            onclick: _openRequestSheetResponsive,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------- Request Sheet / Dialog (responsive) ----------
  Future<void> _openRequestSheetResponsive() async {
    if (kIsWeb ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux) {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => Dialog(
          backgroundColor: notifire.getbgcolor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: _RequestForm(
                notifire: notifire,
                formKey: _formKey,
                selectType: selectType,
                onTypeChanged: (v) => setState(() => selectType = v),
                onCancel: () {
                  payOutController.emptyDetails();
                  Navigator.of(context).pop();
                },
                onProceed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (selectType != null) {
                      payOutController.requestWithdraweApi(rType: selectType);
                      Navigator.of(context).pop();
                    } else {
                      showToastMessage("Please Select Type".tr);
                    }
                  }
                },
                dashBoardController: dashBoardController,
                payOutController: payOutController,
              ),
            ),
          ),
        ),
      );
    } else {
      await Get.bottomSheet(
        _RequestForm(
          notifire: notifire,
          formKey: _formKey,
          selectType: selectType,
          onTypeChanged: (v) => setState(() => selectType = v),
          onCancel: () {
            payOutController.emptyDetails();
            Get.back();
          },
          onProceed: () {
            if (_formKey.currentState?.validate() ?? false) {
              if (selectType != null) {
                payOutController.requestWithdraweApi(rType: selectType);
                Get.back();
              } else {
                showToastMessage("Please Select Type".tr);
              }
            }
          },
          dashBoardController: dashBoardController,
          payOutController: payOutController,
        ),
        backgroundColor: notifire.getbgcolor,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      );
    }
  }

  // ---------- Payout details (sheet on mobile, dialog on web) ----------
  void _openPayoutDetails(BuildContext context, int index, Color statusColor) {
    final item = payOutController.payoutInfo!.payoutlist[index];

    final content = SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          SizedBox(height: 12),
          Text(
            "Payout Request".tr,
            style: TextStyle(
              color: notifire.getwhiteblackcolor,
              fontFamily: FontFamily.gilroyBold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 12),
          detailsRow(detailsName: "Status", value: item.status, color: statusColor),
          detailsRow(detailsName: "Transaction Date".tr, value: item.rDate.toString(), color: notifire.getwhiteblackcolor),
          if ((item.upiId ?? "").isNotEmpty)
            detailsRow(detailsName: "Payment Method".tr, value: item.upiId, color: notifire.getwhiteblackcolor),
          if ((item.accNumber ?? "").isNotEmpty)
            detailsRow(detailsName: "Account Number".tr, value: item.accNumber, color: notifire.getwhiteblackcolor),
          if ((item.accName ?? "").isNotEmpty)
            detailsRow(detailsName: "Account holder name".tr, value: item.accName, color: notifire.getwhiteblackcolor),
          if ((item.bankName ?? "").isNotEmpty)
            detailsRow(detailsName: "Bank Name".tr, value: item.bankName, color: notifire.getwhiteblackcolor),
          if ((item.ifscCode ?? "").isNotEmpty)
            detailsRow(detailsName: "Bank IFSC".tr, value: item.ifscCode, color: notifire.getwhiteblackcolor),
          if ((item.paypalId ?? "").isNotEmpty)
            detailsRow(detailsName: "Payment Method", value: item.paypalId, color: notifire.getwhiteblackcolor),
          Container(
            height: 44,
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  "Total".tr,
                  style: TextStyle(
                    color: Color(0xFF808080),
                    fontFamily: FontFamily.gilroyBold,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Spacer(),
                Text(
                  "${currency}${item.amt}",
                  style: TextStyle(
                    color: notifire.getwhiteblackcolor,
                    fontFamily: FontFamily.gilroyBold,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          if (item.proof != null) ...[
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  "Payout Proof".tr,
                  style: TextStyle(
                    color: notifire.getwhiteblackcolor,
                    fontFamily: FontFamily.gilroyBold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "${Config.imageUrl}${item.proof}",
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (kIsWeb) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: notifire.getbgcolor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: content,
            ),
          ),
        ),
      );
    } else {
      Get.bottomSheet(
        SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: notifire.getbgcolor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: content,
          ),
        ),
        isScrollControlled: true,
      );
    }
  }

  // Original details row (kept), with minor overflow safety
  Widget detailsRow({String? detailsName, value, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              detailsName ?? "",
              style: TextStyle(
                color: Color(0xFF808080),
                fontFamily: FontFamily.gilroyMedium,
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(width: 12),
          Flexible(
            child: Text(
              value ?? "",
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontFamily: FontFamily.gilroyBold,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================== Sub-widgets ==================

class _WalletHeader extends StatelessWidget {
  const _WalletHeader({required this.notifire, required this.total});
  final ColorNotifire notifire;
  final String total;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final cardHeight = isWide ? 220.0 : 200.0;

    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: cardHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/walletIMage.png"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.05),
                BlendMode.srcATop,
              ),
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16, vertical: 16),
            alignment: Alignment.topLeft,
            child: DefaultTextStyle(
              style: TextStyle(color: WhiteColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isWide ? 8 : 4),
                  Text(
                    "Payout".tr,
                    style: TextStyle(
                      fontSize: isWide ? 24 : 22,
                      fontFamily: FontFamily.gilroyBold,
                      color: WhiteColor,
                    ),
                  ),
                  Spacer(),
                  Text(
                    total,
                    style: TextStyle(
                      fontSize: isWide ? 48 : 42,
                      fontFamily: FontFamily.gilroyBold,
                      color: WhiteColor,
                    ),
                  ),
                  Text(
                    "Your total earning".tr,
                    style: TextStyle(
                      fontSize: isWide ? 20 : 18,
                      fontFamily: FontFamily.gilroyBold,
                      color: WhiteColor,
                    ),
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

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.notifire});
  final ColorNotifire notifire;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(bottom: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/bookingEmpty.png", height: 120, width: 110, fit: BoxFit.contain),
            SizedBox(height: 16),
            Text(
              "Go & Request your Payout".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: notifire.getgreycolor,
                fontFamily: FontFamily.gilroyBold,
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Request form extracted for reuse (sheet/dialog)
class _RequestForm extends StatefulWidget {
  const _RequestForm({
    required this.notifire,
    required this.formKey,
    required this.selectType,
    required this.onTypeChanged,
    required this.onCancel,
    required this.onProceed,
    required this.dashBoardController,
    required this.payOutController,
  });

  final ColorNotifire notifire;
  final GlobalKey<FormState> formKey;
  final String? selectType;
  final ValueChanged<String?> onTypeChanged;
  final VoidCallback onCancel;
  final VoidCallback onProceed;
  final DashBoardController dashBoardController;
  final PayOutController payOutController;

  @override
  State<_RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<_RequestForm> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isGrid = width >= 720;

    return SafeArea(
      top: false,
      child: Form(
        key: widget.formKey,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 6),
                Text(
                  "Payout Request".tr,
                  style: TextStyle(
                    color: widget.notifire.getwhiteblackcolor,
                    fontFamily: FontFamily.gilroyBold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                Divider(height: 1),
                SizedBox(height: 10),
                Text(
                  "${"Minimum amount:".tr} ${widget.dashBoardController.dashBoardInfo?.withdrawLimit}${currency}",
                  style: TextStyle(
                    color: widget.notifire.getwhiteblackcolor,
                    fontFamily: FontFamily.gilroyMedium,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 12),

                // Amount
                _textfield(
                  notifire: widget.notifire,
                  controller: widget.payOutController.amount,
                  labelText: "Amount".tr,
                  textInputType: TextInputType.number,
                  validator: (v) => (v == null || v.isEmpty) ? 'Please Enter Amount'.tr : null,
                ),

                SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 6, top: 6),
                    child: Text(
                      "Select Type".tr,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 16,
                        color: widget.notifire.getwhiteblackcolor,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 56,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: widget.notifire.getblackwhitecolor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: widget.selectType,
                    dropdownColor: widget.notifire.getbgcolor,
                    underline: SizedBox.shrink(),
                    icon: Image.asset(
                      'assets/images/Arrow - Down.png',
                      height: 20,
                      width: 20,
                      color: widget.notifire.getwhiteblackcolor,
                    ),
                    hint: Text("Select Type".tr, style: TextStyle(color: Colors.grey)),
                    items: payType
                        .map((value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyMedium,
                          color: widget.notifire.getwhiteblackcolor,
                          fontSize: 14,
                        ),
                      ),
                    ))
                        .toList(),
                    onChanged: widget.onTypeChanged,
                  ),
                ),

                // Dynamic fields
                if (widget.selectType == "UPI") ...[
                  _sectionLabel("UPI".tr, widget.notifire),
                  _textfield(
                    notifire: widget.notifire,
                    controller: widget.payOutController.upi,
                    labelText: "UPI".tr,
                    validator: (v) => (v == null || v.isEmpty) ? 'Please Enter UPI'.tr : null,
                  ),
                ] else if (widget.selectType == "BANK Transfer") ...[
                  _sectionLabel("Bank Details".tr, widget.notifire),
                  _ResponsiveGrid(
                    twoCols: isGrid,
                    children: [
                      _textfield(
                        notifire: widget.notifire,
                        controller: widget.payOutController.accountNumber,
                        labelText: "Account Number".tr,
                        textInputType: TextInputType.number,
                        validator: (v) => (v == null || v.isEmpty) ? 'Please Enter Account Number'.tr : null,
                      ),
                      _textfield(
                        notifire: widget.notifire,
                        controller: widget.payOutController.bankName,
                        labelText: "Bank Name".tr,
                        validator: (v) => (v == null || v.isEmpty) ? 'Please Enter Bank Name'.tr : null,
                      ),
                      _textfield(
                        notifire: widget.notifire,
                        controller: widget.payOutController.accountHolderName,
                        labelText: "Account Holder Name".tr,
                        validator: (v) => (v == null || v.isEmpty) ? 'Please Enter Account Holder Name'.tr : null,
                      ),
                      _textfield(
                        notifire: widget.notifire,
                        controller: widget.payOutController.ifscCode,
                        labelText: "IFSC Code".tr,
                        validator: (v) => (v == null || v.isEmpty) ? 'Please Enter IFSC Code'.tr : null,
                      ),
                    ],
                  ),
                ] else if (widget.selectType == "Paypal") ...[
                  _sectionLabel("Paypal".tr, widget.notifire),
                  _textfield(
                    notifire: widget.notifire,
                    controller: widget.payOutController.ifscCode, // kept as in your original
                    labelText: "Email Id".tr,
                    validator: (v) => (v == null || v.isEmpty) ? 'Please Enter Paypal id'.tr : null,
                  ),
                ],

                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: widget.onCancel,
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFFeef4ff),
                            borderRadius: BorderRadius.circular(45),
                          ),
                          child: Text(
                            "Cancel".tr,
                            style: TextStyle(
                              color: blueColor,
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: widget.onProceed,
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(45),
                          ),
                          child: Text(
                            "Proceed".tr,
                            style: TextStyle(
                              color: WhiteColor,
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, ColorNotifire notifire) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(left: 6, top: 12, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: FontFamily.gilroyBold,
          fontSize: 16,
          color: notifire.getwhiteblackcolor,
        ),
      ),
    ),
  );
}

// Simple grid: 2 columns on wide, single on narrow
class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.twoCols, required this.children});
  final bool twoCols;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!twoCols) {
      return Column(
        children: children
            .map((w) => Padding(padding: EdgeInsets.only(bottom: 8), child: w))
            .toList(),
      );
    }
    return LayoutBuilder(
      builder: (context, c) {
        final itemW = (c.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 8,
          children: children.map((w) => SizedBox(width: itemW, child: w)).toList(),
        );
      },
    );
  }
}

// Themed textfield helper (uses your styles)
Widget _textfield({
  required ColorNotifire notifire,
  String? labelText,
  TextEditingController? controller,
  TextInputType? textInputType,
  String? Function(String?)? validator,
  Function(String)? onChanged,
  bool? readOnly,
  int? max,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: notifire.getblackwhitecolor,
    ),
    child: TextFormField(
      controller: controller,
      onChanged: onChanged,
      cursorColor: notifire.getwhiteblackcolor,
      keyboardType: textInputType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLength: max,
      readOnly: readOnly ?? false,
      style: TextStyle(
        color: notifire.getwhiteblackcolor,
        fontFamily: FontFamily.gilroyMedium,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        counterText: "",
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintText: labelText,
        hintStyle: TextStyle(color: Colors.grey, fontFamily: "Gilroy Medium", fontSize: 16),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: blueColor),
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      validator: validator,
    ),
  );
}



// // ignore_for_file: prefer_const_constructors, unnecessary_brace_in_string_interps, sort_child_properties_last, non_constant_identifier_names, prefer_const_literals_to_create_immutables
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/controller/dashboard_controller.dart';
// import 'package:gotocarefinder/controller/payout_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/screen/home_screen.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Custom_widget.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class MyPayoutScreen extends StatefulWidget {
//   const MyPayoutScreen({super.key});
//
//   @override
//   State<MyPayoutScreen> createState() => _MyPayoutScreenState();
// }
//
// List<String> payType = ["UPI", "BANK Transfer", "Paypal"];
//
// class _MyPayoutScreenState extends State<MyPayoutScreen> {
//   DashBoardController dashBoardController = Get.find();
//   PayOutController payOutController = Get.find();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   String? selectType;
//
//   late ColorNotifire notifire;
//   getdarkmodepreviousstate() async {
//     final prefs = await SharedPreferences.getInstance();
//     bool? previusstate = prefs.getBool("setIsDark");
//     if (previusstate == null) {
//       notifire.setIsDark = false;
//     } else {
//       notifire.setIsDark = previusstate;
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     getdarkmodepreviousstate();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//     return Scaffold(
//       backgroundColor: notifire.getbgcolor,
//       appBar: AppBar(
//         backgroundColor: notifire.getbgcolor,
//         elevation: 0,
//         leading: BackButton(
//           color: notifire.getwhiteblackcolor,
//           onPressed: () {
//             Get.back();
//           },
//         ),
//         title: Text(
//           "Payout".tr,
//           style: TextStyle(
//             color: notifire.getwhiteblackcolor,
//             fontFamily: FontFamily.gilroyBold,
//             fontSize: 17,
//           ),
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: () {
//           return Future.delayed(
//             Duration(seconds: 2),
//             () {
//               payOutController.getPayOutList();
//             },
//           );
//         },
//         child: SizedBox(
//           height: Get.size.height,
//           width: Get.size.width,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: Get.height * 0.28,
//                 width: Get.size.width,
//                 margin: EdgeInsets.only(left: 15, top: 15, right: 15),
//                 alignment: Alignment.topLeft,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: 30),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 0, left: 15),
//                       child: Text(
//                         "Payout".tr,
//                         textAlign: TextAlign.start,
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontFamily: FontFamily.gilroyBold,
//                           color: WhiteColor,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 40),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 10, left: 15),
//                       child: Text(
//                         "${currency}${dashBoardController.payOut}",
//                         textAlign: TextAlign.start,
//                         style: TextStyle(
//                           fontSize: 45,
//                           fontFamily: FontFamily.gilroyBold,
//                           color: WhiteColor,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 0, left: 15),
//                       child: Text(
//                         "Your total earning".tr,
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontFamily: FontFamily.gilroyBold,
//                           color: WhiteColor,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage("assets/images/walletIMage.png"),
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 10, left: 25),
//                 child: Text(
//                   "History".tr,
//                   style: TextStyle(
//                     fontSize: 17,
//                     color: notifire.getwhiteblackcolor,
//                     fontFamily: FontFamily.gilroyMedium,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: GetBuilder<PayOutController>(builder: (context) {
//                   return payOutController.isLoading
//                       ? payOutController.payoutInfo!.payoutlist.isNotEmpty
//                           ? ListView.builder(
//                               itemCount: payOutController
//                                   .payoutInfo?.payoutlist.length,
//                               itemBuilder: (context, index) {
//                                 return InkWell(
//                                   onTap: () {
//                                     Get.bottomSheet(
//                                       Container(
//                                         height: Get.size.height * 0.5,
//                                         width: Get.size.width,
//                                         child: SingleChildScrollView(
//                                           physics: BouncingScrollPhysics(),
//                                           child: Column(
//                                             children: [
//                                               SizedBox(
//                                                 height: 10,
//                                               ),
//                                               Text(
//                                                 "Payout Request".tr,
//                                                 style: TextStyle(
//                                                   color: notifire
//                                                       .getwhiteblackcolor,
//                                                   fontFamily:
//                                                       FontFamily.gilroyBold,
//                                                   fontSize: 17,
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 height: 10,
//                                               ),
//                                               detailsRow(
//                                                 detailsName: "Status",
//                                                 value: payOutController
//                                                     .payoutInfo
//                                                     ?.payoutlist[index]
//                                                     .status,
//                                                 color: payOutController
//                                                             .payoutInfo
//                                                             ?.payoutlist[index]
//                                                             .status ==
//                                                         "pending"
//                                                     ? Colors.red
//                                                     : Color(0xFF398B2B),
//                                               ),
//                                               detailsRow(
//                                                 detailsName:
//                                                     "Transaction Date".tr,
//                                                 value: payOutController
//                                                     .payoutInfo
//                                                     ?.payoutlist[index]
//                                                     .rDate
//                                                     .toString(),
//                                                 color:
//                                                     notifire.getwhiteblackcolor,
//                                               ),
//                                               payOutController
//                                                           .payoutInfo
//                                                           ?.payoutlist[index]
//                                                           .upiId !=
//                                                       ""
//                                                   ? detailsRow(
//                                                       detailsName:
//                                                           "Payment Method".tr,
//                                                       value: payOutController
//                                                           .payoutInfo
//                                                           ?.payoutlist[index]
//                                                           .upiId,
//                                                       color: notifire
//                                                           .getwhiteblackcolor,
//                                                     )
//                                                   : SizedBox(),
//                                               payOutController
//                                                           .payoutInfo
//                                                           ?.payoutlist[index]
//                                                           .accNumber !=
//                                                       ""
//                                                   ? detailsRow(
//                                                       detailsName:
//                                                           "Account Number".tr,
//                                                       value: payOutController
//                                                           .payoutInfo
//                                                           ?.payoutlist[index]
//                                                           .accNumber,
//                                                       color: notifire
//                                                           .getwhiteblackcolor,
//                                                     )
//                                                   : SizedBox(),
//                                               payOutController
//                                                           .payoutInfo
//                                                           ?.payoutlist[index]
//                                                           .accName !=
//                                                       ""
//                                                   ? detailsRow(
//                                                       detailsName:
//                                                           "Account holder name"
//                                                               .tr,
//                                                       value: payOutController
//                                                           .payoutInfo
//                                                           ?.payoutlist[index]
//                                                           .accName,
//                                                       color: notifire
//                                                           .getwhiteblackcolor,
//                                                     )
//                                                   : SizedBox(),
//                                               payOutController
//                                                           .payoutInfo
//                                                           ?.payoutlist[index]
//                                                           .bankName !=
//                                                       ""
//                                                   ? detailsRow(
//                                                       detailsName:
//                                                           "Bank Name".tr,
//                                                       value: payOutController
//                                                           .payoutInfo
//                                                           ?.payoutlist[index]
//                                                           .bankName,
//                                                       color: notifire
//                                                           .getwhiteblackcolor,
//                                                     )
//                                                   : SizedBox(),
//                                               payOutController
//                                                           .payoutInfo
//                                                           ?.payoutlist[index]
//                                                           .ifscCode !=
//                                                       ""
//                                                   ? detailsRow(
//                                                       detailsName:
//                                                           "Bank IFSC".tr,
//                                                       value: payOutController
//                                                           .payoutInfo
//                                                           ?.payoutlist[index]
//                                                           .ifscCode,
//                                                       color: notifire
//                                                           .getwhiteblackcolor,
//                                                     )
//                                                   : SizedBox(),
//                                               payOutController
//                                                           .payoutInfo
//                                                           ?.payoutlist[index]
//                                                           .paypalId !=
//                                                       ""
//                                                   ? detailsRow(
//                                                       detailsName:
//                                                           "Payment Method",
//                                                       value: payOutController
//                                                           .payoutInfo
//                                                           ?.payoutlist[index]
//                                                           .paypalId,
//                                                       color: notifire
//                                                           .getwhiteblackcolor,
//                                                     )
//                                                   : SizedBox(),
//                                               Container(
//                                                 height: 40,
//                                                 width: Get.size.width,
//                                                 margin: EdgeInsets.symmetric(
//                                                     horizontal: 15),
//                                                 child: Row(
//                                                   children: [
//                                                     SizedBox(
//                                                       width: 10,
//                                                     ),
//                                                     Text(
//                                                       "Total".tr,
//                                                       style: TextStyle(
//                                                         color:
//                                                             Color(0xFF808080),
//                                                         fontFamily: FontFamily
//                                                             .gilroyBold,
//                                                         fontWeight:
//                                                             FontWeight.w600,
//                                                         fontSize: 15,
//                                                       ),
//                                                     ),
//                                                     Spacer(),
//                                                     Text(
//                                                       "${currency}${payOutController.payoutInfo?.payoutlist[index].amt}",
//                                                       style: TextStyle(
//                                                         color: notifire
//                                                             .getwhiteblackcolor,
//                                                         fontFamily: FontFamily
//                                                             .gilroyBold,
//                                                         fontWeight:
//                                                             FontWeight.w600,
//                                                         fontSize: 15,
//                                                       ),
//                                                     ),
//                                                     SizedBox(
//                                                       width: 10,
//                                                     )
//                                                   ],
//                                                 ),
//                                                 decoration: BoxDecoration(
//                                                   border: Border.all(
//                                                       color:
//                                                           Colors.grey.shade200),
//                                                   borderRadius:
//                                                       BorderRadius.circular(10),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 height: 15,
//                                               ),
//                                               payOutController
//                                                           .payoutInfo
//                                                           ?.payoutlist[index]
//                                                           .proof !=
//                                                       null
//                                                   ? Container(
//                                                       alignment:
//                                                           Alignment.topLeft,
//                                                       margin: EdgeInsets.only(
//                                                           left: 15),
//                                                       child: Text(
//                                                         "Payout Proof".tr,
//                                                         style: TextStyle(
//                                                           color: notifire
//                                                               .getwhiteblackcolor,
//                                                           fontFamily: FontFamily
//                                                               .gilroyBold,
//                                                         ),
//                                                       ),
//                                                     )
//                                                   : SizedBox(),
//                                               payOutController
//                                                           .payoutInfo
//                                                           ?.payoutlist[index]
//                                                           .proof !=
//                                                       null
//                                                   ? Padding(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               8.0),
//                                                       child: Image.network(
//                                                         "${Config.imageUrl}${payOutController.payoutInfo?.payoutlist[index].proof}",
//                                                         height: 100,
//                                                         width: Get.size.width,
//                                                         fit: BoxFit.fill,
//                                                       ),
//                                                     )
//                                                   : SizedBox(),
//                                             ],
//                                           ),
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: notifire.getbgcolor,
//                                           borderRadius: BorderRadius.only(
//                                             topLeft: Radius.circular(30),
//                                             topRight: Radius.circular(30),
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   child: Container(
//                                     margin: EdgeInsets.all(10),
//                                     child: ListTile(
//                                       leading: Container(
//                                         height: 70,
//                                         width: 60,
//                                         padding: EdgeInsets.all(12),
//                                         child: Image.asset(
//                                           "assets/images/Wallet.png",
//                                           color: blueColor,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(10),
//                                           color: Color(0xFFf6f7f9),
//                                         ),
//                                       ),
//                                       title: Text(
//                                         payOutController.payoutInfo
//                                                 ?.payoutlist[index].rDate
//                                                 .toString() ??
//                                             "",
//                                         maxLines: 1,
//                                         style: TextStyle(
//                                           color: notifire.getwhiteblackcolor,
//                                           fontFamily: FontFamily.gilroyBold,
//                                           // fontSize: 16,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       subtitle: Row(
//                                         children: [
//                                           Text(
//                                             payOutController.payoutInfo
//                                                     ?.payoutlist[index].rType
//                                                     .toString() ??
//                                                 "",
//                                             maxLines: 1,
//                                             style: TextStyle(
//                                               color:
//                                                   notifire.getwhiteblackcolor,
//                                               fontFamily:
//                                                   FontFamily.gilroyMedium,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             width: 10,
//                                           ),
//                                           Text(
//                                             payOutController
//                                                     .payoutInfo
//                                                     ?.payoutlist[index]
//                                                     .status ??
//                                                 "",
//                                             style: TextStyle(
//                                               color: payOutController
//                                                           .payoutInfo
//                                                           ?.payoutlist[index]
//                                                           .status ==
//                                                       "pending"
//                                                   ? Colors.red
//                                                   : Color(0xFF398B2B),
//                                               fontFamily:
//                                                   FontFamily.gilroyMedium,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       trailing: TextButton(
//                                         onPressed: () {},
//                                         child: Text(
//                                           "${payOutController.payoutInfo?.payoutlist[index].amt}${currency}",
//                                           style: TextStyle(
//                                             fontFamily: FontFamily.gilroyBold,
//                                             color: payOutController
//                                                         .payoutInfo
//                                                         ?.payoutlist[index]
//                                                         .status ==
//                                                     "pending"
//                                                 ? Colors.red
//                                                 : Color(0xFF398B2B),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                           color: notifire.getborderColor),
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             )
//                           : Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(left: 30),
//                                     child: Image.asset(
//                                       "assets/images/bookingEmpty.png",
//                                       height: 110,
//                                       width: 100,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 20,
//                                   ),
//                                   Text(
//                                     "Go & Request your Payout".tr,
//                                     style: TextStyle(
//                                       color: notifire.getgreycolor,
//                                       fontFamily: FontFamily.gilroyBold,
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             )
//                       : Center(
//                           child: CircularProgressIndicator(),
//                         );
//                 }),
//               ),
//               GestButton(
//                 Width: Get.size.width,
//                 height: 50,
//                 buttoncolor: blueColor,
//                 margin: EdgeInsets.only(top: 15, left: 35, right: 35),
//                 buttontext: "Request".tr,
//                 style: TextStyle(
//                   fontFamily: FontFamily.gilroyBold,
//                   color: WhiteColor,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 onclick: () {
//                   requestSheet();
//                 },
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget detailsRow({String? detailsName, value, Color? color}) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             SizedBox(
//               width: 15,
//             ),
//             Text(
//               detailsName ?? "",
//               style: TextStyle(
//                 color: Color(0xFF808080),
//                 fontFamily: FontFamily.gilroyMedium,
//                 fontWeight: FontWeight.w400,
//                 fontSize: 15,
//               ),
//             ),
//             Spacer(),
//             Text(
//               value ?? "",
//               style: TextStyle(
//                 color: color,
//                 fontFamily: FontFamily.gilroyBold,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 15,
//               ),
//             ),
//             SizedBox(
//               width: 15,
//             ),
//           ],
//         ),
//         SizedBox(
//           height: 15,
//         ),
//       ],
//     );
//   }
//
//   Future<void> requestSheet() {
//     return Get.bottomSheet(
//       StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
//         return Form(
//           key: _formKey,
//           child: Container(
//             height: Get.size.height * 0.6,
//             width: Get.size.width,
//             child: SingleChildScrollView(
//               physics: BouncingScrollPhysics(),
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 15,
//                   ),
//                   Text(
//                     "Payout Request".tr,
//                     style: TextStyle(
//                       color: notifire.getwhiteblackcolor,
//                       fontFamily: FontFamily.gilroyBold,
//                       fontSize: 20,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Divider(),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     "${"Minimum amount:".tr} ${dashBoardController.dashBoardInfo?.withdrawLimit}${currency}",
//                     style: TextStyle(
//                       color: notifire.getwhiteblackcolor,
//                       fontFamily: FontFamily.gilroyMedium,
//                       fontSize: 16,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   textfield(
//                     controller: payOutController.amount,
//                     labelText: "Amount".tr,
//                     textInputType: TextInputType.number,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please Enter Amount'.tr;
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(
//                     height: 8,
//                   ),
//                   Container(
//                     alignment: Alignment.topLeft,
//                     margin: EdgeInsets.only(left: 15),
//                     child: Text(
//                       "Select Type".tr,
//                       style: TextStyle(
//                         fontFamily: FontFamily.gilroyBold,
//                         fontSize: 16,
//                         color: notifire.getwhiteblackcolor,
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 8,
//                   ),
//                   Container(
//                     height: 60,
//                     width: Get.size.width,
//                     alignment: Alignment.center,
//                     margin: EdgeInsets.symmetric(horizontal: 10),
//                     padding: EdgeInsets.only(left: 15, right: 15),
//                     child: DropdownButton(
//                       dropdownColor: notifire.getbgcolor,
//                       hint: Text(
//                         "Select Type".tr,
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                       value: selectType,
//                       icon: Image.asset(
//                         'assets/images/Arrow - Down.png',
//                         height: 20,
//                         width: 20,
//                         color: notifire.getwhiteblackcolor,
//                       ),
//                       isExpanded: true,
//                       underline: SizedBox.shrink(),
//                       items:
//                           payType.map<DropdownMenuItem<String>>((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(
//                             value,
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyMedium,
//                               color: notifire.getwhiteblackcolor,
//                               fontSize: 14,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           selectType = value ?? "";
//                         });
//                       },
//                     ),
//                     decoration: BoxDecoration(
//                       color: notifire.getblackwhitecolor,
//                       borderRadius: BorderRadius.circular(15),
//                       border: Border.all(color: Colors.grey),
//                     ),
//                   ),
//                   selectType == "UPI"
//                       ? Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15),
//                               child: Text(
//                                 "UPI".tr,
//                                 style: TextStyle(
//                                   fontFamily: FontFamily.gilroyBold,
//                                   fontSize: 16,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 6,
//                             ),
//                             textfield(
//                               controller: payOutController.upi,
//                               labelText: "UPI".tr,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please Enter UPI'.tr;
//                                 }
//                                 return null;
//                               },
//                             )
//                           ],
//                         )
//                       : selectType == "BANK Transfer"
//                           ? Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 15),
//                                   child: Text(
//                                     "Account Number".tr,
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyBold,
//                                       fontSize: 16,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   height: 6,
//                                 ),
//                                 textfield(
//                                   controller: payOutController.accountNumber,
//                                   labelText: "Account Number".tr,
//                                   textInputType: TextInputType.number,
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Please Enter Account Number'.tr;
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 15),
//                                   child: Text(
//                                     "Bank Name".tr,
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyBold,
//                                       fontSize: 16,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   height: 6,
//                                 ),
//                                 textfield(
//                                   controller: payOutController.bankName,
//                                   labelText: "Bank Name".tr,
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Please Enter Bank Name'.tr;
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 15),
//                                   child: Text(
//                                     "Account Holder Name".tr,
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyBold,
//                                       fontSize: 16,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   height: 6,
//                                 ),
//                                 textfield(
//                                   controller:
//                                       payOutController.accountHolderName,
//                                   labelText: "Account Holder Name".tr,
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Please Enter Account Holder Name'
//                                           .tr;
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 15),
//                                   child: Text(
//                                     "IFSC Code".tr,
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyBold,
//                                       fontSize: 16,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   height: 6,
//                                 ),
//                                 textfield(
//                                   controller: payOutController.ifscCode,
//                                   labelText: "IFSC Code".tr,
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Please Enter IFSC Code'.tr;
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                               ],
//                             )
//                           : selectType == "Paypal"
//                               ? Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 15),
//                                       child: Text(
//                                         "Email ID".tr,
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyBold,
//                                           fontSize: 16,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       height: 6,
//                                     ),
//                                     textfield(
//                                       controller: payOutController.ifscCode,
//                                       labelText: "Email Id".tr,
//                                       validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                           return 'Please Enter Paypal id'.tr;
//                                         }
//                                         return null;
//                                       },
//                                     ),
//                                   ],
//                                 )
//                               : Container(),
//                   SizedBox(
//                     height: 15,
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: InkWell(
//                           onTap: () {
//                             payOutController.emptyDetails();
//                             Get.back();
//                           },
//                           child: Container(
//                             height: 50,
//                             margin: EdgeInsets.all(15),
//                             alignment: Alignment.center,
//                             child: Text(
//                               "Cancel".tr,
//                               style: TextStyle(
//                                 color: blueColor,
//                                 fontFamily: FontFamily.gilroyBold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             decoration: BoxDecoration(
//                               color: Color(0xFFeef4ff),
//                               borderRadius: BorderRadius.circular(45),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: InkWell(
//                           onTap: () {
//                             if (_formKey.currentState?.validate() ?? false) {
//                               if (selectType != null) {
//                                 payOutController.requestWithdraweApi(
//                                   rType: selectType,
//                                 );
//                               } else {
//                                 showToastMessage("Please Select Type".tr);
//                               }
//                             }
//                           },
//                           child: Container(
//                             height: 50,
//                             margin: EdgeInsets.all(15),
//                             alignment: Alignment.center,
//                             child: Text(
//                               "Proceed".tr,
//                               style: TextStyle(
//                                 color: WhiteColor,
//                                 fontFamily: FontFamily.gilroyBold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             decoration: BoxDecoration(
//                               color: blueColor,
//                               borderRadius: BorderRadius.circular(45),
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   )
//                 ],
//               ),
//             ),
//             decoration: BoxDecoration(
//               color: notifire.getbgcolor,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(30),
//                 topRight: Radius.circular(30),
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }
//
//   textfield(
//       {String? type,
//       labelText,
//       prefixtext,
//       suffix,
//       Color? labelcolor,
//       prefixcolor,
//       floatingLabelColor,
//       focusedBorderColor,
//       TextDecoration? decoration,
//       bool? readOnly,
//       double? Width,
//       int? max,
//       TextEditingController? controller,
//       TextInputType? textInputType,
//       Function(String)? onChanged,
//       String? Function(String?)? validator,
//       Height}) {
//     return Container(
//       height: Height,
//       width: Width,
//       margin: EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 12),
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           color: notifire.getblackwhitecolor),
//       child: TextFormField(
//         controller: controller,
//         onChanged: onChanged,
//         cursorColor: notifire.getwhiteblackcolor,
//         keyboardType: textInputType,
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         maxLength: max,
//         readOnly: readOnly ?? false,
//         style: TextStyle(
//             color: notifire.getwhiteblackcolor,
//             fontFamily: FontFamily.gilroyMedium,
//             fontSize: 18),
//         decoration: InputDecoration(
//           hintText: labelText,
//           hintStyle: TextStyle(
//               color: Colors.grey, fontFamily: "Gilroy Medium", fontSize: 16),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: blueColor),
//             borderRadius: BorderRadius.circular(15),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide(color: Colors.grey.shade200),
//           ),
//           border: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.grey.shade200),
//             borderRadius: BorderRadius.circular(15),
//           ),
//         ),
//         validator: validator,
//       ),
//     );
//   }
// }
