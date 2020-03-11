#
# Input
#

variable "lb_allowed_cidr" {
  description = "Allowed CIDR list that can connect to the load balancer"
  default     = ["0.0.0.0/0"]
}

#
# Security
#

resource "aws_security_group" "lb" {
  name        = "test-lb"
  description = "Test Load Balancer Security Group"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    description = "Allow incoming on HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.lb_allowed_cidr}"
  }

  ingress {
    description = "Allow incoming on HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${var.lb_allowed_cidr}"
  }

  egress {
    description = "Connect to Traefik"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.aws_vpc_cidr}"]
  }

  egress {
    description = "Connect to goss for healthcheck"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.aws_vpc_cidr}"]
  }
}

resource "aws_lb_listener" "lb_http" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.cluster.arn}"
  }
}

resource "aws_lb" "lb" {
  name               = "test-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["${aws_subnet.public_a.id}", "${aws_subnet.public_b.id}", "${aws_subnet.public_c.id}"]
  security_groups    = ["${aws_security_group.lb.id}"]
}
