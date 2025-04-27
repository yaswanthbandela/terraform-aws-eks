resource "aws_lb" "ingress_alb" {
  name               = "${var.project_name}-${var.environment}-ingress-alb"
  internal           = false # public ALB
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.ingress_sg_id.value]
  subnets            = split(",", data.aws_ssm_parameter.public_subnet_ids.value)

  enable_deletion_protection = false

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-ingress-alb"
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ingress_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.ingress_alb.arn
  port              = "443"

  protocol          = "HTTPS"
  certificate_arn   = data.aws_ssm_parameter.acm_certificate_arn.value
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>This is fixed response from Web ALB HTTPS</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_lb_target_group" "frontend" {
  name     = "${var.project_name}-${var.environment}-frontend"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Create a target group for the argoCD frontend service
resource "aws_lb_target_group" "argocd" {
  name        = "${var.project_name}-${var.environment}-argocd"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  health_check {
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Create a target group for grafana service
resource "aws_lb_target_group" "grafana" {
  name        = "${var.project_name}-${var.environment}-grafana"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100 # less number will be first validated

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
      # dev.homelabs.me --> frontend pod
      values = ["${var.environment}.${var.zone_name}"]
    }
  }
}

# Create a listener rule for the argocd service
resource "aws_lb_listener_rule" "argocd" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 101 # Ensure this doesn't conflict with existing priorities

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.argocd.arn
  }

  condition {
    host_header {
      values = ["argocd.${var.zone_name}"]
    }
  }
}

# Create a listener rule for the grafana service
resource "aws_lb_listener_rule" "grafana" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 102 # Ensure this doesn't conflict with existing priorities

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }

  condition {
    host_header {
      values = ["grafana.${var.zone_name}"]
    }
  }
}




module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name
  
  records = [
    {
      name    = "${var.environment}"
      type    = "A"
      allow_overwrite = true
      alias   = {
        name    = aws_lb.ingress_alb.dns_name
        zone_id = aws_lb.ingress_alb.zone_id
      }
    }
  ]
}

# Create a Route 53 record for the argocd service
module "argocd_records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name
  
  records = [
    {
      name    = "argocd"
      type    = "A"
      allow_overwrite = true
      alias   = {
        name    = aws_lb.ingress_alb.dns_name
        zone_id = aws_lb.ingress_alb.zone_id
      }
    }
  ]
}

# Create a Route 53 record for the grafana service
module "grafana_records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name
  
  records = [
    {
      name    = "grafana"
      type    = "A"
      allow_overwrite = true
      alias   = {
        name    = aws_lb.ingress_alb.dns_name
        zone_id = aws_lb.ingress_alb.zone_id
      }
    }
  ]
}
