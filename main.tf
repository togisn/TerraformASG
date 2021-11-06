resource "aws_launch_configuration" "ec2" {
  depends_on = [
    aws_security_group.allow_http,
  ]

  name_prefix = "ec2-"

  image_id      = "ami-0fed77069cd5a6d6c" #Ubuntu Server 20.04 LTS (HVM)
  instance_type = "t2.medium"

  security_groups = [aws_security_group.allow_http.id]
  user_data       = <<EOT
#cloud-config
# update apt on boot
package_update: true
# install nginx
packages:
- nginx
EOT

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  depends_on = [
    aws_launch_configuration.ec2
  ]

  name = "${aws_launch_configuration.ec2.name}-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 5

  health_check_type = "ELB"
  load_balancers = [
    aws_elb.elb.id
  ]

  launch_configuration = aws_launch_configuration.ec2.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier = [
    aws_subnet.nated.id
  ]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "ec2"
    propagate_at_launch = true
  }
}
