#!/bin/bash
apt-get update -y
apt-get install -y apache2


cat > /var/www/html/index.html << EOF
<html>
<head>
    <title>Welcome</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }
        .header { background: #f8f9fa; padding: 10px; border-radius: 3px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Multi-Region Deployment</h1>
        </div>
        <h2>Hello from ${region} (${environment})</h2>
        <p><strong>Operating System:</strong> Ubuntu</p>
        <p><strong>Region:</strong> ${region}</p>
        <p><strong>Environment:</strong> ${environment}</p>
        <p><strong>Server Time:</strong> $(date)</p>
        <hr>
        <p>This is the secondary region serving as failover.</p>
    </div>
</body>
</html>
EOF


chown www-data:www-data /var/www/html/index.html
chmod 644 /var/www/html/index.html


systemctl enable apache2
systemctl start apache2


echo "OK" > /var/www/html/health.html

echo "User data script completed successfully"