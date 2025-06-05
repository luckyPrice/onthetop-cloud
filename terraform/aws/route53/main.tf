provider "aws" {
  region  = "ap-northeast-2"
  profile = "terraform"
}

resource "aws_route53_zone" "public" {
  name = "onthe-top.com"
}

resource "aws_route53_record" "onthe_top_com_a" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "onthe-top.com"
  type    = "A"
  ttl     = 60
  records = [

  ]
}
resource "aws_route53_record" "onthe_top_com_ns" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "onthe-top.com"
  type    = "NS"
  ttl     = 60
  records = [
    "ns-351.awsdns-43.com.",    "ns-1203.awsdns-22.org.",    "ns-1739.awsdns-25.co.uk.",    "ns-740.awsdns-28.net."
  ]
}
resource "aws_route53_record" "onthe_top_com_soa" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "onthe-top.com"
  type    = "SOA"
  ttl     = 60
  records = [
    "ns-351.awsdns-43.com. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
  ]
}
resource "aws_route53_record" "_569a9f281f2a09d33dd306c5e99b3e8c_onthe_top_com_cname" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "_569a9f281f2a09d33dd306c5e99b3e8c.onthe-top.com"
  type    = "CNAME"
  ttl     = 60
  records = [
    "_155cefb4e819d69ac77034b1bf351d44.xlfgrmvvlj.acm-validations.aws."
  ]
}
resource "aws_route53_record" "_acme_challenge_onthe_top_com_cname" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "_acme-challenge.onthe-top.com"
  type    = "CNAME"
  ttl     = 60
  records = [
    "8dba75a1-b928-41bc-8753-977ae2100d80.10.authorize.certificatemanager.goog."
  ]
}
resource "aws_route53_record" "_dmarc_onthe_top_com_txt" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "_dmarc.onthe-top.com"
  type    = "TXT"
  ttl     = 60
  records = ["\"v=DMARC1; p=none;\""]

}
resource "aws_route53_record" "bebuiorpv7ddw5qbp4h4srqy32hraifn__domainkey_onthe_top_com_cname" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "bebuiorpv7ddw5qbp4h4srqy32hraifn._domainkey.onthe-top.com"
  type    = "CNAME"
  ttl     = 60
  records = [
    "bebuiorpv7ddw5qbp4h4srqy32hraifn.dkim.amazonses.com"
  ]
}
resource "aws_route53_record" "k4zvwj2klw2dbarvkr3ohkqbovabaorp__domainkey_onthe_top_com_cname" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "k4zvwj2klw2dbarvkr3ohkqbovabaorp._domainkey.onthe-top.com"
  type    = "CNAME"
  ttl     = 60
  records = [
    "k4zvwj2klw2dbarvkr3ohkqbovabaorp.dkim.amazonses.com"
  ]
}
resource "aws_route53_record" "knkbluckxzmuqpyw2oklg5m6egghjklg__domainkey_onthe_top_com_cname" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "knkbluckxzmuqpyw2oklg5m6egghjklg._domainkey.onthe-top.com"
  type    = "CNAME"
  ttl     = 60
  records = [
    "knkbluckxzmuqpyw2oklg5m6egghjklg.dkim.amazonses.com"
  ]
}
resource "aws_route53_record" "ai_onthe_top_com_a" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "ai.onthe-top.com"
  type    = "A"
  ttl     = 60
  records = [
    "10.70.10.2"
  ]
}
resource "aws_route53_record" "alertmanager_onthe_top_com_a" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "alertmanager.onthe-top.com"
  type    = "A"
  ttl     = 60
  records = [
    "10.0.0.2"
  ]
}
resource "aws_route53_record" "backend_lb_onthe_top_com_a" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "backend-lb.onthe-top.com"
  type    = "A"
  ttl     = 60
  records = [
    "34.49.42.227"
  ]
}
resource "aws_route53_record" "_acme_challenge_backend_lb_onthe_top_com_cname" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "_acme-challenge.backend-lb.onthe-top.com"
  type    = "CNAME"
  ttl     = 60
  records = [
    "87e7be72-2755-4985-8338-1db88321a391.3.authorize.certificatemanager.goog."
  ]
}
resource "aws_route53_record" "backend_onthe_top_com_a" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "backend.onthe-top.com"
  type    = "A"
  ttl     = 60
  records = [
    "34.49.42.227"
  ]
}
resource "aws_route53_record" "dev_ai_onthe_top_com_a" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "dev-ai.onthe-top.com"
  type    = "A"
  ttl     = 60
  records = [
    "10.10.0.2"
  ]
}
resource "aws_route53_record" "dev_backend_onthe_top_com_a" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "dev-backend.onthe-top.com"
  type    = "A"
  ttl     = 60
  records = [
    "10.10.0.2"
  ]
}
resource "aws_route53_record" "dev_onthe_top_com_a" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "dev.onthe-top.com"
  type    = "A"
  ttl     = 60
  records = [
    "10.10.0.2"
  ]
}
resource "aws_route53_record" "grafana_onthe_top_com_a" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "grafana.onthe-top.com"
  type    = "A"
  ttl     = 60
  records = [
    "10.0.0.2"
  ]
}
resource "aws_route53_record" "img_onthe_top_com_a" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "img.onthe-top.com"
  type    = "A"
  ttl     = 60
  records = [

  ]
}
resource "aws_route53_record" "prometheus_onthe_top_com_a" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "prometheus.onthe-top.com"
  type    = "A"
  ttl     = 60
  records = [
    "10.0.0.2"
  ]
}
resource "aws_route53_record" "www_onthe_top_com_a" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "www.onthe-top.com"
  type    = "A"
  ttl     = 60
  records = [

  ]
}
