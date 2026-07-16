# PC Health Check

Script em lote (`.bat`) para Windows 10/11 que automatiza uma rotina completa de verificação e reparo do sistema. Pensado para ser executado após falhas como tela azul (BSOD) ou desligamentos forçados.

## O que o script faz

O [pc_health_check.bat](pc_health_check.bat) executa, em ordem, as seguintes etapas:

| # | Comando | Finalidade |
|---|---------|-----------|
| 1 | `DISM /Online /Cleanup-Image /RestoreHealth` | Repara o repositório de componentes do Windows (WinSxS), usado como fonte pelo SFC |
| 2 | `DISM /Online /Cleanup-Image /StartComponentCleanup` | Remove versões antigas de componentes já substituídos, liberando espaço em disco |
| 3 | `sfc /scannow` | Verifica e corrige arquivos do sistema usando o repositório já reparado |
| 4 | `defrag C: /O /U` | Otimiza o disco C: (desfragmentação em HDD ou TRIM em SSD, conforme o tipo de disco) |
| 5 | `chkdsk %SystemDrive% /r /f` | Agenda verificação completa do disco do sistema para a próxima inicialização |

Ao final, o computador é **reiniciado automaticamente em 30 segundos** para que o CHKDSK agendado seja executado durante o boot.

### Por que essa ordem?

- O `RestoreHealth` roda **antes** do `StartComponentCleanup` para que a limpeza não remova versões de componentes que poderiam servir de fonte de reparo.
- O `sfc /scannow` roda **depois** do DISM porque ele usa o repositório de componentes como fonte — reparar o repositório primeiro aumenta a chance de o SFC corrigir os arquivos com sucesso.
- O CHKDSK fica por último porque o disco do sistema está em uso e a verificação só pode ocorrer no próximo boot.

## Requisitos

- Windows 10 ou 11
- Privilégios de **Administrador** (o script detecta e solicita elevação automaticamente via UAC)
- Conexão com a internet (necessária para o `DISM /RestoreHealth` baixar arquivos do Windows Update, se preciso)

## Como usar

1. Dê um duplo clique em `pc_health_check.bat` (ou execute pelo Prompt de Comando).
2. Confirme a solicitação de elevação do UAC, se aparecer.
3. Aguarde a conclusão das etapas — o processo pode demorar bastante, principalmente o DISM e o SFC.
4. O computador será reiniciado automaticamente ao final e o CHKDSK rodará durante a inicialização.

### Cancelar o reinício automático

Se precisar cancelar o reinício dentro da janela de 30 segundos, abra outro Prompt de Comando **como Administrador** e execute:

```cmd
shutdown /a
```

## Avisos

- **Salve todo o seu trabalho antes de executar** — o computador será reiniciado ao final sem confirmação adicional.
- A verificação do CHKDSK com `/r` durante o boot pode levar de vários minutos a algumas horas, dependendo do tamanho e do estado do disco.
- O script assume que o sistema está instalado no disco `C:` para a etapa de otimização (`defrag`).
