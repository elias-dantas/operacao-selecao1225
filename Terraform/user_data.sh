#!/bin/bash
set -e

# Atualiza sistema
apt-get update && apt-get upgrade -y

# Instala Docker
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Adiciona usuário ubuntu ao grupo docker (opcional, para depuração)
usermod -aG docker ubuntu

# Cria diretório de log (necessário para bind mount)
mkdir -p /var/log/phoenix
chmod 777 /var/log/phoenix  # simplificação; ideal: usar usuário específico

# Executa container (supondo que a imagem foi previamente construída e armazenada em ECR ou Docker Hub)
# Para MVP, vamos construir localmente (não ideal para produção, mas aceitável no desafio)
cat > /home/ubuntu/app.py << 'EOF'
from flask import Flask
import os
app = Flask(__name__)
@app.route('/')
def hello():
    with open('/var/log/app_access.log', 'a') as f:
        f.write("Acesso recebido\n")
    return "Hello, Infrastructure Team!"
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))
EOF

cat > /home/ubuntu/requirements.txt << 'EOF'
Flask==2.3.3
EOF

cat > /home/ubuntu/Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
EOF

cd /home/ubuntu
docker build -t phoenix-app .
docker run -d --name phoenix -p 5000:5000 -v /var/log/phoenix:/var/log phoenix-app

# Cria o script de monitoramento self-healing
cat > /usr/local/bin/phoenix-monitor.sh << 'EOF'
#!/bin/bash
LOG_FILE="/var/log/app_access.log"
CONTAINER_NAME="phoenix"
MAX_LOG_SIZE=10485760  # 10 MB em bytes

# Rotaciona log se maior que 10MB
if [ -f "$LOG_FILE" ]; then
  if [ $(stat -c%s "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
    mv "$LOG_FILE" "$LOG_FILE.$(date +%s).old"
    touch "$LOG_FILE"
    chmod 644 "$LOG_FILE"
    gzip -f "$LOG_FILE.$(date +%s -d '1 sec').old" 2>/dev/null || true
  fi
fi

# Verifica se a app responde e reinicia o container se necessário
if ! curl -f --max-time 10 http://localhost:5000/ > /dev/null 2>&1; then
  echo "$(date): App inacessível. Reiniciando container '$CONTAINER_NAME'." >> /var/log/phoenix-monitor.log
  docker restart "$CONTAINER_NAME"
fi
EOF

# Torna o script executável
chmod +x /usr/local/bin/phoenix-monitor.sh

# Garante que o cron está ativo
systemctl enable --now cron

# Agenda a execução a cada 2 minutos
echo "*/2 * * * * /usr/local/bin/phoenix-monitor.sh" > /etc/cron.d/phoenix-monitor
chmod 644 /etc/cron.d/phoenix-monitor