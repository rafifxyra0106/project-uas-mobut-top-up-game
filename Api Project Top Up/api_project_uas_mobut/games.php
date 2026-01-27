<?php
require_once __DIR__ . "/db.php";

$result = $conn->query("SELECT id, name, image_url FROM games ORDER BY id DESC");
$rows = [];
while ($r = $result->fetch_assoc()) {
  $rows[] = [
    "id" => (int)$r["id"],
    "name" => $r["name"],
    "image_url" => $r["image_url"],
  ];
}
ok($rows);
