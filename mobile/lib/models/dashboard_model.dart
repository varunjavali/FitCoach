class DashboardModel {
  final int totalClients;
  final int activeMembers;
  final int expiredMembers;
  final double totalRevenue;
  final double pendingBalance;
  final int expiringSoon;

  DashboardModel({
    required this.totalClients,
    required this.activeMembers,
    required this.expiredMembers,
    required this.totalRevenue,
    required this.pendingBalance,
    required this.expiringSoon,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalClients: json["totalClients"] ?? 0,
      activeMembers: json["activeMembers"] ?? 0,
      expiredMembers: json["expiredMembers"] ?? 0,
      totalRevenue: (json["totalRevenue"] ?? 0).toDouble(),
      pendingBalance: (json["pendingBalance"] ?? 0).toDouble(),
      expiringSoon: json["expiringSoon"] ?? 0,
    );
  }
}