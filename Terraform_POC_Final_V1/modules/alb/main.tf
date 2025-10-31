resource "aws_lb" "application_lb" {
  name               = "alb-${var.environment}-${var.region}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets           = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Environment = var.environment
    Name        = "alb-${var.environment}-${var.region}"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg-${var.environment}-${var.region}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"  # Accept any 2xx or 3xx status code
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  count            = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = var.instance_ids[count.index]
  port             = 80
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  tags = {
    Environment = var.environment
  }
}

# resource "aws_lb_listener" "web_listener_https" {
#   load_balancer_arn = aws_lb.application_lb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.certificate_arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.web_tg.arn
#   }
# }

output "alb_dns_name" {
  value = aws_lb.application_lb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.application_lb.zone_id
}

output "alb_arn" {
  value = aws_lb.application_lb.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.web_tg.arn
}