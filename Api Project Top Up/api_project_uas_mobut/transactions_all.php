<?php
require_once __DIR__ . "/db.php";

$data = body_json();
$user_id = (int)($data["user_id"] ?? 0);
if ($user_id <= 0) fail("user_id wajib");

// cek role admin dari DB
$st = $conn->prepare("SELECT id, role FROM users WHERE id=? LIMIT 1");
$st->bind_param("i", $user_id);
$st->execute();
$u = $st->get_result()->fetch_assoc();

if (!$u) fail("User tidak ditemukan", 401);
if (($u["role"] ?? "user") !== "admin") fail("Admin only", 403);

// ambil semua transaksi
$sql = "
  SELECT 
    t.id,
    u.name AS user_name,
    u.email AS user_email,
    g.name AS game,
    t.nominal,
    t.status,
    t.created_at
  FROM topup_transactions t
  JOIN users u ON u.id = t.user_id
  JOIN games g ON g.id = t.game_id
  ORDER BY t.id DESC
";
$res = $conn->query($sql);

$rows = [];
while ($r = $res->fetch_assoc()) {
  $rows[] = [
    "id" => (int)$r["id"],
    "user_name" => $r["user_name"],
    "user_email" => $r["user_email"],
    "game" => $r["game"],
    "nominal" => (int)$r["nominal"],
    "status" => $r["status"],
    "created_at" => $r["created_at"],
  ];
}

ok($rows);
