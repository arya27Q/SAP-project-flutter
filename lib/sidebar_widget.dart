import 'package:flutter/material.dart';
import 'constants.dart';

class SidebarWidget extends StatefulWidget {
  final String currentView;
  final Function(String) onViewChanged;

  const SidebarWidget({
    super.key,
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  // STATE BARU: Untuk nentuin sidebar lagi kebuka atau ketutup
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    // Animasi perubahan lebar: 280 kalau kebuka, 70 kalau ketutup
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isExpanded ? 280 : 70, // Lebar berubah di sini
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkIndigo, AppColors.primaryIndigo],
        ),
      ),
      // BUNGKUS DENGAN CLIP RECT: Biar isi yang meluber ke kanan otomatis dipotong
      child: ClipRect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Pastikan rata kiri
          children: [
            const SizedBox(height: 40),
            // --- HEADER: LOGO SAP & TOMBOL TOGGLE ---
            // Pakai SingleChildScrollView horizontal biar logo nggak error pas ngecil
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics:
                  const NeverScrollableScrollPhysics(), // Nggak bisa di-scroll manual
              child: Container(
                width: 280, // Kunci lebar container ini biar isinya nggak panik
                padding: EdgeInsets.symmetric(horizontal: isExpanded ? 24 : 12),
                child: Row(
                  mainAxisAlignment: isExpanded
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.start,
                  children: [
                    // Tombol Toggle Buka-Tutup gabung sama Logo
                    InkWell(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isExpanded
                              ? Icons.menu_open_rounded
                              : Icons.menu_rounded,
                          color: AppColors.primaryIndigo,
                          size: 24,
                        ),
                      ),
                    ),
                    // Tulisan Samudra II cuma muncul kalau lagi kebuka
                    if (isExpanded) ...[
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SAMUDRA II",
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "ERP System",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // PENGAMAN DIVIDER: Hilangkan kalau lagi ketutup biar nggak error
            if (isExpanded)
              const Divider(
                color: Color(0x33FFFFFF),
                height: 1,
                indent: 24,
                endIndent: 24,
              ),
            if (!isExpanded)
              const Divider(
                color: Color(0x33FFFFFF),
                height: 1,
                indent: 10,
                endIndent: 10,
              ),
            const SizedBox(height: 24),

            // --- MENU LIST ---
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  _buildSimpleMenu(Icons.grid_view_rounded, "Dashboard"),
                  _buildExpansionMenu(
                    context,
                    Icons.admin_panel_settings_rounded,
                    "Administration",
                    [
                      _buildSubMenu("Choose Company", Icons.business_rounded),
                      _buildSubMenu(
                        "Exchange Rates",
                        Icons.currency_exchange_rounded,
                      ),
                      _buildSubMenu("Setup", Icons.settings_rounded),
                      _buildSubMenu(
                          "Approval Process", Icons.fact_check_rounded),
                    ],
                  ),
                  _buildExpansionMenu(
                    context,
                    Icons.account_balance_wallet_rounded,
                    "Financials",
                    [
                      _buildSubMenu(
                        "Chart of Accounts",
                        Icons.account_tree_outlined,
                      ),
                      _buildSubMenu(
                        "Edit Chart of Accounts",
                        Icons.edit_outlined,
                      ),
                      _buildSubMenu("Journal Entry", Icons.edit_note_rounded),
                      _buildSubMenu(
                        "Exchange Rate Differences",
                        Icons.currency_exchange,
                      ),
                      _buildSubMenu(
                          "Cost Accounting", Icons.calculate_outlined),
                      _buildSubExpansionMenu(
                        context,
                        "Financial Report",
                        Icons.summarize_outlined,
                        [
                          _buildSubMenu("Accounting", Icons.book_outlined),
                          _buildSubMenu("Financial", Icons.attach_money),
                          _buildSubExpansionMenu(
                            context,
                            "Custom Report",
                            Icons.dashboard_customize_outlined,
                            [
                              _buildSubMenu(
                                "Budget Report",
                                Icons.pie_chart_outline,
                              ),
                              _buildSubMenu(
                                "Balance Sheet Budget",
                                Icons.balance,
                              ),
                              _buildSubMenu(
                                "Trial Balance Budget",
                                Icons.scale_outlined,
                              ),
                              _buildSubMenu(
                                "Profit Loss Budget",
                                Icons.trending_up,
                              ),
                            ],
                            indent: 20.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildExpansionMenu(
                    context,
                    Icons.shopping_bag_rounded,
                    "Sales - A/R",
                    [
                      _buildSubMenu(
                        "Sales Quotation",
                        Icons.description_outlined,
                      ),
                      _buildSubMenu("Sales Order", Icons.list_alt_rounded),
                      _buildSubMenu("Delivery", Icons.local_shipping_outlined),
                      _buildSubMenu("Return", Icons.assignment_return_outlined),
                      _buildSubMenu(
                        "A/R Down Payment Invoice",
                        Icons.payments_outlined,
                      ),
                      _buildSubMenu("A/R Invoice", Icons.receipt_long_rounded),
                      _buildSubMenu(
                        "A/R Credit Memo",
                        Icons.credit_card_off_rounded,
                      ),
                      _buildSubMenu(
                        "Cancel Write Off",
                        Icons.cancel_presentation_rounded,
                      ),
                      _buildSubMenu(
                        "open lock DO",
                        Icons.lock_open_rounded,
                      ),
                      _buildSubMenu(
                        "serah terima DO",
                        Icons.assignment_turned_in_rounded,
                      ),
                    ],
                  ),
                  _buildExpansionMenu(
                    context,
                    Icons.local_shipping_rounded,
                    "Purchasing",
                    [
                      _buildSubMenu(
                        "Purchase Request",
                        Icons.assignment_late_outlined,
                      ),
                      _buildSubMenu(
                        "Purchase Quotation",
                        Icons.request_quote_outlined,
                      ),
                      _buildSubMenu(
                        "Purchase Order",
                        Icons.shopping_cart_checkout_rounded,
                      ),
                      _buildSubMenu(
                          "Goods Receipt PO", Icons.inventory_rounded),
                      _buildSubMenu(
                        "Goods Return",
                        Icons.keyboard_return_rounded,
                      ),
                      _buildSubMenu("A/P Down Payment", Icons.money_outlined),
                      _buildSubMenu("A/P Invoice", Icons.description_rounded),
                      _buildSubMenu(
                        "A/P Credit Memo",
                        Icons.assignment_return_rounded,
                      ),
                      _buildSubMenu(
                        "Purchasing Report",
                        Icons.analytics_outlined,
                      ),
                    ],
                  ),
                  _buildExpansionMenu(
                    context,
                    Icons.account_balance_rounded,
                    "Banking",
                    [
                      _buildSubExpansionMenu(
                        context,
                        "Incoming Payments",
                        Icons.folder_open_outlined,
                        [
                          _buildSubMenu(
                              "Incoming Payments", Icons.input_rounded),
                          _buildSubMenu(
                            "Check Register",
                            Icons.receipt_long_outlined,
                          ),
                          _buildSubMenu(
                            "Credit Card Management",
                            Icons.credit_card,
                          ),
                          _buildSubMenu(
                            "Credit Card Summary",
                            Icons.analytics_outlined,
                          ),
                        ],
                      ),
                      _buildSubMenu("Deposits", Icons.folder_open_outlined),
                      _buildSubExpansionMenu(
                        context,
                        "Outgoing Payments",
                        Icons.folder_open_outlined,
                        [
                          _buildSubMenu(
                            "Outgoing Payments",
                            Icons.output_rounded,
                          ),
                          _buildSubMenu(
                            "Checks for Payment",
                            Icons.check_circle_outline,
                          ),
                          _buildSubMenu(
                            "Void Checks for Payment",
                            Icons.block_flipped,
                          ),
                          _buildSubMenu(
                            "Checks Drafts Report",
                            Icons.description,
                          ),
                        ],
                      ),
                      _buildSubExpansionMenu(
                        context,
                        "Bank Statements & Recon.",
                        Icons.folder_open_outlined,
                        [
                          _buildSubMenu("Reconciliation", Icons.compare_arrows),
                          _buildSubMenu(
                            "Manual Reconciliation",
                            Icons.handshake_outlined,
                          ),
                          _buildSubMenu(
                              "Manage Previous Recon.", Icons.history),
                        ],
                      ),
                    ],
                  ),
                  _buildExpansionMenu(
                    context,
                    Icons.inventory_2_rounded,
                    "Inventory",
                    [
                      _buildSubMenu("Item Master Data", Icons.category_rounded),
                      _buildSubMenu("Goods Receipt", Icons.add_box_outlined),
                      _buildSubMenu(
                        "Good Issue",
                        Icons.indeterminate_check_box_outlined,
                      ),
                      _buildSubMenu(
                        "Inventory Transfer",
                        Icons.swap_horiz_rounded,
                      ),
                      _buildSubMenu(
                        "Inventory Counting",
                        Icons.calculate_outlined,
                      ),
                      _buildSubMenu(
                          "Inventory Posting", Icons.post_add_rounded),
                      _buildSubMenu(
                          "Inventory Report", Icons.bar_chart_rounded),
                    ],
                  ),
                  _buildSimpleMenu(Icons.assessment_rounded, "Reports"),
                  _buildSimpleMenu(
                    Icons.people_alt_rounded,
                    "Business Partner Master Data",
                  ),
                  _buildSimpleMenu(
                    Icons.admin_panel_settings_outlined,
                    "Data Admin",
                  ),
                  const SizedBox(height: 20),
                  Divider(
                      color: Colors.white24,
                      indent: isExpanded ? 20 : 10,
                      endIndent: isExpanded ? 20 : 10),
                  const SizedBox(height: 10),
                  _buildLogoutMenu(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleMenu(IconData icon, String title, {VoidCallback? onTap}) {
    bool isActive = widget.currentView == title;
    // BUNGKUS JUGA BIAR AMAN DARI OVERFLOW HORIZONTAL
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        width: 280, // Selalu pakai lebar utuh biar isinya nggak kegencet
        margin:
            EdgeInsets.symmetric(horizontal: isExpanded ? 10 : 8, vertical: 2),
        child: InkWell(
          onTap: onTap ?? () => widget.onViewChanged(title),
          hoverColor: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            padding: EdgeInsets.symmetric(
                vertical: 8, horizontal: isExpanded ? 0 : 8),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (isExpanded) const SizedBox(width: 12),
                SizedBox(
                  width: 24,
                  child: Center(
                    child: Tooltip(
                      message: !isExpanded ? title : '',
                      child: Icon(
                        icon,
                        color: Colors.white
                            .withValues(alpha: isActive ? 1.0 : 0.7),
                        size: 22,
                      ),
                    ),
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutMenu() {
    return _buildSimpleMenu(
      Icons.logout_rounded,
      "Logout",
      onTap: () => widget.onViewChanged("Login"),
    );
  }

  Widget _buildExpansionMenu(
    BuildContext context,
    IconData icon,
    String title,
    List<Widget> children,
  ) {
    if (!isExpanded) {
      return _buildSimpleMenu(icon, title, onTap: () {
        setState(() {
          isExpanded = true;
        });
      });
    }

    // PAKAI SINGLECHILDSCROLLVIEW BIAR EXPANSION TILE AMAN WAKTU TRANSISI
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: SizedBox(
        width: 280,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 22),
            leading: SizedBox(
              width: 24,
              child: Center(
                child: Icon(icon,
                    color: Colors.white.withValues(alpha: 0.8), size: 22),
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis, // Tambahan aman
            ),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white70,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildSubExpansionMenu(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children, {
    double indent = 0.0,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.only(left: 32 + indent, right: 22),
        leading: Icon(icon, size: 16, color: Colors.white60),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white60,
        childrenPadding: const EdgeInsets.only(left: 20),
        children: children,
      ),
    );
  }

  Widget _buildSubMenu(String title, IconData subIcon) {
    bool isSubActive = widget.currentView == title;
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 16, bottom: 2),
      child: InkWell(
        onTap: () => widget.onViewChanged(title),
        hoverColor: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSubActive
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSubActive
                  ? Colors.white.withOpacity(0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 32),
              Icon(
                subIcon,
                size: 16,
                color: isSubActive ? Colors.white : Colors.white60,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSubActive ? Colors.white : Colors.white60,
                    fontSize: 13,
                  ),
                  overflow:
                      TextOverflow.ellipsis, // Mencegah teks kepanjangan error
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
