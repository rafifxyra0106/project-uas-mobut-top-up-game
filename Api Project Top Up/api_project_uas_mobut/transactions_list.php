<?php
require_once __DIR__ . "/db.php";

$user_id = (int)($_GET["user_id"] ?? 0);
if ($user_id <= 0) fail("user_id wajib");

$stmt = $conn->prepare("
  SELECT t.id, g.name AS game, t.nominal, t.status, t.created_at
  FROM topup_transactions t
  JOIN games g ON g.id = t.game_id
  WHERE t.user_id=?
  ORDER BY t.id DESC
");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$res = $stmt->get_result();

$rows = [];
while ($r = $res->fetch_assoc()) {
  $rows[] = [
    "id" => (int)$r["id"],
    "game" => $r["game"],
    "nominal" => (int)$r["nominal"],
    "status" => $r["status"],
    "created_at" => $r["created_at"],
  ];
}

ok($rows);
