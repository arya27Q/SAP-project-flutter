import 'package:flutter/material.dart';
import 'constants.dart';



class SidebarWidget extends StatelessWidget {
  final String currentView;
  final Function(String) onViewChanged;

  const SidebarWidget({
    super.key,
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkIndigo, AppColors.primaryIndigo],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // --- HEADER: LOGO SAP ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    // Border putih tebal di logo
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: AppColors.primaryIndigo,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "ERP SYSTEM",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

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
                    _buildSubMenu("Approval Process", Icons.fact_check_rounded),
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
                    _buildSubMenu("Cost Accounting", Icons.calculate_outlined),

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
                      "Cancel & Read Off",
                      Icons.cancel_presentation_rounded,
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
                    _buildSubMenu("Goods Receipt PO", Icons.inventory_rounded),
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
                        _buildSubMenu("Incoming Payments", Icons.input_rounded),
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
                        _buildSubMenu("Manage Previous Recon.", Icons.history),
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
                      "Goods Issue",
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
                    _buildSubMenu("Inventory Posting", Icons.post_add_rounded),
                    _buildSubMenu("Inventory Report", Icons.bar_chart_rounded),
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
                const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                const SizedBox(height: 10),

                _buildLogoutMenu(),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSimpleMenu(IconData icon, String title, {VoidCallback? onTap}) {
    bool isActive = currentView == title;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: InkWell(
        onTap: onTap ?? () => onViewChanged(title),
        hoverColor: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.white : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              SizedBox(
                width: 24,
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white.withOpacity(isActive ? 1.0 : 0.7),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutMenu() {
    return _buildSimpleMenu(
      Icons.logout_rounded,
      "Logout",
      onTap: () => onViewChanged("Login"),
    );
  }

  Widget _buildExpansionMenu(
    BuildContext context,
    IconData icon,
    String title,
    List<Widget> children,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 22),
        leading: SizedBox(
          width: 24,
          child: Center(
            child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 22),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white70,
        children: children,
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
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white60,
        childrenPadding: const EdgeInsets.only(left: 20),
        children: children,
      ),
    );
  }

  Widget _buildSubMenu(String title, IconData subIcon) {
    bool isSubActive = currentView == title;
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 16, bottom: 2),
      child: InkWell(
        onTap: () => onViewChanged(title),
        hoverColor: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSubActive
                ? Colors.white.withOpacity(0.1)
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}