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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.bolt, color: AppColors.primaryIndigo, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  "SAP SYSTEM",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                _buildSimpleMenu(Icons.grid_view_rounded, "Dashboard"),
                
                _buildExpansionMenu(context, Icons.admin_panel_settings_rounded, "Administration", [
                  _buildSubMenu("Choose Company", Icons.business_rounded),
                  _buildSubMenu("Exchange Rates", Icons.currency_exchange_rounded),
                  _buildSubMenu("Setup", Icons.settings_rounded),
                  _buildSubMenu("Approval Process", Icons.fact_check_rounded),
                ]),

                _buildExpansionMenu(context, Icons.account_balance_wallet_rounded, "Financials", [
                  _buildSubMenu("Chart of Accounts", Icons.account_tree_outlined),
                  _buildSubMenu("Journal Entry", Icons.edit_note_rounded),
                  _buildSubMenu("Financial Report", Icons.summarize_outlined),
                ]),

                _buildExpansionMenu(context, Icons.shopping_bag_rounded, "Sales - A/R", [
                  _buildSubMenu("Sales Quotation", Icons.description_outlined),
                  _buildSubMenu("Sales Order", Icons.list_alt_rounded),
                  _buildSubMenu("Delivery", Icons.local_shipping_outlined),
                  _buildSubMenu("Return", Icons.assignment_return_outlined),
                  _buildSubMenu("A/R Down Payment", Icons.payments_outlined),
                  _buildSubMenu("A/R Invoice", Icons.receipt_long_rounded),
                  _buildSubMenu("A/R Credit Memo", Icons.credit_card_off_rounded),
                  _buildSubMenu("Cancel & Read Off", Icons.cancel_presentation_rounded),
                ]),

                _buildExpansionMenu(context, Icons.local_shipping_rounded, "Purchasing", [
                  _buildSubMenu("Purchase Request", Icons.assignment_late_outlined),
                  _buildSubMenu("Purchase Quotation", Icons.request_quote_outlined),
                  _buildSubMenu("Purchase Order", Icons.shopping_cart_checkout_rounded),
                  _buildSubMenu("Goods Receipt PO", Icons.inventory_rounded),
                  _buildSubMenu("Goods Return", Icons.keyboard_return_rounded),
                  _buildSubMenu("AP Down Payment", Icons.money_outlined),
                  _buildSubMenu("A/P Invoice", Icons.description_rounded),
                  _buildSubMenu("A/P Credit Memo", Icons.assignment_return_rounded),
                  _buildSubMenu("Purchasing Report", Icons.analytics_outlined),
                ]),

                _buildExpansionMenu(context, Icons.account_balance_rounded, "Banking", [
                  _buildSubMenu("Incoming Payment", Icons.file_download_outlined),
                  _buildSubMenu("Outgoing Payment", Icons.file_upload_outlined),
                  _buildSubMenu("Banking Report", Icons.assessment_outlined),
                ]),

                _buildExpansionMenu(context, Icons.inventory_2_rounded, "Inventory", [
                  _buildSubMenu("Item Master Data", Icons.category_rounded),
                  _buildSubMenu("Goods Receipt", Icons.add_box_outlined),
                  _buildSubMenu("Goods Issue", Icons.indeterminate_check_box_outlined),
                  _buildSubMenu("Inventory Transfer", Icons.swap_horiz_rounded),
                  _buildSubMenu("Inventory Counting", Icons.calculate_outlined),
                  _buildSubMenu("Inventory Posting", Icons.post_add_rounded),
                  _buildSubMenu("Inventory Report", Icons.bar_chart_rounded),
                ]),
  
                _buildSimpleMenu(Icons.assessment_rounded, "Reports"),

                _buildExpansionMenu(context, Icons.account_circle_rounded, "Account", [
                  _buildSubMenu("Login", Icons.login_rounded),
                  _buildSubMenu("Sign Up", Icons.person_add_alt_1_rounded),
                  _buildSubMenu("Forgot Password", Icons.lock_reset_rounded),
                ]),
                
                _buildSimpleMenu(Icons.people_alt_rounded, "Business Partner Master Data"),
                _buildSimpleMenu(Icons.admin_panel_settings_outlined, "Data Admin"),
                
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMenu(IconData icon, String title) {
    bool isActive = currentView == title;
    return InkWell(
      onTap: () => onViewChanged(title),
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12), 
            SizedBox(
              width: 24,
              child: Center(
                child: Icon(icon, color: Colors.white.withOpacity(isActive ? 1.0 : 0.7), size: 22),
              ),
            ),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionMenu(BuildContext context, IconData icon, String title, List<Widget> children) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        // leading diletakkan dalam SizedBox dengan lebar yang sama dengan menu simpel
        tilePadding: const EdgeInsets.symmetric(horizontal: 22),
        leading: SizedBox(
          width: 24,
          child: Center(
            child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 22),
          ),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white70,
        children: children,
      ),
    );
  }

  Widget _buildSubMenu(String title, IconData subIcon) {
    bool isSubActive = currentView == title;
    return InkWell(
      onTap: () => onViewChanged(title),
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(left: 20, right: 16, bottom: 2),
        decoration: BoxDecoration(
          color: isSubActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const SizedBox(width: 32),
            Icon(subIcon, size: 16, color: isSubActive ? Colors.white : Colors.white60),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title, 
                style: TextStyle(color: isSubActive ? Colors.white : Colors.white60, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
