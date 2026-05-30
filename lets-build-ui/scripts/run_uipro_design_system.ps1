Param(
  [Parameter(Mandatory = $true)][string]$Query,
  [Parameter(Mandatory = $false)][string]$ProjectName = "Project"
)

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
  $python = Get-Command python3 -ErrorAction SilentlyContinue
}
if (-not $python) {
  Write-Error "Python is required (python or python3)."
  exit 1
}

$candidatePaths = @(
  (Join-Path $PWD ".codex\\skills\\ui-ux-pro-max\\scripts\\search.py"),
  (Join-Path $PWD ".claude\\skills\\ui-ux-pro-max\\scripts\\search.py"),
  (Join-Path $PWD ".cursor\\skills\\ui-ux-pro-max\\scripts\\search.py"),
  (Join-Path $HOME ".codex\\skills\\ui-ux-pro-max\\scripts\\search.py"),
  (Join-Path $HOME ".claude\\skills\\ui-ux-pro-max\\scripts\\search.py"),
  (Join-Path $HOME ".cursor\\skills\\ui-ux-pro-max\\scripts\\search.py")
)

$searchPy = $null
foreach ($p in $candidatePaths) {
  if (Test-Path $p) {
    $searchPy = $p
    break
  }
}

if (-not $searchPy) {
  $searchPy = Get-ChildItem -Path $PWD, $HOME -Recurse -Depth 6 -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match "ui-ux-pro-max[\\\\/]scripts[\\\\/]search\\.py$" } |
    Select-Object -First 1 -ExpandProperty FullName
}

if (-not $searchPy) {
  Write-Error "Could not locate UI/UX Pro Max search.py. Proceed using the fallback brainstorm prompt instead."
  exit 1
}

& $python.Source $searchPy $Query --design-system -p $ProjectName
