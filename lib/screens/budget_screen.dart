import 'package:flutter/material.dart';

class BudgetTrackerPage extends StatelessWidget {
  final List<BudgetItem> budgetItems = [
    BudgetItem("Monthly", 790.00, 816.00, 103),
    BudgetItem("Apparel", 150.00, 163.51, 109),
    BudgetItem("Culture", 100.00, 124.00, 124),
    BudgetItem("Beauty", 100.00, 100.00, 100),
    BudgetItem("Social Life", 50.00, 87.00, 174),
    BudgetItem("Food", 250.00, 232.21, 92),
    BudgetItem("Health", 100.00, 89.99, 92),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.arrow_back, color: Colors.grey),
                      Row(
                        children: [
                          _buildTabButton("Stats", false),
                          _buildTabButton("Budget", true),
                          _buildTabButton("Note", false),
                        ],
                      ),
                      Text("M ▾", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.chevron_left),
                      Text("Oct 2020",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500)),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ],
              ),
            ),

            // Income and Budget Setting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Income \$3,100.00",
                          style: TextStyle(color: Colors.grey)),
                      Text("Expenses \$816.00",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Remaining(Monthly)",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Text("\$ -26.00",
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text("Budget Setting",
                                style: TextStyle(color: Colors.grey[600])),
                            Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Budget List
            Expanded(
              child: ListView.builder(
                itemCount: budgetItems.length,
                itemBuilder: (context, index) {
                  return _buildBudgetItem(budgetItems[index]);
                },
              ),
            ),

            // Bottom Navigation
            BottomNavigationBar(
              currentIndex: 1,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'Transaksi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Stats',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sync),
                  label: 'Accounts',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Account',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.red : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBudgetItem(BudgetItem item) {
    Color progressColor = item.percentage > 100 ? Colors.red : Colors.blue;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.category, style: TextStyle(color: Colors.grey[600])),
              Text("\$${item.budget.toStringAsFixed(2)}",
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: (item.spent * 100 ~/ item.budget).toInt(),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(4),
                      right: Radius.circular(item.percentage >= 100 ? 4 : 0),
                    ),
                  ),
                ),
              ),
              if (item.percentage < 100)
                Expanded(
                  flex: 100 - (item.spent * 100 ~/ item.budget),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("\$${item.spent.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text("${item.percentage}%",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}

class BudgetItem {
  final String category;
  final double budget;
  final double spent;
  final int percentage;

  BudgetItem(this.category, this.budget, this.spent, this.percentage);
}
