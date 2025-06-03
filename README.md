## Poc vLLM + AWS Inferentia (Inf2/Neuron)

**Ambiente local:**  Windows

### Pré-requisitos

Referências:
1. [Documentação AWS](https://awslabs.github.io/ai-on-eks/docs/blueprints/inference/Neuron/vllm-ray-inf2)
2. [README original do repositório](https://git.animaeducacao.com.br/generative-ia-pocs/open-source-inferentia-cluster-poc/-/blob/master/orginal/)

Softwares:
1. **aws cli** v2
2. **kubectl** v1.32
3. **k9s** (recomendado)
4. [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-windows.html)
5. **terraform** v1.5.6

Configuração:
1. Adicionar profile com nome **vllm-admin** com as credenciais da AWS via comando **aws configure** ou **aws configure sso**.

### Criação da Infraestrutura

**1 -** Selecionar diretório do contexto do terraform.

```
cd ...\open-source-inferentia-cluster-poc\infra\trainium-inferentia\terraform
```

**2 -** Registrar o plano de criação

```
terraform plan -out plan_create.bin -var-file=blueprint.tfvars
terraform show plan_create.bin > plan_create.txt
terraform show -json plan_create.bin > plan_create.json
```


**3 -** Executar script de instalação

```
terraform apply -target=module.vpc -var-file=blueprint.tfvars
terraform apply -target=module.eks -var-file=blueprint.tfvars
terraform apply  -var-file=blueprint.tfvars
```

#### Aplicar alterações

**1 -** Executar comando a seguir:

```
terraform apply -var-file=blueprint.tfvars
```

#### Remoção da infraestrutura

**2 -** Executar script de instalação

```
terraform destroy -var-file=blueprint.tfvars
```

### Operação

**1 -** Acesso ao cluster EKS via **kubectl** ou **k9s**

```
cd ...\open-source-inferentia-cluster-poc\infra\trainium-inferentia

.\AccessEks.ps1 -AwsProfile vllm-admin `
	-ClusterName eks-poc-vllm `
	-BastionHostName core-node-group `
	-LocalPort 8443
```
_Este acesso é realizado através de tunnel de conexão com SSM (AWS Session Manager) para o endpoit privado da api do Kubernetes (EKS)._
_Observações_
1. _A conta AWS deve ter o Session Manager habilitado_
2. _O usuário deve possuir as permissões **ssm:StartSession** e **ssm:TerminateSession**_

**2 -** Acesso a interface do **OpenWebUI**

Link: http://k8s-ingressn-ingressn-8f49a9a029-27389f8cca29312e.elb.us-east-1.amazonaws.com

**3 -** Acesso ao **Dashboard do Ray**

Executar:
``` 
kubectl -n vllm port-forward svc/vllm 8265:8265
```

Link: http://localhost:8265


**3 -** Acesso ao modelo LLM no padrão de API da OpenAI

Executar:
``` 
kubectl -n vllm port-forward svc/vllm-llama3-inf2-serve-svc 8000:8000
```

Exemplo: http://localhost:8000/v1/chat/completions