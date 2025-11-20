import 'package:flutter/material.dart';
import 'package:gotocarefinder/controller/subscribe_controller.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:signature/signature.dart';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:convert';

class ContractAgreement extends StatefulWidget {
  ContractAgreement({super.key});

  @override
  State<ContractAgreement> createState() => _ContractAgreementState();
}

class _ContractAgreementState extends State<ContractAgreement> {
  SubscribeController subscribeController = Get.find();

  // initialize the signature controller
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.blue,
    exportBackgroundColor: Colors.transparent,
    exportPenColor: Colors.black,
  );

  String? userSignatureBase64;

  @override
  void initState() {
    super.initState();
    getdarkmodepreviousstate();
    _controller
      ..addListener(() => log('Value changed'))
      ..onDrawEnd = () => setState(
            () {
              // setState for build to update value of "empty label" in gui
            },
          );
  }

  @override
  void dispose() {
    // IMPORTANT to dispose of the controller
    _controller.dispose();
    super.dispose();
  }

  Future<void> exportImage(BuildContext context) async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          key: Key('snackbarPNG'),
          content: Text('No content'),
        ),
      );
      return;
    }

    final Uint8List? data =
        await _controller.toPngBytes(height: 1000, width: 1000);
    if (data == null) {
      return;
    }

    if (!mounted) return;

    userSignatureBase64 = base64Encode(data);
  }

  late ColorNotifire notifier;

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifier.setIsDark = false;
    } else {
      notifier.setIsDark = previusstate;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Get.width / 20),
      child: Text(
        title,
        style: TextStyle(
          color: notifier.getwhiteblackcolor,
          fontSize: 16,
          fontFamily: FontFamily.gilroyBold,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Get.width / 20),
      child: Text(
        content,
        style: TextStyle(
          color: notifier.getwhiteblackcolor,
          fontSize: 15,
          fontFamily: FontFamily.gilroyMedium,
        ),
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Acknowledgment",
            style: TextStyle(
              color: notifier.getwhiteblackcolor,
              fontSize: 16,
              fontFamily: FontFamily.gilroyBold,
            ),
          ),
          SizedBox(height: Get.height / 40),
          Text(
            "THE PROVIDER",
            style: TextStyle(
              color: notifier.getwhiteblackcolor,
              fontSize: 16,
              fontFamily: FontFamily.gilroyBold,
            ),
          ),
          SizedBox(height: Get.height / 40),
          textfield(
            type: "Representative Name".tr,
            controller: subscribeController.representativeNameController,
            labelText: "Representative Name".tr,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter Home Name'.tr;
              }
              return null;
            },
          ),
          SizedBox(
            height: 10,
          ),
          _buildSectionTitle("Signature"),
          SizedBox(height: 10),
          //SIGNATURE CANVAS
                Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Signature(
                          key: const Key('signature'),
                          controller: _controller,
                          height: 250,
                          backgroundColor: Colors.grey[300]!,
                        ),
                      ),
                Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.undo),
                            color: Colors.blue,
                            onPressed: () {
                              setState(() => _controller.undo());
                            },
                            tooltip: 'Undo',
                          ),
                          IconButton(
                            icon: const Icon(Icons.redo),
                            color: Colors.blue,
                            onPressed: () {
                              setState(() => _controller.redo());
                            },
                            tooltip: 'Redo',
                          ),
                          //CLEAR CANVAS
                          IconButton(
                            key: const Key('clear'),
                            icon: const Icon(Icons.clear),
                            color: Colors.blue,
                            onPressed: () {
                              setState(() => _controller.clear());
                            },
                            tooltip: 'Clear',
                          ),
                          // STOP Edit
                          IconButton(
                            key: const Key('stop'),
                            icon: Icon(
                              _controller.disabled
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            color: Colors.blue,
                            onPressed: () {
                              setState(() =>
                                  _controller.disabled = !_controller.disabled);
                            },
                            tooltip: _controller.disabled ? 'Pause' : 'Play',
                          ),
                        ],
                      ),
        ],
      ),
    );
  }

  Widget _buildSignatureLine(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Get.height / 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: notifier.getwhiteblackcolor,
              fontSize: 16,
              fontFamily: FontFamily.gilroyMedium,
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey,
            margin: EdgeInsets.only(top: Get.height / 100),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifire>(context, listen: true);

    return Scaffold(
      backgroundColor: notifier.getbgcolor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: notifier.getwhiteblackcolor,
          ),
        ),
        backgroundColor: notifier.getblackwhitecolor,
        elevation: 0,
        title: Text(
          "Client Placement Agreement".tr,
          style: TextStyle(
            color: notifier.getwhiteblackcolor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Get.width / 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "This agreement is entered into by GoToCareFinder, LLC and the party responsible for the creation, addition and management of listings on this platfrom, herein referred to as THE PROVIDER. The purpose of this agreement is to establish the terms and conditions under which GoToCareFinder will refer clients to THE PROVIDER for placement and residency.",
                style: TextStyle(
                  color: notifier.getwhiteblackcolor,
                  fontSize: 15,
                  fontFamily: FontFamily.gilroyMedium,
                ),
              ),
              SizedBox(height: Get.height / 30),
              _buildSectionTitle("1. Service Provided"),
              SizedBox(height: Get.height / 40),
              _buildSectionContent(
                  "GoToCareFinder will refer clients seeking adult family home care to THE PROVIDER for consideration of placement. THE PROVIDER agrees to accept such clients in accordance with its licensing and care capabilities and to treat all referred clients with dignity, respect, and quality care. If GoToCareFinder receives a substantiated complaint regarding the mistreatment of a client, it reserves the right to relocate the client to another facility without any obligation to pay THE PROVIDER."),
              SizedBox(height: Get.height / 30),
              _buildSectionTitle(
                  "2. Licensing, Compliance, and Notification Requirements"),
              SizedBox(height: Get.height / 40),
              _buildSectionContent(
                  "THE PROVIDER must comply with all applicable state and local regulations and maintain its license in good standing. THE PROVIDER must immediately notify GoToCareFinder of any investigations, citations, or regulatory violations that may impact client care or licensing status. GoToCareFinder reserves the right to withdraw services if THE PROVIDER fails to meet required standards, including but not limited to care quality and facility condition."),
              SizedBox(height: Get.height / 30),
              _buildSectionTitle("3. Referral Fee and Payment Terms"),
              SizedBox(height: Get.height / 40),
              _buildSectionContent(
                  "THE PROVIDER agrees to pay GoToCareFinder a referral fee equivalent to 90% of the monthly care fee charged to the referred client, spread over three monthly installments as follows:\n\n"
                  "1st Payment (40%): Due within 30 days of the client's move-in date.\n"
                  "2nd Payment (30%): Due within 30 days after the first payment.\n"
                  "3rd Payment (20%): Due within 30 days after the second payment.\n\n"
                  "The fee will be based on the published rate without adjustments for any special promotions or discounts applied after the referral.\n\n"
                  "Failure to make payments as agreed shall result in a penalty of 10% per month on the outstanding balance. Persistent non-payment may result in legal action and termination of this agreement."),
              SizedBox(height: Get.height / 30),
              _buildSectionTitle("4. Client Removal or Departure"),
              SizedBox(height: Get.height / 40),
              _buildSectionContent(
                  "If the client vacates the premises or expires within the first 30 days of occupancy, THE PROVIDER is only responsible for paying the prorated portion of the referral fee.\n\n"
                  "For clients in Hospice or short-term Respite care, fees will be prorated based on the duration of their stay, payable upon client departure."),
              SizedBox(height: Get.height / 30),
              _buildSectionTitle("5. Indemnification and Liability Waiver"),
              SizedBox(height: Get.height / 40),
              _buildSectionContent(
                  "THE PROVIDER agrees to indemnify, defend, and hold harmless GoToCareFinder, its officers, directors, employees, and affiliates from any and all claims, damages, liabilities, costs, or expenses (including attorney fees) arising from:\n\n"
                  "• Client care, neglect, abuse, or mistreatment within THE PROVIDER.\n"
                  "• Violations of local, state, or federal regulations by THE PROVIDER.\n"
                  "• Any legal claims brought by clients, their families, or third parties due to the actions or omissions of THE PROVIDER.\n"
                  "• Any data breaches or privacy violations related to client information.\n\n"
                  "GoToCareFinder shall not be held responsible for any liability arising from the conduct, operations, or management of THE PROVIDER."),
              SizedBox(height: Get.height / 30),
              _buildSectionTitle("6. Termination and Breach of Agreement"),
              SizedBox(height: Get.height / 40),
              _buildSectionContent(
                  "Either party may terminate this agreement with a 30-day written notice. However, if either party materially violates the terms of this agreement, the non-breaching party may terminate the agreement immediately.\n\n"
                  "In the event of termination, THE PROVIDER remains responsible for any referral fees owed for clients already placed in their facility.\n\n"
                  "If THE PROVIDER fails to provide proper care to a referred client or engages in unethical or illegal practices, GoToCareFinder reserves the right to immediately terminate this agreement and remove all active referrals without any financial obligation to THE PROVIDER."),
              SizedBox(height: Get.height / 30),
              _buildSectionTitle("7. Confidentiality"),
              SizedBox(height: Get.height / 40),
              _buildSectionContent(
                  "Both parties agree to maintain the confidentiality of all client information as required by law and will only share information as necessary for client care or in compliance with legal obligations."),
              SizedBox(height: Get.height / 30),
              _buildSectionTitle(
                  "8. Consent to Use of Images, Likeness, and Trademarks"),
              SizedBox(height: Get.height / 40),
              _buildSectionContent(
                  "THE PROVIDER grants GoToCareFinder the right to use images of their facility, including interior and exterior photographs, for advertising and promotional purposes. Additionally, THE PROVIDER consents to GoToCareFinder displaying and referencing their official website, which may contain client images, in promotional materials and the GoToCareFinder application/platform. THE PROVIDER further grants a non-exclusive license to use its name, logo, and branding elements strictly for marketing purposes, ensuring accurate representation."),
              SizedBox(height: Get.height / 30),
              _buildSectionTitle("9. Advertising Terms & Conditions"),
              SizedBox(height: Get.height / 40),
              _buildSectionContent(
                  "THE PROVIDER acknowledges and agrees that any advertising of its facility on the GoToCareFinder application/platform is subject to the platform's terms and conditions. GoToCareFinder reserves the right to approve, modify, or remove advertisements that do not align with the platform's policies or quality standards. THE PROVIDER also agrees that any promotional claims or representations made in advertising must be truthful and not misleading to clients."),
              SizedBox(height: Get.height / 30),
              _buildSectionTitle("10. Dispute Resolution"),
              SizedBox(height: Get.height / 40),
              _buildSectionContent(
                  "In the event of any dispute arising from this agreement, the parties agree to first attempt mediation. If mediation fails, the dispute shall be resolved through binding arbitration in the state in which THE PROVIDER operates. Each party shall bear its own legal costs, unless otherwise determined by the arbitrator."),
              SizedBox(height: Get.height / 30),
              _buildSectionTitle("11. Representative Authorization"),
              SizedBox(height: Get.height / 40),
              _buildSectionContent(
                  "The undersigned representative of THE PROVIDER certifies that they are authorized to act on behalf of THE PROVIDER and enter into this agreement. The representative further affirms that they have the authority to grant permissions and accept terms outlined in this agreement."),
              SizedBox(height: Get.height / 30),
              _buildSectionTitle("12. Governing Law"),
              SizedBox(height: Get.height / 40),
              _buildSectionContent(
                  "This Agreement shall be governed by the laws of the state in which THE PROVIDER operates."),
              SizedBox(height: Get.height / 30),
              _buildSectionTitle("13. Entire Agreement"),
              SizedBox(height: Get.height / 40),
              _buildSectionContent(
                  "This Agreement constitutes the entire agreement between GoToCareFinder and THE PROVIDER and supersedes any previous agreements or understandings, whether written or oral."),
              SizedBox(height: Get.height / 30),
              _buildSectionTitle("4. Client Removal or Departure"),
              SizedBox(height: Get.height / 40),
              SizedBox(height: Get.height / 30),
              _buildSignatureSection(),
              SizedBox(height: Get.height / 20),
              Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: _controller.isEmpty
                                ? null
                                : () {
                                  Get.toNamed(Routes.subscribeScreen);
                                },
                          child: Container(
                            decoration: BoxDecoration(
                                color: notifier.getdarkbluecolor,
                                borderRadius: BorderRadius.circular(50)),
                            height: 50,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "Get Started".tr,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontFamily: "Gilroy Bold"),
                              ),
                            ),
                          ),
                        ),
                      )
            ],
          ),
        ),
      ),
    );
  }

  textfield(
      {String? type,
      labelText,
      prefixtext,
      suffix,
      Color? labelcolor,
      prefixcolor,
      floatingLabelColor,
      focusedBorderColor,
      TextDecoration? decoration,
      bool? readOnly,
      double? Width,
      int? max,
      TextEditingController? controller,
      TextInputType? textInputType,
      Function(String)? onChanged,
      String? Function(String?)? validator,
      Height}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            type ?? "",
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              fontSize: 16,
              color: notifier.getwhiteblackcolor,
            ),
          ),
        ),
        SizedBox(
          height: 6,
        ),
        Container(
          height: Height,
          width: Width,
          margin: EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: notifier.getblackwhitecolor),
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            cursorColor: notifier.getwhiteblackcolor,
            keyboardType: textInputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLength: max,
            readOnly: readOnly ?? false,
            style: TextStyle(
                color: notifier.getwhiteblackcolor,
                fontFamily: FontFamily.gilroyMedium,
                fontSize: 18),
            decoration: InputDecoration(
              hintText: labelText,
              hintStyle: TextStyle(
                  color: Colors.grey,
                  fontFamily: "Gilroy Medium",
                  fontSize: 16),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: notifier.getblackblue),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: notifier.getborderColor),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: notifier.getborderColor),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
