# 🪟 Windows Optimizer

**Ferramenta de otimização e manutenção para Windows 10 e Windows 11**

![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=flat-square&logo=windows&logoColor=white)
![Batch](https://img.shields.io/badge/Linguagem-Batch-000000?style=flat-square)
![Admin](https://img.shields.io/badge/Requer-Administrador-red?style=flat-square)
![Status](https://img.shields.io/badge/Status-Estável-brightgreen?style=flat-square)

---

### 📋 O que é?

O **Windows Optimizer** é um script `.cmd` simples e completo para realizar manutenções, limpezas, otimizações e instalações úteis no Windows, tudo através de um menu interativo.

Ideal para pós-formatação ou manutenção periódica.

---

### ✨ Funcionalidades

| Categoria              | Recursos                                      |
|------------------------|-----------------------------------------------|
| **Limpeza**            | Temporários, Prefetch, Cache, Windows Update |
| **Reparo**             | SFC, DISM, Ponto de Restauração              |
| **Programas**          | Instalação rápida via Winget (18+ apps)      |
| **Desempenho**         | Plano de energia, SysMain, efeitos visuais, SSD |
| **Drivers**            | Atalhos NVIDIA / AMD / Intel + verificação de BIOS |
| **Rede**               | Reset completo, Flush DNS                    |
| **Sistema**            | Informações detalhadas + relatório           |

---

### 🚀 Como usar

1. Baixe o arquivo `Windows_Optimizer.cmd`
2. Clique com o **botão direito** no arquivo
3. Selecione **Executar como administrador**
4. Navegue pelo menu usando os números

> ⚠️ **Importante:** O script precisa ser executado como Administrador.

---

### 📦 Programas disponíveis para instalação

- 7-Zip, WinRAR, KeePass, Notepad++, Everything, ShareX  
- Chrome, Firefox, Brave  
- Telegram, Discord, VLC, Spotify  
- Visual Studio Code, PowerToys, qBittorrent, Adobe Reader

---

### ⚠️ Avisos

- Sempre crie um **Ponto de Restauração** antes de aplicar otimizações agressivas.
- A desativação do **SysMain** e o uso do plano **Alto Desempenho** podem aumentar o consumo de energia (especialmente em notebooks).
- A limpeza com `/ResetBase` impede a desinstalação de atualizações antigas do Windows.

#### Recomendação para Windows 11

No **Windows 11**, o recurso **Controle de Aplicativos Inteligentes** (Smart App Control) pode bloquear a execução de scripts `.cmd` e ferramentas como o Winget.

**Recomendação:**  
Desative temporariamente o *Controle de Aplicativos Inteligentes* caso o script seja bloqueado ou feche sozinho:

1. Abra a **Segurança do Windows**
2. Vá em **Controle de aplicativos e navegador**
3. Clique em **Configurações de Controle de Aplicativos Inteligentes**
4. Selecione **Desativado**

Após o uso do script, você pode reativar o recurso se desejar.

---

### 📁 Estrutura de arquivos

O script cria automaticamente:
%ProgramData%\WindowsOptimizer

├── logs\          → Histórico de ações
└── backups\       → Backups das configurações alteradas


---

### 📜 Histórico de Versões

As versões anteriores estão disponíveis em formato `.txt` para consulta:

- `Windows_Optimizer_v1.txt`
- `Windows_Optimizer_v2.txt`
- `Windows_Optimizer_v3.1.txt`

Esses arquivos servem como histórico de desenvolvimento e referência.

---

### 📄 Licença

Este projeto é de código aberto. Sinta-se livre para modificar e distribuir.

---

**Desenvolvido para uso pessoal e educacional.**  
Use com responsabilidade.
