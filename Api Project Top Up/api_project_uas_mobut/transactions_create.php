<?php
require_once __DIR__ . "/db.php";

$data = body_json();
$user_id = (int)($data["user_id"] ?? 0);
$game_id = (int)($data["game_id"] ?? 0);
$nominal = (int)($data["nominal"] ?? 0);

if ($user_id <= 0 || $game_id <= 0 || $nominal <= 0) {
  fail("user_id, game_id, nominal wajib valid");
}

$stmt = $conn->prepare("INSERT INTO topup_transactions (user_id, game_id, nominal, status) VALUES (?, ?, ?, 'PENDING')");
$stmt->bind_param("iii", $user_id, $game_id, $nominal);

if (!$stmt->execute()) fail("Gagal membuat transaksi", 500);

ok([
  "transaction_id" => $conn->insert_id,
  "status" => "PENDING"
]);
