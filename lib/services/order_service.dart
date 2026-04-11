import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final supabase = Supabase.instance.client;

  /// 🔥 CREATE ORDER (SUDAH BAGUS, TIDAK PERLU DIUBAH)
  Future<void> createOrder({
    required String userId,
    required Map product,
    required Map variant,
    required String email,
    String? paymentProof, 
  }) async {
    await supabase.from('orders').insert({
      "user_id": userId,
      "product_id": product["id"], // 🔥 penting (relasi)
      "variant_id": variant["id"], // 🔥 penting (relasi)
      "product_name": product["name"],
      "variant_type": variant["type"],
      "duration_days": variant["duration_days"],
      "price": variant["price"],
      "account_email": email,
      "payment_proof": paymentProof,
      "status": "pending",
    });
  }

  /// 🔥 GET ORDERS (SUDAH INCLUDE IMAGE DARI PRODUCTS)
  Future<List<Map<String, dynamic>>> getOrders() async {
    final user = supabase.auth.currentUser;

    if (user == null) return [];

    final data = await supabase
        .from('orders')
        .select('*, products(image)') // 🔥 INI KUNCINYA
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  /// GET ALL ORDERS (UNTUK ADMIN)
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final data = await supabase
        .from('orders')
        .select('*, products(image)')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  /// 🔥 APPROVE ORDER (MANUAL INPUT ACCOUNT)
Future<void> approveOrderManual({
  required String orderId,
  required String email,
  required String password,
}) async {

  final order = await supabase
      .from('orders')
      .select()
      .eq('id', orderId)
      .single();

  await supabase.from('orders').update({
    "status": "approved",
    "account_email": email,
    "account_password": password,
  }).eq('id', orderId);

  print("ORDER UPDATED");

  final startDate = DateTime.now();
  final endDate = startDate.add(Duration(days: order['duration_days'] ?? 30));

  await supabase.from('subscriptions').insert({
    "user_id": order['user_id'],
    "order_id": orderId,
    "product_name": order['product_name'],
    "variant_type": order['variant_type'],
    "start_date": startDate.toIso8601String(),
    "end_date": endDate.toIso8601String(),
    "status": "active",
  });

  print("SUBSCRIPTION CREATED");

  final variant = await supabase
      .from('product_variants')
      .select('modal_price')
      .eq('id', order['variant_id'])
      .single();

   print("VARIANT: $variant");    

  final price = order['price'] ?? 0;
  final modalPrice = variant['modal_price'] ?? 0;
  final profit = price - modalPrice;

  print("PRICE: $price, MODAL: $modalPrice, PROFIT: $profit");

  await supabase.from('transactions').insert({
    "order_id": orderId,
    "price": price,
    "modal_price": modalPrice,
    "profit": profit,
  });

  print("TRANSACTION CREATED");
}

/// 🔥 UPDATE STATUS ORDER (REJECT / DLL)
Future<void> updateOrderStatus(String id, String status) async {
  await supabase
      .from('orders')
      .update({'status': status})
      .eq('id', id);
}

}
