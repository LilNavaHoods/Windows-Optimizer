# 🪟 WinHood

**Painel de otimização e manutenção para Windows 10 e Windows 11**

![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=flat-square&logo=windows&logoColor=white)
![React](https://img.shields.io/badge/Frontend-React%20%2B%20TypeScript-61DAFB?style=flat-square&logo=react&logoColor=black)
![Python](https://img.shields.io/badge/Backend-Python-3776AB?style=flat-square&logo=python&logoColor=white)
![Admin](https://img.shields.io/badge/Requer-Administrador-red?style=flat-square)
![Status](https://img.shields.io/badge/Status-v5.0%20(Em%20Empacotamento)-brightgreen?style=flat-square)

> 🚧 **Atenção:** O WinHood está atualmente em processo de empacotamento para se tornar um **arquivo executável único (.exe)**. Durante essa fase de transição para a versão 5.0, a estrutura está sendo adaptada para que, no futuro, não seja mais necessário instalar dependências manuais (como Python ou Node.js).

---

### 📋 O que é?

O **WinHood** é uma central de suporte local para Windows: interface moderna em React e backend Python que executa as rotinas do sistema com privilégios de administrador.

Ele centraliza limpeza, reparo, instalação de programas (Winget), desempenho, rede, inventário e armazenamento em um painel fácil de usar. Ideal para preparar máquinas **pós-formatação** ou para a **manutenção periódica** do computador.

O navegador **nunca** executa comandos do Windows diretamente. O fluxo é:

`React (painel) → API local Python → Windows → resultado/log → React`

---

### 🗺️ Roadmap e funcionalidades

#### ✅ Funcionalidades atuais

- [x] **Interface gráfica (React + Vite + TypeScript)** com tema claro/escuro e status do backend em tempo real
- [x] **Backend local Python** (biblioteca padrão — sem FastAPI/Flask)
- [x] **Comunicação robusta** — proxy Vite `/api`, CORS local, timeouts, erros de rede vs HTTP, saída expandível
- [x] **Limpeza:** rápida (script original), avançada (CleanMgr) e Windows Update (DISM StartComponentCleanup)
- [x] **Reparo do sistema:** ponto de restauração, SFC, DISM e verificação combinada
- [x] **Instalação de programas (Winget):** catálogo por categoria, seleção individual e atualização em lote
- [x] **Otimização de desempenho:** plano de energia, SysMain, efeitos visuais, TRIM/SSD e remoção de bloatware
- [x] **Drivers e vídeo:** atalhos NVIDIA, AMD, Intel e consulta de BIOS
- [x] **Rede:** teste de conectividade, Flush DNS, renovação de IP e reset Winsock/TCP-IP
- [x] **Diagnóstico:** inventário real (Windows, CPU, RAM, GPU, BIOS), hardware, relatório técnico e MSInfo32
- [x] **Armazenamento:** Gerenciamento de Disco, listagem de discos/volumes, guia DiskPart e abertura do DiskPart
- [x] **Logs em JSONL** com timestamp, ação, status, duração e código de saída

#### 🚀 Planejado para o futuro

- [ ] Maior biblioteca de aplicativos e serviços no catálogo Winget
- [ ] Download de ISOs oficiais do Windows e ferramentas de suporte
- [ ] Menu de segurança (Defender, Firewall e políticas)
- [ ] Preparo de pendrives bootáveis
- [ ] Progresso em tempo real (SSE/WebSocket) para rotinas longas (SFC/DISM)
- [x] **Empacotamento em executável único para distribuição** *(Em andamento para a versão 5.0)*

---

### 🏗️ Arquitetura

| Camada | Tecnologia | Função |
|--------|------------|--------|
| **Frontend** | React 19 + TypeScript + Vite + Tailwind CSS | Painel visual e chamadas à API |
| **Backend** | Python (`http.server`) | Executa comandos Windows e devolve JSON |
| **Limpeza** | `backend/cleanup_script.bat` | Rotina de limpeza profunda herdada do script original |
| **API** | `http://127.0.0.1:8765` | Endpoints `/api/health`, `/action`, `/install`, etc. |

**Comunicação frontend ↔ backend**

- Em desenvolvimento, o Vite faz **proxy** de `/api/*` para `http://127.0.0.1:8765` (sem CORS no browser)
- Fallback absoluto se o app for aberto fora do dev server
- CORS no backend libera origens `localhost` / `127.0.0.1` (qualquer porta)
- Camada de API no React com timeout, `AbortController`, parse JSON seguro e distinção rede vs HTTP
- `/api/health` expõe `version`, `admin` e `winget` — o painel exibe esse status
- Falhas de negócio retornam HTTP 200 com `success: false` (install parcial usa 207)
- Saída longa (`output`) pode ser expandida no toast após a ação

---

### 📦 Programas disponíveis para instalação (Winget)

Organizados por categoria no painel:

- **Navegadores e comunicação:** Chrome, Firefox, Edge, Brave, Opera, Vivaldi, Discord, Telegram, Zoom, Teams, Thunderbird, Slack
- **Utilitários de suporte:** 7-Zip, WinRAR, PeaZip, PowerToys, Everything, ShareX, WinDirStat, WizTree, AnyDesk, TeamViewer, TeraCopy, Revo Uninstaller
- **Desenvolvimento e runtimes:** VS Code, Notepad++, Git, Python 3, Node.js LTS, FileZilla, PuTTY, WinSCP, WinMerge, .NET Runtime, Java Temurin

Também é possível **atualizar todos os programas** instalados via Winget em um único clique.

---

### ⚠️ Avisos e cuidados

- **Backup primeiro:** crie um **Ponto de Restauração** antes de otimizações agressivas.
- **Bateria:** desativar o **SysMain** e usar o plano **Alto Desempenho** pode aumentar o consumo em notebooks.
- **DiskPart:** operações destrutivas exigem confirmação no próprio DiskPart — use com atenção.
- **Updates:** limpezas profundas de componentes podem limitar a desinstalação de atualizações antigas.

#### 🛡️ Windows 11 — Controle de Aplicativos Inteligentes

O **Smart App Control** pode bloquear scripts e o Winget.

1. Abra a **Segurança do Windows**
2. Vá em **Controle de aplicativos e navegador**
3. Clique em **Configurações de Controle de Aplicativos Inteligentes**
4. Selecione **Desativado**

*(Você pode reativar depois do uso.)*

---

### 📁 Estrutura do projeto

```text
WinHood/
├── src/                    → Frontend React + TypeScript
│   ├── App.tsx             → Painel principal e camada de API
│   ├── main.tsx
│   └── index.css
├── backend/
│   ├── server.py           → API local Python (porta 8765)
│   └── cleanup_script.bat    → Rotina de limpeza profunda
├── package.json
├── vite.config.ts            → Dev server + proxy /api → :8765
├── tsconfig.json
└── README.md
