<?php
$env = getenv('APP_ENV') ?: 'local';

echo '<link rel="stylesheet" href="/static/style.css">';

$host = getenv('DB_HOST');
$db = getenv('DB_NAME');
$user = getenv('DB_USER');
$pass = getenv('DB_PASS');


echo "<h1>Devops Technical Test - Application PHP</h1>";
echo "<p>PHP version: " . PHP_VERSION . "</p>";
echo "<p>Environnement : " . htmlspecialchars($env) . "</p>";

if (in_array(false, [$host, $db, $user, $pass], true)) {
    echo "<p>Configuration de la bd incomplète :variables d'environnement manquantes.</p>";
} else {
    if (str_starts_with($host, '/cloudsql/')) {
        $dsn = "mysql:unix_socket=$host;dbname=$db;charset=utf8mb4";
    } else {
        $dsn = "mysql:host=$host;dbname=$db;charset=utf8mb4";
    }

    $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_TIMEOUT => 3,
    ];

    try {
        $pdo = new PDO($dsn, $user, $pass, $options);
        echo "<p>Connexion base de données : OK</p>";
    } catch (PDOException $e) {
        echo "<p>Connexion base de données : Échec</p>";
        error_log($e->getMessage());
    }
}  
