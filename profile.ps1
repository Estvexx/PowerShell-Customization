$env:POWERSHELL_TELEMETRY_OPTOUT = "1"

# 1. Oh-My-Posh (carregamento mínimo)
$null = [System.IO.File]::Exists("$HOME\temaEstvexx.omp.json") -and 
    (oh-my-posh init pwsh --config "$HOME\temaEstvexx.omp.json" | Invoke-Expression)

# 2. Terminal-Icons (carregamento inteligente)
$global:TerminalIconsLoaded = $false
$global:TerminalIconsCheckDone = $false

function __CheckTerminalIcons {
    if (-not $global:TerminalIconsCheckDone) {
        $global:TerminalIconsCheckDone = $true
        
        # Verifica se o módulo já está na memória
        if (Get-Module Terminal-Icons -ErrorAction SilentlyContinue) {
            $global:TerminalIconsLoaded = $true
            return
        }

        # Carrega de forma assíncrona
        $null = Register-EngineEvent -SourceIdentifier TerminalIconsLoader -Action {
            if (-not $global:TerminalIconsLoaded) {
                Import-Module Terminal-Icons -ErrorAction SilentlyContinue
                $global:TerminalIconsLoaded = $true
            }
            Remove-Event -SourceIdentifier TerminalIconsLoader
            Get-EventSubscriber -SourceIdentifier TerminalIconsLoader | Unregister-Event
        }
        
        $null = New-Event -SourceIdentifier TerminalIconsLoader
    }
}

# 3. Prompt modificado (mínimo overhead)
if ($function:prompt -like '*__CheckTerminalIcons*') {} else {
    $originalPrompt = $function:prompt
    function global:prompt {
        __CheckTerminalIcons
        & $originalPrompt
    }
}
