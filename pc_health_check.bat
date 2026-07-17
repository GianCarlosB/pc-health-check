@echo off
setlocal EnableExtensions
cd /d "%~dp0"

:: ============================================================
:: PC HEALTH CHECK - Windows 10/11
:: Executar apos falhas (tela azul / BSOD, desligamento forcado)
::
:: Ordem de execucao:
::   1) DISM /Online /Cleanup-Image /RestoreHealth
::      (repara o repositorio de componentes usado pelo SFC)
::   2) DISM /Online /Cleanup-Image /StartComponentCleanup
::      (remove versoes antigas de componentes ja substituidos,
::       liberando espaco em disco - roda depois do RestoreHealth
::       para nao remover versoes que poderiam servir de reparo)
::   3) defrag C: /O
::      (otimiza o disco local C: - desfragmenta ou faz TRIM,
::       dependendo do tipo de disco)
::   4) sfc /scannow
::      (corrige arquivos do sistema usando o repositorio ja reparado)
::   5) chkdsk /r /f no disco do sistema (roda no proximo boot)
::   6) Pausa aguardando o usuario pressionar uma tecla e, em
::      seguida, reinicializacao do computador
:: ============================================================

:: --- Verifica se esta rodando como Administrador ---
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Este script precisa ser executado como Administrador.
    echo Solicitando elevacao de privilegios...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo ============================================================
echo   PC HEALTH CHECK - Windows 10/11
echo ============================================================
echo.

:: --- ETAPA 1: DISM RestoreHealth ---
echo [1/5] Executando: DISM /Online /Cleanup-Image /RestoreHealth
echo       (requer conexao com a internet, pode demorar bastante)
DISM /Online /Cleanup-Image /RestoreHealth
echo.

:: --- ETAPA 2: DISM StartComponentCleanup ---
echo [2/5] Executando: DISM /Online /Cleanup-Image /StartComponentCleanup
echo       (limpa componentes antigos do WinSxS, libera espaco em disco)
DISM /Online /Cleanup-Image /StartComponentCleanup
echo.

:: --- ETAPA 3: Otimizacao do disco local C: ---
echo [3/5] Executando: defrag C: /O
defrag C: /O /U
echo.

:: --- ETAPA 4: SFC ---
echo [4/5] Executando: sfc /scannow
echo       (pode levar varios minutos, aguarde...)
sfc /scannow
echo.

:: --- ETAPA 5: CHKDSK no disco do sistema ---
echo [5/5] Agendando: chkdsk %SystemDrive% /r /f
echo       O disco do sistema esta em uso, entao o Windows vai
echo       executar essa verificacao na proxima inicializacao.
:: Responde "S" (Sim) ao prompt de agendamento do CHKDSK.
:: Em Windows em ingles, trocar por "echo Y|" (Yes).
echo S| chkdsk %SystemDrive% /r /f
echo.

:: --- Pausa antes do reinicio ---
echo Todas as etapas foram executadas.
echo Pressione qualquer tecla para prosseguir com o REINICIO do computador...
pause >nul
echo.

echo ============================================================
echo   Todas as verificacoes foram executadas.
echo   O computador sera REINICIADO em 30 segundos para que o
echo   CHKDSK seja executado durante a inicializacao.
echo.
echo   Para CANCELAR: abra outro Prompt de Comando (admin) e
echo   execute o comando:   shutdown /a
echo ============================================================
echo.

shutdown /r /t 30 /c "Reiniciando para concluir a verificacao de disco (CHKDSK) apos PC Health Check."

:: Mantem a janela aberta para leitura das mensagens finais.
:: O reinicio agendado acima continua contando em segundo plano.
echo.
pause

endlocal
exit /b