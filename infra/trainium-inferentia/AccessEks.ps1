param (
	[string]$AwsProfile,
	[string]$ClusterName,
	[string]$BastionHostName,
	[string]$LocalPort
)

$KubeconfigPath = "~\.kube\config"
$LocalPortFowardHost = "https://localhost:$LocalPort"

if (-not (Get-Module -Name powershell-yaml)) {
	Install-Module -Name powershell-yaml -Scope CurrentUser -Force -Confirm:$false
    Import-Module -Name powershell-yaml -Force
}

aws sts get-caller-identity --profile $AwsProfile | Out-Null

if ($LASTEXITCODE -ne 0) {
	aws sso login --profile $AwsProfile
}

$YamlContent = Get-Content -Path $KubeconfigPath -Raw
$YamlObject = ConvertFrom-Yaml -Yaml $YamlContent
$SelectedCluster = ($YamlObject.clusters | Where-Object { $_.name -match $ClusterName }).cluster

if ($null -eq $SelectedCluster) {
	aws eks --region us-east-1 update-kubeconfig --name $ClusterName --alias $ClusterName --profile $AwsProfile

	$YamlContent = Get-Content -Path $KubeconfigPath -Raw
	$YamlObject = ConvertFrom-Yaml -Yaml $YamlContent
	$SelectedCluster = ($YamlObject.clusters | Where-Object { $_.name -match $ClusterName }).cluster
}

if ($SelectedCluster.server -ne $LocalPortFowardHost) {
	$ApiHost = $SelectedCluster.server.Replace("https://", "")
	$SelectedCluster.env = @(@{"name" = "KUBERNETES_SERVICE_HOST"; "value" = $ApiHost})
	$SelectedCluster.'tls-server-name' = $ApiHost
	$SelectedCluster.server = $LocalPortFowardHost

	ConvertTo-Yaml $YamlObject | Out-File -FilePath $KubeconfigPath -Encoding UTF8
}

$K8sApiHost = $SelectedCluster.'tls-server-name'

$InstanceId = (aws ec2 describe-instances `
	--filters "Name=tag:Name,Values=$BastionHostName" `
	--query 'Reservations[0].Instances[0].InstanceId' `
	--output text --profile $AwsProfile);

aws ssm start-session `
	--profile $AwsProfile `
	--target $InstanceId `
	--document-name AWS-StartPortForwardingSessionToRemoteHost `
	--parameters  ('{\""host\"":[\""' + $K8sApiHost + '\""],\""portNumber\"":[\""443\""], \""localPortNumber\"":[\""8443\""]}');