variable "netdata_enable" {
  description = "Monitor nodes using netdata or not (1/on or 0/off)"
  default     = 1
}

resource "aws_lb_listener_rule" "netdata_http" {
  count        = var.netdata_enable * var.cluster_size
  listener_arn = aws_lb_listener.lb_http.arn

  action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.netdata.*.arn, count.index)
  }

  condition {
    host_header {
      values = ["netdata-${count.index}.example.com"]
    }
  }
}

resource "aws_lb_target_group" "netdata" {
  count                = var.netdata_enable * var.cluster_size
  name                 = "test-tg-nd${count.index}"
  port                 = 19999
  protocol             = "HTTP"
  vpc_id               = aws_vpc.default.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 6
    timeout             = 5
    protocol            = "HTTP"
    port                = 19999
    path                = "/"
    matcher             = "200"
  }
}

resource "aws_security_group_rule" "netdata" {
  count       = var.netdata_enable
  description = "Connect to netdata"
  type        = "egress"
  from_port   = 19999
  to_port     = 19999
  protocol    = "tcp"
  cidr_blocks = [var.aws_vpc_cidr]
 
  security_group_id = aws_security_group.lb.id
}

resource "null_resource" "netdata-domain" {
  count = var.cluster_size * var.netdata_enable

  triggers = {
    url = "http://netdata-${count.index}.example.com"
  }
}

output "netdata-url" {
  value = "${formatlist("%v", null_resource.netdata-domain.*.triggers.url)}"
}
