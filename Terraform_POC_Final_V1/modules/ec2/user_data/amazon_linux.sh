#!/bin/bash
yum update -y
yum install -y httpd


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
        <p><strong>Operating System:</strong> Amazon Linux</p>
        <p><strong>Region:</strong> ${region}</p>
        <p><strong>Environment:</strong> ${environment}</p>
        <p><strong>Server Time:</strong> $(date)</p>
        <hr>
        <p>This is the primary region serving active traffic.</p>
    </div>
</body>
</html>
EOF


chown apache:apache /var/www/html/index.html
chmod 644 /var/www/html/index.html


systemctl enable httpd
systemctl start httpd


echo "OK" > /var/www/html/health.html


chkconfig httpd on

echo "User data script completed successfully"