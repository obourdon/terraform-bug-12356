variable "cluster_size" {
  description = "Number of nodes in the cluster"
  default     = 3
}

resource "aws_security_group" "cluster" {
  name        = "test-cluster-sg"
  description = "test cluster Security Group"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow anything ingress"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow anything egress"
  }
}

resource "aws_placement_group" "cluster" {
  name     = "test-pg"
  strategy = "spread"
}

resource "aws_launch_template" "cluster" {
  name          = "test-lt"
  image_id      = "ami-07c25af0e918ce3c1" // CoreOS-stable-2345.3.0-hvm
  instance_type = "t3.medium"

  placement {
    group_name = "${aws_placement_group.cluster.id}"
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true

    security_groups = [
      "${aws_security_group.cluster.id}",
    ]
  }
}

resource "aws_autoscaling_group" "cluster" {
  name                      = "test-asg"
  max_size                  = "${var.cluster_size}"
  min_size                  = "${var.cluster_size}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = "${var.cluster_size}"
  force_delete              = true
  placement_group           = "${aws_placement_group.cluster.id}"
  vpc_zone_identifier       = ["${aws_subnet.public_a.id}", "${aws_subnet.public_b.id}", "${aws_subnet.public_c.id}"]
  termination_policies      = ["OldestLaunchConfiguration"]
  wait_for_capacity_timeout = 0
  target_group_arns         = ["${concat(list(aws_lb_target_group.cluster.arn), aws_lb_target_group.netdata.*.arn)}"]

  depends_on = ["aws_lb.lb"]

  launch_template {
    name    = "${aws_launch_template.cluster.name}"
    version = "${aws_launch_template.cluster.latest_version}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "cluster" {
  name                 = "test-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${aws_vpc.default.id}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 5
    timeout             = 3
    protocol            = "HTTP"
    port                = 8080
    path                = "/healthz"
  }
}
