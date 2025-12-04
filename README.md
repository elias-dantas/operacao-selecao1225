# Desafio Técnico: Infraestrutura, SRE e DevOps

Seja bem-vindo(a) ao nosso processo seletivo!
Este teste tem como objetivo avaliar sua capacidade de analisar cenários, resolver problemas de infraestrutura e propor soluções resilientes.

**Entrega:** Link para um repositório público (GitHub/GitLab) contendo os códigos e a documentação.

---

## Regras do Jogo
1.  **Uso de IA:** Você **pode** utilizar ferramentas como ChatGPT, Claude ou Copilot. No entanto, queremos avaliar o **seu** raciocínio. Se usar IA, você deve revisar, corrigir e explicar o código gerado. Lembre que o foco é entender como você faz a análise dos cenários e propõe soluções.
2.  **Documentação é Código:** A forma como você explica suas decisões é tão importante quanto a solução rodando.

---

## Parte 1: Avaliação Teórica (Cenários)
No seu repositório, crie um arquivo chamado `RESPOSTAS.md`. Responda às 12 perguntas abaixo de forma sucinta. Foque no "porquê" das suas escolhas.

1. Cenário de Escala: Uma aplicação de e-commerce está sofrendo com lentidão na leitura do catálogo de produtos (PostgreSQL), mas a escrita (pedidos) é moderada. Qual estratégia você adotaria primeiro: Sharding ou Read Replicas? Justifique sua escolha considerando complexidade e custo.

2. Consistência: Você precisa armazenar dados de sessão de usuário (carrinho de compras temporário) que precisam de altíssima velocidade de escrita/leitura e expiram em 30 minutos. Você escolheria um banco SQL (ex: MySQL) ou NoSQL (ex: Redis/DynamoDB)? Por quê? Explique o conceito de CAP Theorem aplicado à sua escolha.

3. Métrica vs Log: O uso de CPU de um servidor subiu para 95%, mas a aplicação continua respondendo 200 OK. O time de desenvolvimento diz que não mudou nada. Que tipo de dado (Métrica, Log ou Trace) seria mais útil para diagnosticar a causa raiz imediata desse comportamento (ex: um loop infinito ou Garbage Collection) e por quê? 

4. Alertas: Em um plantão anterior, você recebeu 500 emails de alerta durante a noite informando que a "Latência estava alta", mas o sistema se recuperou sozinho em segundos. Isso gerou fadiga de alerta. Como você reestruturaria essa política de alertas usando conceitos de SRE (SLO/SLA/Error Budget)?

5. Autenticação Unificada: A empresa possui um Active Directory (AD) Windows on-premise e está subindo 50 servidores Linux na nuvem. O time de segurança exige que o login nos Linux seja feito com as mesmas credenciais do AD. Quais ferramentas ou protocolos você utilizaria para integrar o Linux ao AD (ex: SSSD, LDAP, Kerberos)? 

6. Automação Cross-Platform: Precisamos de um script que verifique espaço em disco e status de serviços tanto em servidores Windows Server quanto em Ubuntu. Qual linguagem ou ferramenta de configuração você escolheria para manter uma base de código única (ou o mais unificada possível) para gerir ambos?

7. Otimização de Imagem: Um desenvolvedor entregou uma imagem Docker de 2GB para uma aplicação Node.js simples. Isso está deixando o deploy lento. Cite 3 técnicas que você aplicaria no Dockerfile para reduzir drasticamente esse tamanho (ex: Multi-stage build). 

8. Troubleshooting Kubernetes: Um Pod está em status CrashLoopBackOff. O comando kubectl logs não retorna nada útil porque o container morre antes de escrever no stdout. Que outros comandos ou estratégias você usaria para descobrir por que o container não está subindo?

9. Segurança de Rede: Qual a diferença prática entre um Security Group e uma Network ACL (NACL) na AWS? Em qual cenário você precisaria bloquear explicitamente um IP malicioso? 

10. Gerenciamento de Custos: Um ambiente de desenvolvimento fica ligado 24/7, mas os devs só trabalham das 9h às 18h. Além de desligar as máquinas (schedule), que modelo de compra de instâncias (On-Demand, Savings Plan, Spot) você recomendaria para os ambientes de Produção vs. Desenvolvimento/CI para otimizar custos? 

11. Storage: Diferencie Block Storage (EBS) de Object Storage (S3). Se sua aplicação precisa processar uploads de fotos de usuários e depois servir essas fotos em um site estático, qual você usaria e por quê? 

12. IaC State: Por que é considerado uma má prática manter o arquivo de estado do Terraform (terraform.tfstate) na máquina local do engenheiro? Como você resolveria isso em um time de 5 pessoas?

---

## Parte 2: Desafio Prático - "Project Phoenix"

### Contexto
Você recebeu uma aplicação legada em Python que precisa ser modernizada para rodar na AWS. Atualmente, ela é instável e o processo de deploy é manual.

**Arquivos fornecidos:**
* `app.py`: O código da aplicação.
* `requirements.txt`: Dependências.

### Missão
Sua tarefa é containerizar a aplicação, provisionar a infraestrutura e criar uma automação de auto-recuperação.

#### Requisitos Técnicos:

1.  **Dockerização:**
    * Crie um `Dockerfile` otimizado e seguro para a aplicação.
    * Garanta que a aplicação esteja acessível externamente quando o container subir.

2.  **Infraestrutura como Código (IaC) e Gestão de Configuração:**
    * Utilize alguma solução de IaC (Terraform/Terragrunt, Cloudformation, etc) para provisionar uma instância EC2 (t3a.micro) na AWS.
    * A instância deve ter Docker instalado (via UserData, Ansible ou script de inicialização).
    * Garantir a segurança básica do SO (Linux).
    * Configure o Security Group adequadamente (princípio do menor privilégio).

_Atenção: A política de segurança da conta restringe o uso de recursos. Certifique-se de configurar seu Terraform para utilizar a região designada a você e o tipo de instância t3a.micro e um tamanho de volume máximo de 10GB. O uso de outros tipos de instância ou discos maiores resultará em erro de permissão._
    
_Você tem permissão para criar um bucket S3. Use se achar necessário. O nome dele é OBRIGATÓRIO seguir o padrão: group-infra-selecao-SEU_USUARIO_AWS. Exemplo: se seu login é devops-candidato-01, seu bucket deve ser group-infra-selecao-devops-candidato-01. Por questões de segurança, você não tem permissão de listar todos os buckets da conta. Ao acessar o console do S3, você verá erros de acesso. Isso é esperado. Para acessar seu bucket pelo console, use a URL direta: https://s3.console.aws.amazon.com/s3/buckets/group-infra-selecao-SEU_USUARIO ou utilize ferramentas de IaC._

3.  **Scripting & Self-Healing (O diferencial):**
    * A aplicação escreve logs em `/var/log/app_access.log`. Crie um script que rode no servidor para:
        * Monitorar o tamanho desse log. Se for maior que 10MB, rotacionar (comprimir/limpar).
        * Verificar se a aplicação responde HTTP 200. Se falhar, reiniciar o container automaticamente.

4.  **Diário de Bordo (a principal sessão deste exame):**
    * No arquivo `README.md` principal, inclua uma seção **"Decision Log"**.
    * Explique como você contornou o problema de rede da aplicação (dica: olhe o código Python).
    * Liste melhorias de segurança que você faria se tivesse mais tempo.
    * Descreva de forma detalhada como você lidou com o desafio e o que achou deste cenário.

---

**Lembre-se:** o foco da nossa avaliação é o seu raciocínio. Se não souber alguma resposta, não se preocupe. Foque em explicar bem o que você conhece. O Diário de Bordo é a principal sessão da sua documentação!

Boa sorte!

---

## Decision Log

### Problema de Rede
O código original rodava com `host='127.0.0.1'`, o que limita o Flask a aceitar apenas conexões locais (loopback). Isso **impede acesso externo**, tanto de outros containers quanto da internet. A solução foi alterar para `host='0.0.0.0'`, permitindo escuta em todas as interfaces de rede — padrão para aplicações em containers.

### Melhorias de Segurança (se houvesse mais tempo)
1. **Não escrever logs em arquivo dentro do container**: migrar logs para `stdout` e usar CloudWatch Logs via Fluent Bit.
2. **Usar IAM Roles para EC2**, não chaves de acesso.
3. **Imagem em ECR com scanning habilitado**.
4. **Hardening do Ubuntu**: CIS Benchmark, fail2ban, remoção de pacotes desnecessários.
5. **TLS/HTTPS** com ALB + ACM.
6. **Isolar instância em sub-rede privada** com NAT Gateway (não expor diretamente à internet).

### Reflexão sobre o Desafio
O cenário reflete desafios comuns em sistemas legados: código não preparado para a nuvem, logs mal gerenciados e deploy manual. A solução foi evolutiva: containerizar com alterações mínimas, garantir recuperação automática e usar infraestrutura declarativa com Terraform. O script de monitoramento serve como solução temporária até que uma observabilidade completa (como CloudWatch ou Prometheus) seja implantada. O principal aprendizado: infraestrutura moderna só funciona bem se a aplicação colaborar — com logs em stdout, health checks e boas práticas para nuvem.
