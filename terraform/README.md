# Terraform IaC 프로젝트 구조 설명서

이 문서는 Onthe-Top 프로젝트의 Terraform 기반 개발/운영 프로젝트의 파일 구조, 항목 설명, 활용 방식, 변수 관리 전략, 그리고 개선 방향에 대한 정보를 제공합니다. 본 프로젝트는 AWS와 GCP를 병행 활용하며, Terraform의 모듈화와 환경 분리를 통해 체계적인 인프라 구성을 목표로 합니다.

## 디렉터리 구조

```
terraform/
├── aws/
│   ├── route53/            # Route 53 관련 호스팅  영역 설정
│   └── s3-cloudfront/      # S3 + CloudFront CDN 전략 설정
├── gcp/
│   ├── envs/
│   │   ├── shared/         # VPC, NAT, Router, VPN 같은 공통 인프라 구성
│   │   ├── dev/            # Dev 환경 Backend, DB 인스턴스 구성
│   │   ├── prod/           # Prod 환경 Backend, DB 인스턴스 구성 
│   │   ├── gpu-2/          # AI GPU 인스턴스 (현재 Dev)
│   │   └── gpu-3/          # AI GPU 인스턴스 (현재 Prod)
│   └── modules/            # 모듈화 (VPC, Subnet, MIG 등)
```

## 기본 환경 전략

1. shared 환경
  * 가장 먼저 terraform apply
  * VPC, Router, NAT Gateway, VPN 등 공용 자원을 구성
2. dev, prod 환경
  * dev: 단일 인스턴스에 Backend + DB 구성
  * prod: MIG, HTTPS Load Balancer, 인증서, Health Check 포함 고가용성 구성
3. gpu-2, gpu-3 환경
  * AI GPU 서버용 FastAPI 환경

## 모듈 구조

모든 인프라 구성 요소는 modules/ 하위에 모듈로 정의되어 있습니다.

* vpc, subnet, ip-internal, ip-external
* router, cloud_nat
* firewall, compute, instance-template, mig
* health-check, https-lb, peering 등

이를 통해 각 환경의 main.tf에서는 선언만으로 필요한 리소스를 반복 없이 구성할 수 있습니다.  
현재 peering은 직접 구축하였기 때문에 코드가 존재하지 않습니다.

## tfvars 변수 전략

### 공통 변수 파일 (envs/common.auto.tfvars)

```hcl
project_id = "your-project-id"
region     = "asia-northeast3"
ssh_keys   = "ssh-rsa AAAA..."
```

### 환경별 변수 파일 (예: envs/dev/terraform.tfvars)

```hcl
env                      = "dev"
private_subnet_cidr     = "10.10.10.0/24"
db_subnet_cidr          = "10.10.20.0/28"
backend_machine_type    = "e2-small"
backend_image           = "ubuntu-os-cloud/ubuntu-2404-lts"
```

공통 변수와 환경별 변수를 분리하여 효율적으로 관리하고, 팀 단위 협업 시 변경 충돌을 줄일 수 있습니다.

## 사용 방법

```bash
terraform plan -var-file=../common.auto.tfvars -var-file=./terraform.tfvars
terraform apply -var-file=../common.auto.tfvars -var-file=./terraform.tfvars
```

* common.auto.tfvars: 공통 환경 설정 포함
* terraform.tfvars: 환경별 설정(dev, prod 등)

## naming convention

리소스 명은 다음의 네이밍 컨벤션을 따릅니다:

```
<project>-<resource>-<env>-<purpose>
```

예: `onthetop-vpc-shared`, `onthetop-mig-prod-backend`

모든 모듈은 locals.tf에서 공통 접두어를 지정하여 일관성을 유지합니다.

## 실행 순서 가이드

1. shared: VPC, NAT, Router, VPN 등 공통 자원 구성
2. dev: 개발용 DB + Backend 단일 인스턴스 구성
3. prod: 운영용 MIG, LB, 인증서, 헬스체크 등 고가용성 구성

모든 환경은 독립적으로 관리되며, 필요한 경우 data 블록을 통해 다른 환경의 정보를 참조합니다.

## 관리 유의사항

* terraform apply 시 항상 -var-file로 명시적으로 지정
* Terraform Backend(GCS, S3)로 상태 관리를 설정할 수 있음
* Lock 파일 및 상태 파일은 Git으로 관리 금지

## 향후 개선 사항

* GitHub Actions 연동으로 Plan/Apply 자동화
* S3/CloudFront 캐시 정책 자동 관리
* Cross-project Peering 자동 구성
* 인증서 자동 발급 (ACME/DNS-01)
* Terraform state backend를 GCS로 마이그레이션

## 프로젝트 효과

Terraform 기반으로 AWS + GCP 멀티클라우드 인프라를 일관된 구조로 구성하고, 모듈화와 환경 분리를 통해 반복 작업을 줄였습니다. 누구나 쉽게 인프라를 관리할 수 있고, 환경별 파이프라인을 빠르게 구성하며, 롤백 및 장애 대응도 수월하게 할 수 있는 구조입니다.