-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 29, 2025 at 08:08 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bookstore`
--

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`) VALUES
(6, 'Fiksi'),
(8, 'Non-Fiksi'),
(9, 'Anak - Anak'),
(10, 'Bisnis');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `order_number` varchar(20) DEFAULT NULL,
  `status` enum('pending','paid','processing','shipped','delivered','cancelled') DEFAULT 'pending',
  `payment_method` enum('transfer_bank','credit_card','e_wallet','cod') DEFAULT 'transfer_bank',
  `payment_status` enum('pending','paid','failed') DEFAULT 'pending',
  `payment_proof` varchar(255) DEFAULT NULL,
  `payment_proof_uploaded_at` timestamp NULL DEFAULT NULL,
  `subtotal` float(10,2) NOT NULL DEFAULT 0.00,
  `shipping_cost` float(10,2) NOT NULL DEFAULT 0.00,
  `tax_amount` float(10,2) NOT NULL DEFAULT 0.00,
  `total_amount` float(10,2) NOT NULL DEFAULT 0.00,
  `shipping_address` text DEFAULT NULL,
  `shipping_city` varchar(100) DEFAULT NULL,
  `shipping_province` varchar(100) DEFAULT NULL,
  `shipping_postal_code` varchar(10) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `tracking_number` varchar(100) DEFAULT NULL,
  `shipped_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `review_status` enum('not_reviewed','reviewed') DEFAULT 'not_reviewed',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `shipping_option_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `order_number`, `status`, `payment_method`, `payment_status`, `payment_proof`, `payment_proof_uploaded_at`, `subtotal`, `shipping_cost`, `tax_amount`, `total_amount`, `shipping_address`, `shipping_city`, `shipping_province`, `shipping_postal_code`, `notes`, `tracking_number`, `shipped_at`, `delivered_at`, `review_status`, `created_at`, `updated_at`, `shipping_option_id`) VALUES
(13, 2, 'ORD-2025-6095', 'delivered', 'transfer_bank', 'paid', 'payment_proof_13_1748533567.jpg', '2025-05-29 10:46:07', 80000.00, 40000.00, 0.00, 120000.00, 'Jl. Gg. H. Naiman No.46 C, RT.06/06\r\nKebagusan, Pasar Minggu', 'Jakarta Selatan', 'DKI Jakarta', '12520', '', '8237438293874324', '2025-05-30 00:41:50', '2025-05-30 00:43:59', 'reviewed', '2025-05-29 22:46:07', '2025-05-30 00:52:01', 3);

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `product_image` varchar(255) DEFAULT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `price` float(10,2) NOT NULL,
  `subtotal` float(10,2) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `product_name`, `product_image`, `quantity`, `price`, `subtotal`, `created_at`) VALUES
(15, 13, 28, 'Your Money Your Attitude', 'uploads/product/product_683855a1d3e625.65578166.jpg', 2, 40000.00, 80000.00, '2025-05-29 22:46:07');

--
-- Triggers `order_items`
--
DELIMITER $$
CREATE TRIGGER `update_order_total_after_insert` AFTER INSERT ON `order_items` FOR EACH ROW BEGIN
    UPDATE orders 
    SET subtotal = (
        SELECT SUM(subtotal) 
        FROM order_items 
        WHERE order_id = NEW.order_id
    ),
    total_amount = subtotal + shipping_cost + tax_amount
    WHERE id = NEW.order_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_order_total_after_update` AFTER UPDATE ON `order_items` FOR EACH ROW BEGIN
    UPDATE orders 
    SET subtotal = (
        SELECT SUM(subtotal) 
        FROM order_items 
        WHERE order_id = NEW.order_id
    ),
    total_amount = subtotal + shipping_cost + tax_amount
    WHERE id = NEW.order_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `order_reviews`
--

CREATE TABLE `order_reviews` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rating` int(1) NOT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `review_text` text DEFAULT NULL,
  `review_date` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_reviews`
--

INSERT INTO `order_reviews` (`id`, `order_id`, `user_id`, `rating`, `review_text`, `review_date`, `updated_at`) VALUES
(3, 13, 2, 5, 'Produk terpercaya !!!', '2025-05-30 00:52:01', '2025-05-30 00:52:01');

-- --------------------------------------------------------

--
-- Table structure for table `payment_proofs`
--

CREATE TABLE `payment_proofs` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `original_filename` varchar(255) NOT NULL,
  `file_size` int(11) NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `price` float NOT NULL,
  `category_id` int(11) NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `stock` int(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `description`, `price`, `category_id`, `image_url`, `stock`) VALUES
(6, 'RADEN DEWI SARTIKA PENDIDIK BANGSA DARI PASUNDAN', 'Tak ada tanda-tanda istimewa saat Raden Ayu Rajapermas – istri Raden Rangga Somanagara seorang Patih Kadipaten Bandung melahirkan putri keduanya – Raden Dewi Sartika – selain kebahagiaan. Tetapi kemudian Dewi Sartika – sang aktivis dan pelopor pendidikan dari Pasundan – itu melewati waktu dengan kehebohan demi kehebohan. Pernah mengalami insiden patah tulang saat bermain yang menyebabkan ia menjadi kidal, menolak pinangan dua laki-laki bangsawan sebelum memilih seorang duda dari kalangan lebih rendah sebagai sikap menolak perjodohan dan poligami. Pada usia sepuluh tahun menghebohkan karena telah berhasil ‘menyulap’ anak-anak para pembantu di kepatihan bisa baca tulis dan mengucapkan beberapa patah kata bahasa Belanda. Kehebohan kemudian berlanjut ketika ia berhasil meluluhkan Bupati Bandung – R. Adipati Aria Martanegara yang tak lain adalah ‘musuh’ besar keluarganya sebagai buntut politik devide et impera Residen J.D. Harders – membantu meluluskan membangun sekolah istri.\r\n\r\nKetika Sekolah Istri yang didirikannya menuai kecurigaan Pemerintah Kolonial Belanda, Dewi Sartika berhasil meyakinkan Inspektur Pengajaran Hindia Belanda – C. De Hammer – berbalik haluan mendukung kiprah putri pemberontak itu. Dukungan juga muncul dari tokoh pergerakan nasional H.O.S Cokroaminoto. Hambatan terbesar justru datang dari keluarga yang menganggap tabu seorang anak perempuan mengenyam pendidikan. Persinggungan dengan sahabat suaminya – Sosrokartono dan Kardinah yang tak lain adalah kakak dan adik R.A. Kartini – membuktikan bagaimana gagasan untuk membuka kran pendidikan bagi perempuan yang selama ini dianggap tabu itu tidak hanya lokal Pasundan melainkan mendapat apresiasi secara nasional.\r\n\r\nDalam sebuah tulisan yang dipublikasikan di media cetak saat itu, Raden Dewi Sartika menulis: “Alangkah sedihnya mereka yang tidak bisa membaca dan menulis, karena orang yang demikian ibarat hidup di dalam kegelapan atau umpama orang buta yang berjalan di tengah hari. Maka jika jadi perempuan harus bisa segala-gala.” Gagasan itulah yang kemudian melahirkan Sekolah Kautamaan Istri dengan mengusung konsep cageur (sehat), bageur (baik) bener (benar), pinter (pintar), dan wanter (percaya diri). Dewi Sartika tak sekadar pencetus pendidikan kaum perempuan, tetapi seorang aktivis berintegritas yang mewakafkan kehidupannya untuk pendidikan. Tak heran bila menjelang wafatnya di pengungsian – Desa Cineam – hanya satu yang selalu dipikirkannya yaitu bagaimana kelangsungan sekolahnya, yang mengakibatkan penyakit gulanya kronis.', 50000, 6, 'uploads/product/product_6838190a86e817.56947193.jpg', 50),
(12, 'KISAH-KISAH PENGANTAR TIDUR BEDTIMES STORIES', 'Kumpulan cerita ini berisi 366 kisah yang cocok sebagai pengantar idur, bersama semua tokoh favorit Disney dan Disney Pixar. Ayo kita habiskan malam bersama Rapunzel, bermain sepanjang siang dengan Belle, dan menyambut bunga-bunga yang bermekaran bersama para peri Disney. Selama setahun penuh kau akan ditemani berbagai kisah yang menarik. Namun, kisah-kisah ini begitu mengasyikkan, jangan-jangan kau tak sabar menunggu saat menjelang tidur untuk membacanya!', 150000, 9, 'uploads/product/product_68382815261689.95409211.jpeg', 25),
(13, 'Syaikh Nawawi Al-Bantani: Biografi Sosial Intelektual Dan Spiritual', 'Syaikh Nawawi Al-Bantani adalah sosok ulama Nusantara kelahiran Banten berkaliber internasional. Mendapatkan banyak julukan, di antaranya al-Imam al-Muhaqqiq wa al-Fahhamah al-Mudaqqiq (Imam yang Mumpuni ilmunya), A\'yan Ulama al-Qarn al-Rabi\' Asyar li al-Hijrah (Tokoh Ulama Abad 14 Hijriyah), hingga Imam Ulama al-Haramain (Imam Ulama Dua Kota Suci). Beliau adalah seorang ulama dan intelektual yang sangat produktif menulis kitab, jumlah karyanya tidak kurang dari 115 kitab yang meliputi bidang ilmu fikih, tauhid, tasawuf, tafsir, dan hadis.\r\n\r\nBuku karya K.H. Zulfa Mustofa ini bisa dikatakan sebagai biografi resmi dan terlengkap yang membahas tuntas sejarah sosial, intelektual, spiritual, sanad guru, jejaring murid, pemikiran kebangsaan, inspirasi semangat antiimperialisme dan kolonialisme Sang Pemimpin Ulama Hijaz ini.\r\n\r\nBuku ini semakin menarik dan asyik, penulis menyajikan 57 bait nazam dalam Bahar Rajaz menceritakan sejarah hidup singkat Syaikh Nawawi Al-Bantani. Wajib dibaca oleh warga Nahdlatul Ulama dan seluruh masyarakat Indonesia.', 60000, 8, 'uploads/product/product_683826af8e7162.53615676.png', 11),
(14, 'SIFAT RASULULLAH SAW.: AMANAH', 'Rasulullah Saw. adalah Nabi yang penuh teladan. Sifatnya bisa dicontoh dalam keseharian. Adik-adik mau tahu, seperti apa, sih, sifat Rasulullah Saw. yang baik dan bisa kita contoh dalam keseharian? Baca buku ini, yuk!', 40000, 9, 'uploads/product/product_683828db964581.02025223.jpg', 9),
(15, 'SERI MAM: RAHASIA JARI-JEMARIMU', 'Ketika listrik mati dan di luar rumah sedang hujan, apa yang kamu lakukan? Pinjamlah senter milik Ayah. Ajaklah adik dan kakakmu bermain bayangan jari. Itu permainan mengasyikkan sekali. Tapi, ternyata banyak hal yang bisa kamu ketahui dari jari-jemarimu. Semula, itu merupakan rahasia. Sekarang, kamu bisa mengetahui ilmunya. Kamu penasaran? Duduk manis, ajak berkumpul teman-teman.\r\n\r\nBuku ini adalah cara dari penulis untuk menyampaikan keinginannya mengenalkan Al-Quran kepada anak-anak, yaitu dengan mngenalkan keistimewaan Al-Quran melalui Seri Al-Quran Menakjubkan. Oleh karena itu, penulis menghadirkan sebuah buku yang dikemas sedemikian rupa dengan gaya penulis yang cocok untuk anak-anak.\r\n\r\nBuku ini memang sangat cocok untuk anak-anak dalam memulai mengenal dan memulai untuk belajar Al-Quran. Penyajian pembahasan pada buku ini tidak begitu berat. Buku ini dihadirkan dengan gambar dan ilustrasi yang sangat menarik dan mudah diterima oleh anak-anak. Lalu, buku ini juga menceritakan contoh-contoh teladan dari tokoh Islam pada masa Nabi Muhammad Saw.\r\n\r\nAnak-anak akan belajar dengan sangat menyenangkan melalui penyampaian penulis tentang keistimewaan ayat-ayat Al-Quran. Anak-anak juga akan memahami bahwa ternyata ada ketersambungan antara keistimewaan Al-Quran dengan kehidupan, lingkungan, dan kebiasaan kita sehari-hari. Anak-anak jadi lebih tahu bahwa kehidupan di sekitar kita sebenarnya ada ketersambungannya dengan Al-Quran sebagai petunjuk hidup manusia. Anak-anak akan menjadi semakin yakin dengan keajaiban Al-Quran dan mereka akan tumbuh giroh semangat untuk menyenangi belajar Al-Quran. Mari dukung motivasi anak untuk mau belajar dari hal-hal yang ada di sekitar.', 25000, 9, 'uploads/product/product_683829bcb1df01.03641358.jpg', 10),
(16, 'SERI MAM: RAHASIA BULAN', 'Ketika malam tiba, keluarlah ke halaman dan lihatlah ke langit. Apakah ada sesuatu yang bersinar? Yap, itulah bulan. Terlihat indah, ya? Ajaklah teman-temanmu bermain di bawah sinar bulan. Mengasyikkan sekali. Tapi apakah kamu tahu bulan memiliki banyak rahasia? Dari bumi, sinar bulan terlihat menawan. Tapi bagaimana bentuk bulan sesungguhnya? Kemudian, kenapa bentuk bulan berubah-ubah ya? Bukalah buku ini dan temukanlah jawabannya.\r\n\r\nBuku ini adalah cara dari penulis untuk menyampaikan keinginannya mengenalkan Al-Quran kepada anak-anak, yaitu dengan mngenalkan keistimewaan Al-Quran melalui Seri Al-Quran Menakjubkan. Oleh karena itu, penulis menghadirkan sebuah buku yang dikemas sedemikian rupa dengan gaya penulis yang cocok untuk anak-anak.\r\n\r\nBuku ini memang sangat cocok untuk anak-anak dalam memulai mengenal dan memulai untuk belajar Al-Quran. Penyajian pembahasan pada buku ini tidak begitu berat. Buku ini dihadirkan dengan gambar dan ilustrasi yang sangat menarik dan mudah diterima oleh anak-anak. Lalu, buku ini juga menceritakan contoh-contoh teladan dari tokoh Islam pada masa Nabi Muhammad Saw.\r\n\r\nAnak-anak akan belajar dengan sangat menyenangkan melalui penyampaian penulis tentang keistimewaan ayat-ayat Al-Quran. Anak-anak juga akan memahami bahwa ternyata ada ketersambungan antara keistimewaan Al-Quran dengan kehidupan, lingkungan, dan kebiasaan kita sehari-hari. Anak-anak jadi lebih tahu bahwa kehidupan di sekitar kita sebenarnya ada ketersambungannya dengan Al-Quran sebagai petunjuk hidup manusia. Anak-anak akan menjadi semakin yakin dengan keajaiban Al-Quran dan mereka akan tumbuh giroh semangat untuk menyenangi belajar Al-Quran. Mari dukung motivasi anak untuk mau belajar dari hal-hal yang ada di sekitar.', 25000, 9, 'uploads/product/product_68382a03890999.71309345.jpg', 10),
(17, 'SERI MAM: RAHASIA LAUTAN', 'Lautan memiliki banyak rahasia dan misteri. Saking luas dan dalamnya, belum pernah ada manusia yang berhasil menjelajahi isinya. Tekanan air yang tinggi dan suhu yang dingin di laut dalam, membuat manusia tidak ada yang bisa bertahan lama menyelaminya. Tapi, tahukah kamu bahwa Al-Quran telah menceritakan banyak hal tentang lautan untuk manusia? Ratusan tahun yang lalu saat Al-Quran diturunkan, para sahabat Rasulullah terkagum-kagum dengan rahasia-rahasia yang Allah katakan tentang lautan. Rahasia-rahasia itu baru terbukti kemudian oleh teknologi manusia masa kini. Apa saja rahasia-rahasia itu? Yuk, jelajahi lewat buku ini.', 25000, 9, 'uploads/product/product_68382a40c5d639.71722668.jpg', 10),
(18, 'LAGU UNTUK RENJANA', '\"Orang-orang tak akan bertanya, jika pernyataan cinta selalu memiliki tujuan yang sama-- yakni bisa saling menerima. Selebihnya, sepasang kekasih harus menjaga masing-masing hati mereka. \"\r\n\r\nDialah Gabian, seorang musisi keturunan Indonesia Timur. Tak seperti biasanya, sebuah lagu entah kenapa seolah sulit dia selesaikan, tidak seperti lagu-lagu lainnya. Berbulan-bulan lagu itu tersimpan dalam buku catatan yang selalu dibawanya. \r\nSuatu ketika, Nana hadir dan mengisi sudut lain hati Gabian yang sulit ditembus gadis lain. Gadis energik dari keluaga berkecukupan dan memiliki gagasan-gagasan liar soal kehidupan.\r\nPertemuan yang tak pernah direncanakan, kencan yang berujung diskusi-diskusi panjang tentang kehidupan menjadi perayaan yang selalu menyenangkan. Mereka tak peduli kapan sepakat jadi sepasang kekasih, yang mereka percaya, cinta telah menguasai dengan caranya yang penuh rahasia.\r\nGabian tidak pernah tahu Nana menyembunyikan sesuatu di balik keliaran pikiran yang telah membuat Gabian jatuh hati. Apakah Gabian mampu menyelesaikan lagunya yang lama mengendap setelah Nana mengisi sunyi sudut hatinya?\r\n\r\nSedangkan lagu cinta yang asli, sekali kita mendengarnya, maka hati kita berkali-kali menyanyikannya.', 38000, 6, 'uploads/product/product_68382b324baa18.54867439.jpg', 22),
(19, 'DILAN DIA ADALAH DILANKU TAHUN 1990 (EDISI REVISI)', '\"Milea kamu cantik, tapi aku belum mencintaimu. Enggak tahu kalau sore. Tunggu aja.\" (Dilan 1990)\r\n\r\n\"Milea jangan pernah bilang ke aku ada yang menyakitimu., nanti besoknya, orang itu akan hilang.\" (Dilan 1990)\r\n\r\n\"Cinta sejati adalah kenyamanan, kepercayaan, dan dukungan. Kalau kamu tidak setuju, aku tidak peduli.\" (Milea 1990)', 90000, 6, 'uploads/product/product_68382b828c5905.47581619.jpg', 29),
(20, 'RUMAH TANPA JENDELA', 'Bukan besarnya rumah atau luas halaman dari balik pagar rendah yang memesona Rara, melainkan jajaran pot-pot cantik yang ditaruh di depan jendela-jendela besar rumah tersebut. Belum pernah Rara melihat jendela sedemikian indah. Mulai hari itu, ia punya sesuatu untuk diimpikan. Bapak dan Ibu harus tahu.\r\n\r\nRara adalah gadis yang periang dan suka bermain. Ia dan teman-temannya suka bermain di pinggir-pinggir jalan saat istirahat mengamen, di bawah derasnya hujan, juga di pekuburan tengah kota Jakarta yang menjadi lingkungan tempat tinggalnya. Sebagai gadis kecil, ia merasa tak kekurangan apa pun, apalagi orangtuanya tak pernah memarahinya seperti ibu-bapak teman-temannya. Tapi ada satu mimpi Rara yang inginsekali ia wujudkan. Sebuah mimpi sederhana, untuk memiliki jendela. Ia ingin sekali bisa tetap melihat hujan, dan tak harus menyalakan lampu ketika siang meski pintunya ditutup. Namun Rara tak tahu, keinginan sederhananya diam-diam membuat pusing orang-orang terdekatnya hingga gadis kecil itu harus membayar mahal agar mimpinya terwujud.', 60000, 6, 'uploads/product/product_68382bf70c6f23.46307806.jpg', 20),
(21, 'ASBUNAYAH', '“Bukan Tuhan yang harus kau cari, tetpi jawaban mengapa kamu bodoh mencari yang sudah bersamamu.”\r\n“Kalau Kehidupan ini Palsu, mengapa uangnya harus asli? Saya hanya butuh penjelasan.”\r\nJika doa bukan sebuah Permintaan, setidaknya itu adalah sebuah Pengakuan atas kelemahan diri manusia di hadapan-Nya.”\r\n“Di sekolah, mendapat pelajaran dulu, baru ujian. Kalau di Kehidupan ujian dulu, baru mendapat pelajaran.”\r\n“Mengapa istri harus bisa masak? Ini kan Rumah Tangga, bukan Rumah Makan?”\r\n“Aku Mencintaimu, biarlah ini urusanku. Bagaimana kamu kepadaku, terserah, itu urusanmu.”\r\n \r\n \r\n“Guk guk guk!”\r\n-Si Kucing, Anjing Herder Pidi Baiq\r\n \r\n“Rock on, Bad Boy”\r\nD. Bumelyte, Teman Rusia Pidi Baiq', 90000, 6, 'uploads/product/product_68382c61aeb263.97221630.jpg', 14),
(22, 'MENCERAHKAN BAKAT MENULIS', 'Mencerahkan Bakat Menulis adalah buku panduan praktis untuk berlatih menulis berbagai jenis tulisan ilmiah dan non-ilmiah bagi para pelajar, mahasiswa, guru, dosen, lembaga pendidikan, dan pihak terkait yang berkepentingan. Buku ini dirancang untuk mencerahkan bakat menulis, memperbaiki kualitas tulisan, meningkatkan budaya dan reputasi berkarya tulis.\r\n\r\nBuku ini membahas pentingnya menulis, masalah tulisan dan cara mencerahkan bakat menulis untuk meningkatkan kualitas tulisan melalui:\r\n• Penekanan proses penulisan yang mencakup persiapan, penulisan draf, revisi draf, penyuntingan, dan penerbitan.\r\n• Penulisan paragraf deduktif, induktif dan campuran yang mengandung kesatuan dan kepaduan.\r\n• Penulisan jenis-jenis paragraf dan tulisan berjudul seperti: narasi, deskriptif, eksplanasi, eksposisi, argumentasi, dan persuasi.\r\n• Penulisan artikel populer: berita, opini, dan fitur.\r\n• Penulisan artikel jurnal.\r\n• Penulisan skripsi, tesis, dan disertasi.\r\n• Penulisan dan penerbitan buku.\r\n• Penulisan puisi, pantun, syair, dan gurindam.\r\n• Penulisan Cerpen dan Novel.\r\n• Pencerahan kesalahan umum berbahasa Indonesia.\r\n• Pencerahan budaya plagiat.\r\n\r\nMencerahkan Bakat Menulis ditulis oleh seorang akademisi, praktisi menulis, pelatih menulis dan konsultan penerbitan buku. Sebagian besar isi buku ini sudah dipresentasikan dalam seminar dan workshop di berbagai perguruan tinggi dan lembaga pendidikan di seluruh Indonesia.', 138000, 8, 'uploads/product/product_68382d29668f97.67861101.jpg', 28),
(23, 'KITAB MASAKAN : KUMPULAN RESEP SEPANJANG MASA', '\"Kitab Masakan Sepanjang Masa\" ini memberikan inspirasi bagi Anda untuk menciptakan menu-menu favorit yang kaya variasi. Isinya pun sangat komplet, dari hidangan tempo dulu, masakan sehari-hari, aneka salad, hidangan mi, aneka nasi, aneka sayur, aneka ikan dan daging, kudapan, hingga kudapan pencuci mulut.\r\n\r\nHidangan ala barat, hidangan asia, hidangan seluruh penjuru nusantara juga tersaji lengkap di dalamnya. Tak salah lagi, buku resep super lengkap ini cocok Anda jadikan referensi di dapur, di tempat usaha, atau dijadikan kado buat sahabat dan kerabat.\r\n\r\nDijamin, Anda tak akan kehabisan ide lagi untuk memasak!', 265000, 8, 'uploads/product/product_68384bae939254.54428740.jpg', 30),
(24, 'PAPER ART ORIGAMI: ORNAMEN CANTIK UNTUK HIASAN DAN DEKOR', 'Beragam bentuk menarik dapat tercipta dengan cara melipat kertas menjadi kelihatan lebih indah. Ini lebih dikenal dengan istilah origami, ori berarti lipat dan kami berarti kertas dalam bahasa Jepang. Jadi origami adalah merupakan sebuah seni melipat kertas yang berasal dari Jepang. Kegiatan ini sangat menyenangkan, bisa meningkatkan keterampilan dan merangsang kreativitas serta daya imajinasi. Tidak salah bila seni ini banyak digemari kalangan remaja maupun dewasa.\r\n\r\nUntuk membuat Ornamen cantik dari kertas tidaklah sulit. Sebagai panduannya kami sajikan buku “ Paper Art Origami. Membuat Ornamen Cantik Untuk Hiasan dan Dekor” berisi 20 model ornamen dalam berbagai bentuk. Disajikan secara menarik dengan pembahasan yang lengkap dan mudah dimengerti juga dilengkapi dengan foto step by step yang memudahkan Anda untuk mulai aneka ornament tersebut dengan corak yang beragam. Kegiatan membuat ornamen cantik bisa dibuat oleh siapa saja mulai dari remaja sampai orang dewasa. Inipun bisa dijadikan salah satu kegiatan yang menyenangkan sekaligus mengembangkan daya kreativitasnya.', 75000, 8, 'uploads/product/product_68384defdd2306.54562452.jpg', 24),
(25, '101 Cara Kreatif Ala Steve Jobs', 'Sebagai seorang innovator dan pendiri perusahaan Apple, Steve Jobs telah membawa perubahan besar dalam dunia teknologi. Genius, ambisius, pantang menyerah. Mungkin itu pengggambaran yang tepat untuk sosok Steve Jobs. Melalui iPod dia telah menciptakan sebuah revolusi teknologi dalam industry music. Bahkan, kreativitas dan jiwa estetiknya telah membawa Pixar mencapai puncak kejayaan malalui film animasi, Toy Story.\r\n\r\nSteve Jobs adalah sosok yang melampaui zaman. Ada seratus sati (101) cara kreatif yang bisa kita teladani dari Sete Jobs, sebagai seorang pembawa perubahan. Ingatlah kutipan terkenal Jobs, â€œStay hungry, stay foolish.â€ (Selalu haus ilmu pengetahuan, dan teruslah mempelajari hal baru).', 80000, 8, 'uploads/product/product_68384f37c9c855.02265208.jpg', 20),
(26, 'Zero To One - Cover Baru', 'Apa perusahaan bernilai bisnis tinggi yang belum dibangun oleh siapa pun? Penerus Bill Gates tidak akan membuat sistem operasi. Penerus Larry Page atau Sergey Brin tidak akan membuat mesin pencari. Jika Anda meniru tokoh-tokoh itu, Anda tidak memetik pelajaran dari mereka. \r\n\r\nTentu saja, meniru itu lebih mudah daripada membuat sesuatu yang baru. Mengerjakan sesuatu yang sudah kita ketahui caranya sama saja membawa dunia ini dari 1 ke n, hanya menambahkan sesuatu yang memang sudah ada dan biasa. Namun, setiap kali kita menciptakan sesuatu yang baru, kita berangkat dari 0 ke 1. Buku ini akan memberi tahu bagaimana caranya. \r\n\r\n“Peter Thiel telah mendirikan banyak perusahaan pelopor, dan Zero to One akan mengajarkan caranya.” \r\n-ELON MUSK,- \r\nCEO SpaceX dan Tesla \r\n\r\n“Buku ini membawa ide-ide baru yang menyegarkan tentang cara menciptakan nilai di dunia.” \r\n-MARK ZUCKERBERG,- \r\nCEO Facebook \r\n\r\n“Jika ada buku yang ditulis oleh seorang pengambil risiko, bacalah. Khusus untuk buku Peter Thiel, bacalah dua kali. Atau, supaya aman, bacalah tiga kali. Ini buku klasik.” \r\n-NASSIM NICHOLAS TALEB,- \r\npenulis The Black Swan \r\n\r\nPETER THIEL adalah salah satu pendiri PayPal dan Palantir, salah seorang investor luar pertama Facebook, pemodal bagi perusahaan-perusahaan seperti SpaceX dan LinkedIn, serta pendiri Thiel Fellowship yang mendorong kaum muda untuk memprioritaskan belajar ketimbang menempuh pendidikan formal.', 62000, 10, 'uploads/product/product_6838552d3c8760.00104079.jpg', 32),
(27, 'Yuk Nabung Saham: Selamat Datang, Investor Indonesia!', 'Selama ini telah terjadi pemahaman yang keliru mengenai investasi di produk-produk pasar modal, seperti saham dan reksa dana, dimana selalu dikaitkan dengan \"mahal\" dan milik orang kaya, njlimet dan complicated, spekulatif dan high risk high gain. Ini pemahaman yang sepenuhnya salah. Yang pada akhirnya, membuat peluang meraih keuntungan berinvestasi di saham dan reksa dana berlalu begitu saja. Padahal dalam sepuluh tahun terakhir, Indonesia adalah negara dengan bursa efek yang mengalami kenaikan indeks tertinggi dibanding bursa-bursa utama dunia lainnya. Saat ini investasi begitu terjangkau, oleh siapapun dan apapun status kita. Entah mahasiswa atau ibu rumah tangga, entah buruh pabrik atau pegawai kantoran, entah nelayan atau supir kendaraan umum. Atau siapapun kita. Investasi bukanlah tindakan spekulasi, bukan pula kegiatan high risk high gain, karenanya tidak seharusnya dihindari. Investasi bukan lagi pilihan, karena investasi adalah kebutuhan. Lalu kapan waktu yang terbaik untuk mulai berinvestasi? Pada saat kita punya uang. Ya, saat ini kita punya uang dan saat ini adalah saatnya berinvestasi. Untuk tabungan masa depan kita. Untuk kesejahteraan kita, dan anak cucu kita.', 55000, 10, 'uploads/product/product_6838556a108184.64773857.jpg', 40),
(28, 'Your Money Your Attitude', '3 Hal Dasar Yang Menyelamatkan anda dari kesalahan finansial', 40000, 10, 'uploads/product/product_683855a1d3e625.65578166.jpg', 14),
(29, 'The 37 Most Powerful Tactics On Negotiation (Soft Cover)', '- Bagaimana cara menghadapi taktik FUTURE PROMISES?\r\n- Bagaimana cara menghadapi taktik HIGHER AUTHORITY?\r\n- Bagaimana cara menghadapi taktik GOOD GUY BAD GUY?\r\n- Bagaimana cara menghadapi taktik BUDGET RESTRAINT?\r\n- Bagaimana cara menghadapi taktik NIBBLING?\r\n- Bagaimana cara menghadapi taktik ABSURD PARAMETER?\r\n- Bagaimana cam menghadapi taktik EXPOSED COMPETITIVE INFORMATION?\r\n- 10 Perintah Negosiasi dan Power Inventory\r\n- Apa saja 4 Gaya Negosiasi Anda?\r\n- Aplikasi The DISC Codes dalam Negosiasi\r\n- Contoh opsi-opsi pertukaran dalam Negosiasi\r\n- Kisah-kisah menarik dalam Negosiasi', 65000, 10, 'uploads/product/product_683855d2e76896.67181236.jpg', 23),
(30, 'Marketing 4.0: Bergerak dari Tradisional ke Digital', '“Dewasa ini, dunia teknologi bergerak begitu cepat sehingga setiap perubahan mempercepat perubahan berikutnya. Menjadi penting di lingkungan seperti itu untuk memiliki garis dasar dan titik referensi guna membantu pemasar menemukan jalan ke depan. Marketing 4.0 menawarkan pengetahuan baru yang akan menjadi titik awal dan sumber daya yang berharga untuk semua orang yang mencoba menciptakan serta memahami masa depan digital dan mobile.” —Howard Tullman, CEO Chicagoland Entrepreneurial Center/1871\r\n“Internet dan IT mengubah pemasaran secara radikal. Buku ini adalah pembuka mata bagi pemasaran di era baru.” —Hermann Simon, Pendiri dan Ketua Simon-Kucher & Partners.', 55000, 10, 'uploads/product/product_68385fa40e93b9.34444008.jpg', 16);

-- --------------------------------------------------------

--
-- Table structure for table `shipping_options`
--

CREATE TABLE `shipping_options` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `cost` decimal(10,2) NOT NULL,
  `estimated_days` varchar(50) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `shipping_options`
--

INSERT INTO `shipping_options` (`id`, `name`, `description`, `cost`, `estimated_days`, `is_active`, `created_at`) VALUES
(1, 'Reguler (Pulau Jawa)', 'Pengiriman reguler dengan estimasi 2-4 hari kerja.', 15000.00, '2-4 hari kerja', 1, '2025-05-24 16:38:48'),
(2, 'Kargo (Luar Pulau Jawa)', 'Pengiriman kargo dengan estimasi 3-7 hari kerja.', 25000.00, '3-7 hari kerja', 1, '2025-05-24 16:38:48'),
(3, 'Same Day', 'Khusus pengiriman di wilayah Provinsi DKI Jakarta. Pengiriman diatas jam 14.00 dikirim besok.', 40000.00, '1 hari', 1, '2025-05-25 14:32:31');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `nama` varchar(255) NOT NULL,
  `no_telepon` varchar(20) NOT NULL,
  `address` text NOT NULL,
  `kota` varchar(15) NOT NULL,
  `provinsi` varchar(20) NOT NULL,
  `kode_pos` int(6) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','member') NOT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `nama`, `no_telepon`, `address`, `kota`, `provinsi`, `kode_pos`, `password`, `role`, `updated_at`) VALUES
(1, 'nada@admin.com', 'Admin - NADA BookStore', '0217991314', '', '', '', 0, '$2y$10$nFDeHxoM25d1KmhmJxPqt.YcgaDZKR/pjoUu45Pv5J0vJdnui1N0m', 'admin', NULL),
(2, 'senna.mathers43@gmail.com', 'Muhammad Senna', '081932981929', 'Jl. Gg. H. Naiman No.46 C, RT.06/06\r\nKebagusan, Pasar Minggu', 'Jakarta Selatan', 'DKI Jakarta', 12520, '$2y$10$ZD8r6hhjMI9027/AHp/NU.C.bPbFMAGY.7kqKraCRRwaAqwLlo3tq', 'member', '2025-05-25 17:35:43'),
(3, 'linda@bookstore.com', 'Linda Juliantari', '088378665432', 'Jl. Mangga Besar', 'Jakarta Pusat', 'DKI Jakarta', 0, '$2y$10$6gmmh2p5uZrtpDCdmw1K2eVMlSZEGn.lBNMHvuFeCJmo9gNNgmUSW', 'member', '2025-05-25 23:28:27');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `order_number` (`order_number`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `shipping_option_id` (`shipping_option_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_order_id` (`order_id`),
  ADD KEY `idx_product_id` (`product_id`);

--
-- Indexes for table `order_reviews`
--
ALTER TABLE `order_reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_order_review` (`order_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_rating` (`rating`),
  ADD KEY `idx_review_date` (`review_date`);

--
-- Indexes for table `payment_proofs`
--
ALTER TABLE `payment_proofs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `shipping_options`
--
ALTER TABLE `shipping_options`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `order_reviews`
--
ALTER TABLE `order_reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `payment_proofs`
--
ALTER TABLE `payment_proofs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `shipping_options`
--
ALTER TABLE `shipping_options`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`shipping_option_id`) REFERENCES `shipping_options` (`id`);

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `order_reviews`
--
ALTER TABLE `order_reviews`
  ADD CONSTRAINT `order_reviews_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `payment_proofs`
--
ALTER TABLE `payment_proofs`
  ADD CONSTRAINT `payment_proofs_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
