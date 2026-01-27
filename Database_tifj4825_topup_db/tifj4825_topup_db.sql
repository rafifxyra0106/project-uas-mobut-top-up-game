-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Waktu pembuatan: 27 Jan 2026 pada 16.39
-- Versi server: 10.11.15-MariaDB-cll-lve
-- Versi PHP: 8.4.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `tifj4825_topup_db`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `games`
--

CREATE TABLE `games` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `image_url` text NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data untuk tabel `games`
--

INSERT INTO `games` (`id`, `name`, `image_url`, `created_at`) VALUES
(1, 'Genshin Impact', 'https://rapip.tif-lbj.my.id/uploads/genshin.png', '2026-01-07 15:45:21'),
(2, 'Mobile Legend', 'https://rapip.tif-lbj.my.id/uploads/MobileLegend.jpg', '2026-01-07 15:45:21'),
(3, 'Honkai : Star Rail', 'https://rapip.tif-lbj.my.id/uploads/game_1769004730_0d410a79.jpg', '2026-01-21 14:12:11'),
(4, 'jdjdjd', 'https://rapip.tif-lbj.my.id/uploads/game_1769161361_6056.png', '2026-01-23 09:42:41');

-- --------------------------------------------------------

--
-- Struktur dari tabel `topup_transactions`
--

CREATE TABLE `topup_transactions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `game_id` int(11) NOT NULL,
  `nominal` int(11) NOT NULL,
  `status` enum('PENDING','PAID','FAILED') DEFAULT 'PENDING',
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data untuk tabel `topup_transactions`
--

INSERT INTO `topup_transactions` (`id`, `user_id`, `game_id`, `nominal`, `status`, `created_at`) VALUES
(1, 2, 2, 20000, 'PENDING', '2026-01-14 14:46:30'),
(2, 2, 1, 10000, 'PENDING', '2026-01-14 15:01:22'),
(3, 2, 1, 100000, 'PENDING', '2026-01-14 16:42:29'),
(4, 2, 2, 100000, 'PENDING', '2026-01-18 10:31:57'),
(5, 2, 2, 100000, 'PENDING', '2026-01-20 13:32:14'),
(6, 4, 2, 20000, 'PENDING', '2026-01-21 07:35:19'),
(7, 5, 2, 20000, 'PENDING', '2026-01-21 14:11:15'),
(8, 5, 3, 50000, 'PENDING', '2026-01-21 17:58:37'),
(9, 6, 2, 20000, 'PENDING', '2026-01-22 04:49:04'),
(10, 8, 4, 100000, 'PENDING', '2026-01-23 09:43:49'),
(11, 6, 3, 50000, 'PENDING', '2026-01-27 08:47:00'),
(12, 6, 2, 100000, 'PENDING', '2026-01-27 08:47:02'),
(13, 6, 1, 20000, 'PENDING', '2026-01-27 08:47:04');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `username` varchar(50) DEFAULT NULL,
  `email` varchar(120) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `role` varchar(20) NOT NULL DEFAULT 'user'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `name`, `username`, `email`, `password_hash`, `created_at`, `role`) VALUES
(1, 'Rafif', NULL, 'rafif20@gmail.com', '$2y$10$FicaficxR2H8MgGF9o9sS.zyJ54IgO/RoyWSxfQZrvbatc1rc7BKG', '2026-01-07 15:46:09', 'user'),
(2, 'rapip23', NULL, 'zenno19@gmail.com', '$2y$10$flXdpSTDq8la4sKt1lYQouipXEbMO.oXNeZwmKIwzwObY8LFxEV/u', '2026-01-14 14:46:20', 'user'),
(3, 'Rapip', NULL, 'rapip@gmail.com', '$2y$10$yrwQctv90Z3hDQ/FlPLnKO1e.0lj3aXXuJltRlumxKwBzUg1a2tf.', '2026-01-21 01:49:44', 'user'),
(4, 'Zen', '@zen20', 'zen19@gmail.com', '$2y$10$LUwrxZj2ygNX.5zvMr/vyudK9ef/2UKaigrwPxO50eG47z/1txqRy', '2026-01-21 07:32:23', 'user'),
(5, 'lixie', 'lixie12', 'lixiekawaii@gmail.com', '$2y$10$dbSxi5.uNu9YGa6uzbC7HePHp3QVlRN7Bb9QB9P3e/rcokulrH7Pm', '2026-01-21 12:23:11', 'user'),
(6, 'Baim', 'baim30', 'baim01@gmail.com', '$2y$10$d.naFFFs7BcBn18FWKwUgOvbBg1f/YE3a5sQLL6UbnjsCeninvWEW', '2026-01-22 04:47:43', 'user'),
(7, 'Administrator', 'admin', 'admin123@gmail.com', '$2y$10$FXBntPX7Yf45pbMsmSDA7Oc01qT1/QVKi5NwtAit05iDz.sqN3Jmy', '2026-01-22 16:29:26', 'admin'),
(8, 'yudha', 'yudha', 'yudha@gmail.com', '$2y$10$vv10nIMJrmzItV2.qeVjeOBy5wCKOa19XVcZ2gVVhMc3VSdQoYpk6', '2026-01-23 09:41:18', 'user');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `games`
--
ALTER TABLE `games`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `topup_transactions`
--
ALTER TABLE `topup_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `game_id` (`game_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `unique_email` (`email`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `games`
--
ALTER TABLE `games`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `topup_transactions`
--
ALTER TABLE `topup_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `topup_transactions`
--
ALTER TABLE `topup_transactions`
  ADD CONSTRAINT `topup_transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `topup_transactions_ibfk_2` FOREIGN KEY (`game_id`) REFERENCES `games` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
