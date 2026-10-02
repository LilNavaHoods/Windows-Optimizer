# 🪟 Windows Optimizer

**Ferramenta de otimização e manutenção para Windows 10 e Windows 11**

![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=flat-square&logo=windows&logoColor=white)
![Batch](https://img.shields.io/badge/Linguagem-Batch-000000?style=flat-square)
![Admin](https://img.shields.io/badge/Requer-Administrador-red?style=flat-square)
![Status](https://img.shields.io/badge/Status-Estável-brightgreen?style=flat-square)

---

### 📋 O que é?

O **Windows Optimizer** é um script `.cmd` simples, completo e interativo projetado para realizar manutenções, limpezas, otimizações e instalações úteis no Windows. 

Ele centraliza os comandos mais importantes do sistema em um menu fácil de navegar. É a ferramenta ideal para preparar máquinas **pós-formatação** ou para realizar a **manutenção periódica** do seu computador.

---

### 🗺️ Roadmap e Funcionalidades (Checklist)

Abaixo você confere o que já está integrado ao sistema e o que está planejado para as próximas atualizações.

#### ✅ Funcionalidades Atuais
- [x] **Limpeza Profunda:** Remoção de arquivos Temporários, Prefetch, Cache e resíduos do Windows Update.
- [x] **Reparo do Sistema:** Execução automatizada de SFC, DISM e criação de Pontos de Restauração.
- [x] **Instalação Rápida de Programas:** Módulo via Winget com mais de 18 aplicativos essenciais em lote.
- [x] **Otimização de Desempenho:** Ajustes no Plano de Energia, SysMain, Efeitos Visuais e otimização para SSDs.
- [x] **Gerenciamento de Drivers:** Atalhos rápidos para NVIDIA, AMD, Intel e verificação da versão da BIOS.
- [x] **Reparo de Rede:** Reset completo das configurações de rede e Flush DNS.
- [x] **Diagnóstico do Sistema:** Geração de relatórios detalhados com informações da máquina.

#### 🚀 Planejado para o Futuro (Em Breve)
- [ ] **Menu DiskPart:** Interface simplificada para gerenciamento rápido de discos, partições e formatações.
- [ ] **Maior Biblioteca de Aplicativos e Serviços:** Expansão massiva do repositório de softwares instaláveis.
- [ ] **Download de ISOs:** Módulo integrado para buscar e baixar imagens oficiais do Windows e outras ferramentas.
- [ ] **Menu de Segurança do Windows:** Opções dedicadas para gerenciar o Windows Defender, Firewall e políticas de segurança.
- [ ] **Preparo de Pendrives Bootáveis:** Ferramenta nativa no script para a criação de mídias de instalação.

---

### 🚀 Como usar

1. Baixe o arquivo `Windows_Optimizer.cmd`.
2. Clique com o **botão direito** sobre o arquivo.
3. Selecione **Executar como administrador**.
4. Navegue pelo menu utilizando os números correspondentes às opções.

> ⚠️ **Importante:** O script precisa obrigatoriamente ser executado como Administrador para que as alterações no sistema tenham efeito.

---

### 📦 Programas disponíveis para instalação atual

*Atualmente instalados rapidamente via Winget:*
- **Utilitários:** 7-Zip, WinRAR, KeePass, Notepad++, Everything, ShareX, PowerToys, Adobe Reader
- **Navegadores:** Google Chrome, Mozilla Firefox, Brave
- **Comunicação e Mídia:** Telegram, Discord, VLC Media Player, Spotify
- **Desenvolvimento e Outros:** Visual Studio Code, qBittorrent

---

### ⚠️ Avisos e Cuidados

- **Backup primeiro:** Sempre crie um **Ponto de Restauração** antes de aplicar otimizações agressivas.
- **Bateria:** A desativação do **SysMain** e o uso do plano **Alto Desempenho** podem aumentar o consumo de energia (tenha atenção especial em notebooks).
- **Updates:** A limpeza avançada com `/ResetBase` impede a desinstalação de atualizações antigas do Windows.

#### 🛡️ Recomendação Especial para Windows 11

No **Windows 11**, o recurso **Controle de Aplicativos Inteligentes** (Smart App Control) pode bloquear a execução de scripts `.cmd` e de ferramentas de linha de comando como o Winget.

**Se o script fechar sozinho ou for bloqueado, siga estes passos:**
1. Abra a **Segurança do Windows**.
2. Vá em **Controle de aplicativos e navegador**.
3. Clique em **Configurações de Controle de Aplicativos Inteligentes**.
4. Selecione **Desativado**.
*(Após o uso do script, você pode reativar o recurso se desejar).*

---

### 📁 Estrutura de arquivos gerada

Durante a execução, o script cria automaticamente a seguinte estrutura para segurança e registro:
```text
%ProgramData%\WindowsOptimizer
 ├── logs\        → Histórico de ações e operações realizadas
 └── backups\     → Backups das configurações alteradas pelo script
