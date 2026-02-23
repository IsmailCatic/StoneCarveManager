class DashboardStatistics {
  // Revenue
  final double totalRevenue;
  final double revenueChange;
  final double averageOrderValue;

  // Orders
  final int totalOrders;
  final int ordersChange;
  final int pendingOrders;
  final int processingOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int customOrders;
  final int regularOrders;

  // Customers
  final int totalCustomers;
  final int newCustomers;
  final int returningCustomers;

  // Products
  final int totalProducts;
  final int lowStockProducts;

  // Reviews
  final double averageRating;
  final int totalReviews;
  final int pendingReviews;

  // Payments
  final int successfulPayments;
  final int failedPayments;
  final double refundedAmount;

  DashboardStatistics({
    required this.totalRevenue,
    required this.revenueChange,
    required this.averageOrderValue,
    required this.totalOrders,
    required this.ordersChange,
    required this.pendingOrders,
    required this.processingOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.customOrders,
    required this.regularOrders,
    required this.totalCustomers,
    required this.newCustomers,
    required this.returningCustomers,
    required this.totalProducts,
    required this.lowStockProducts,
    required this.averageRating,
    required this.totalReviews,
    required this.pendingReviews,
    required this.successfulPayments,
    required this.failedPayments,
    required this.refundedAmount,
  });

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) {
    return DashboardStatistics(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      revenueChange: (json['revenueChange'] ?? 0).toDouble(),
      averageOrderValue: (json['averageOrderValue'] ?? 0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      ordersChange: json['ordersChange'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      processingOrders: json['processingOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      cancelledOrders: json['cancelledOrders'] ?? 0,
      customOrders: json['customOrders'] ?? 0,
      regularOrders: json['regularOrders'] ?? 0,
      totalCustomers: json['totalCustomers'] ?? 0,
      newCustomers: json['newCustomers'] ?? 0,
      returningCustomers: json['returningCustomers'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      lowStockProducts: json['lowStockProducts'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      pendingReviews: json['pendingReviews'] ?? 0,
      successfulPayments: json['successfulPayments'] ?? 0,
      failedPayments: json['failedPayments'] ?? 0,
      refundedAmount: (json['refundedAmount'] ?? 0).toDouble(),
    );
  }
}

class RevenueByMethod {
  final String paymentMethod;
  final double totalRevenue;
  final int orderCount;
  final double percentage;

  RevenueByMethod({
    required this.paymentMethod,
    required this.totalRevenue,
    required this.orderCount,
    required this.percentage,
  });

  factory RevenueByMethod.fromJson(Map<String, dynamic> json) {
    return RevenueByMethod(
      paymentMethod: json['paymentMethod'] ?? '',
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      orderCount: json['orderCount'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class RevenueTrend {
  final DateTime date;
  final double revenue;
  final int orderCount;

  RevenueTrend({
    required this.date,
    required this.revenue,
    required this.orderCount,
  });

  factory RevenueTrend.fromJson(Map<String, dynamic> json) {
    return RevenueTrend(
      date: DateTime.parse(json['date']),
      revenue: (json['revenue'] ?? 0).toDouble(),
      orderCount: json['orderCount'] ?? 0,
    );
  }
}

class TopProduct {
  final int productId;
  final String productName;
  final int orderCount;
  final int quantitySold;
  final double totalRevenue;

  TopProduct({
    required this.productId,
    required this.productName,
    required this.orderCount,
    required this.quantitySold,
    required this.totalRevenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      orderCount: json['orderCount'] ?? 0,
      quantitySold: json['quantitySold'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}

class CategoryPerformance {
  final int categoryId;
  final String categoryName;
  final int productCount;
  final int orderCount;
  final double totalRevenue;
  final double percentage;

  CategoryPerformance({
    required this.categoryId,
    required this.categoryName,
    required this.productCount,
    required this.orderCount,
    required this.totalRevenue,
    required this.percentage,
  });

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) {
    return CategoryPerformance(
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      productCount: json['productCount'] ?? 0,
      orderCount: json['orderCount'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class TopCustomer {
  final int userId;
  final String customerName;
  final String email;
  final int totalOrders;
  final double totalSpent;
  final DateTime lastOrderDate;

  TopCustomer({
    required this.userId,
    required this.customerName,
    required this.email,
    required this.totalOrders,
    required this.totalSpent,
    required this.lastOrderDate,
  });

  factory TopCustomer.fromJson(Map<String, dynamic> json) {
    return TopCustomer(
      userId: json['userId'] ?? 0,
      customerName: json['customerName'] ?? '',
      email: json['email'] ?? '',
      totalOrders: json['totalOrders'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      lastOrderDate: json['lastOrderDate'] != null
          ? DateTime.parse(json['lastOrderDate'])
          : DateTime.now(),
    );
  }
}

class CustomerStatistics {
  final int totalCustomers;
  final int newCustomers;
  final int returningCustomers;
  final double averageLifetimeValue;
  final double averageOrdersPerCustomer;

  CustomerStatistics({
    required this.totalCustomers,
    required this.newCustomers,
    required this.returningCustomers,
    required this.averageLifetimeValue,
    required this.averageOrdersPerCustomer,
  });

  factory CustomerStatistics.fromJson(Map<String, dynamic> json) {
    return CustomerStatistics(
      totalCustomers: json['totalCustomers'] ?? 0,
      newCustomers: json['newCustomers'] ?? 0,
      returningCustomers: json['returningCustomers'] ?? 0,
      averageLifetimeValue: (json['averageLifetimeValue'] ?? 0).toDouble(),
      averageOrdersPerCustomer: (json['averageOrdersPerCustomer'] ?? 0)
          .toDouble(),
    );
  }
}

class ReviewStatistics {
  final double averageRating;
  final int totalReviews;
  final int approvedReviews;
  final int pendingReviews;
  final Map<int, int> ratingDistribution;
  final double approvalRate;

  ReviewStatistics({
    required this.averageRating,
    required this.totalReviews,
    required this.approvedReviews,
    required this.pendingReviews,
    required this.ratingDistribution,
    required this.approvalRate,
  });

  factory ReviewStatistics.fromJson(Map<String, dynamic> json) {
    Map<int, int> distribution = {};
    if (json['ratingDistribution'] != null) {
      (json['ratingDistribution'] as Map<String, dynamic>).forEach((
        key,
        value,
      ) {
        distribution[int.parse(key)] = value as int;
      });
    }

    return ReviewStatistics(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      approvedReviews: json['approvedReviews'] ?? 0,
      pendingReviews: json['pendingReviews'] ?? 0,
      ratingDistribution: distribution,
      approvalRate: (json['approvalRate'] ?? 0).toDouble(),
    );
  }
}

class EmployeePerformance {
  final int employeeId;
  final String employeeName;
  final int assignedOrders;
  final int completedOrders;
  final double completionRate;
  final double averageCompletionDays;
  final double totalRevenue;

  EmployeePerformance({
    required this.employeeId,
    required this.employeeName,
    required this.assignedOrders,
    required this.completedOrders,
    required this.completionRate,
    required this.averageCompletionDays,
    required this.totalRevenue,
  });

  factory EmployeePerformance.fromJson(Map<String, dynamic> json) {
    return EmployeePerformance(
      employeeId: json['employeeId'] ?? 0,
      employeeName: json['employeeName'] ?? '',
      assignedOrders: json['assignedOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      completionRate: (json['completionRate'] ?? 0).toDouble(),
      averageCompletionDays: (json['averageCompletionDays'] ?? 0).toDouble(),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}
