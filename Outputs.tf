# output "public_dns" {
#  value = "${aws_instance.debian.*public_dns}"
#}

output "address" {
 value = "${aws_elb.web.dns_name}"
}
