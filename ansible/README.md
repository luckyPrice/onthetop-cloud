# Monitoring Infrastructure Ansible Playbook

이 프로젝트는 Prometheus, Grafana, Alertmanager 기반의 모니터링 스택을 자동으로 설치하고 운영하기 위한 Ansible Playbook입니다.  
모든 구성 요소는 Docker 기반으로 배포되며, Nginx + Certbot을 통해 HTTPS를 적용합니다.

## 📦 구성 요소

- **Prometheus** : 모니터링 및 메트릭 수집
- **Grafana** : 메트릭 시각화 대시보드
- **Alertmanager** : 알람 및 알림 관리
- **Nginx** : 리버스 프록시 및 HTTPS 제공
- **Certbot** : Let's Encrypt 인증서 자동 발급 및 갱신
- **Common** : 공통 패키지 및 기본 설정

## 📁 프로젝트 구조

```perl
ansible/
├── ansible.cfg
├── group_vars/
│ └── all.yml # 전역 변수 설정
├── inventory.ini # 인벤토리 파일
├── roles/
│├── alertmanager/ # Alertmanager 설정 및 배포
│ ├── certbot/ # Certbot 인증서 발급 및 갱신
│ ├── common/ # 공통 작업 (패키지 설치 등)
│ ├── grafana/ # Grafana 설정 및 배포
│ ├── nginx/ # Nginx 설정 및 배포
│ └── prometheus/ # Prometheus 설정 및 배포
└── site.yml # 전체 플레이북
```

## 🚀 사용 방법

### 1. 인벤토리 파일 설정

`inventory.ini` 파일에 서버 정보를 입력합니다.

```ini
[monitoring]
monitoring-01 ansible_host=10.0.0.2 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### 2. 변수 설정
group_vars/all.yml 에 서비스별 경로, 이미지, 설정 경로 등을 정의합니다.

### 3. 실행
다음 명령어로 전체 구성을 배포합니다.

```bash
ansible-playbook -i inventory.ini site.yml
```

### 4. 인증서 갱신
인증서는 certbot Role을 통해 자동으로 갱신됩니다.
(renew cronjob + nginx reload hook 포함)

## 📌 참고
* 모든 서비스는 Docker + Host Network로 실행됩니다.
* Nginx는 80/443 포트로 외부 트래픽을 받아 각 서비스로 리버스 프록시합니다.
* 서브도메인을 사용한 접근을 기본으로 설계되어 있습니다. (ex: prometheus.example.com, grafana.example.com, alertmanager.example.com)

## 📎 관리 방법
* 모니터링 서버 추가 → inventory.ini 에 추가 후 Playbook 실행
* 서비스 설정 변경 → group_vars/all.yml 변경 후 Playbook 실행
* Alert rule, Grafana dashboard 변경 → roles/*/files/ 내 파일 수정 후 Playbook 실행
