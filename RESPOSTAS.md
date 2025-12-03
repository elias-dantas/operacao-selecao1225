1. Read Replicas, pois a leitura do catálogo é o gargalo, não a escrita. Read Replicas escalam leituras de forma simples, com baixa complexidade e menor custo comparado ao sharding, que exige particionamento lógico, reescrita de queries e gerenciamento de consistência entre shards.

2. NoSQL (ex: Redis). Dados de sessão são voláteis, de curta duração e exigem baixa latência, o Redis oferece alta performance em memória, expiração automática (TTL) e modelo de dados simples (chave-valor). Pelo CAP Theorem, Redis prioriza disponibilidade e particionamento ou consistência e particionamento, dependendo da configuração é  ideal para sessões, onde consistência imediata não é crítica, mas velocidade sim.

3. Utilizaria Trace + Métricas detalhadas. Métricas básicas como CPU %, não mostram o que está consumindo CPU. Um trace de profiling (ex: perf no Linux ou Application Insights) identifica funções/processos específicos como um loop infinito por exemplo. Logs não ajudam aqui, pois o problema é de execução, não de eventos registrados.

4. Substituir alertas baseados em métricas brutas por violações de SLO e definir um SLO de latência, como por exemplo 99% das requisições < 500ms. Alertar apenas quando o Error Budget está sendo consumido acima do aceitável, por exemplo o risco de quebrar o SLA em 1h. Isso evita alertas para picos transitórios e foca em impacto real ao usuário.

5. Usaria SSSD com Kerberos + LDAP. O SSSD integra Linux ao AD via protocolos padrão: Kerberos para autenticação (tickets seguros) e LDAP para consulta de usuários/grupos. Existem alternativas como realmd que automatizam essa configuração. Isso garante login unificado, sem senhas locais, alinhado à política de segurança.

6. Ansible é excelente opção para automação unificada, com módulos nativos para ambos os sistemas  e para manter uma base de código única. Temos outras opções como PowerShell Core (versão multiplataforma) ou Python com bibliotecas específicas (psutil + subprocess), entretanto, são soluções para implementações simples e pontuais.

7. Usar o Multi-stage build: compilar em uma imagem e copiar apenas os artefatos para uma base mínima (ex: node:alpine).
Usar base leve: substituir node por node:alpine ou node:slim.
Remover dependências de desenvolvimento: npm ci --only=production e limpar cache (npm cache clean --force).

8. Usaria o kubectl describe pod <nome>: mostra eventos e motivos de falha (ex: OOMKilled, ImagePullBackOff). O kubectl logs --previous: exibe logs do container anterior, mesmo que tenha falhado. Verificar readiness/liveness probes e resource limits no manifesto. Executar o container localmente com a mesma imagem e cmd para reproduzir o erro.

9. O Security Group é stateful, regras por instância, só permite (não pode negar), é aplicada na interface.
O NACL é stateless, regras por sub-rede, permite/nega, a ordem importa.
Para bloquear IP malicioso usamos NACL, pois é o único que suporta regras de DENY. Security Groups não podem negar tráfego.

10. Em produção utilizaria Savings Plans (compromisso de uso previsível → desconto estável) e em desenvolvimento/CI utilizaria Spot Instances (onde tolerável) ou On-Demand com schedule para desligar fora do horário de trabalho.

11. O EBS é storage de bloco, anexado a uma única instância, ideal para dados transacionais.
O S3 é storage de objeto, altamente escalável, acessível via HTTP, com TTL, versionamento e CDN integrado.
Para fotos de usuários em site estático o S3, que é escalável, barato e integra-se com CloudFront para entrega rápida é a melhor solução para esta atividade.

12. Manter terraform.tfstate localmente impede a colaboração (conflitos, estado inconsistente), risco de perda (sem backup) e não há histórico de mudanças.
Usando backend remoto (ex: AWS S3 + DynamoDB para locking) centraliza o estado, permite versionamento e bloqueio concorrente em time de 5 pessoas.
