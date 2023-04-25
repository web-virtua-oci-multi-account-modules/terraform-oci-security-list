locals {
  list = flatten([
    for item in var.allow_rules_list : [
      for port_range in item.ports : [length(split(",", trimspace(tostring(port_range)))) == 1 ? [
        for port in split(",", trimspace(tostring(port_range))) : {
          protocol          = var.protocols[item.protocol]
          cidr_blocks       = item.cidr_blocks != null ? item.cidr_blocks : var.allow_cidr_blocks
          description       = item.description
          destination_type  = item.destination_type
          icmp_options      = item.icmp_options
          source_port_range = item.source_port_range

          options = {
            min = port
            max = port
          }
          }] : [{
          protocol          = var.protocols[item.protocol]
          cidr_blocks       = item.cidr_blocks != null ? item.cidr_blocks : var.allow_cidr_blocks
          description       = item.description
          destination_type  = item.destination_type
          icmp_options      = item.icmp_options
          source_port_range = item.source_port_range

          options = {
            min = split(",", replace(port_range, " ", ""))[0]
            max = split(",", replace(port_range, " ", ""))[1]
          }
        }]
      ]
    ]
  ])

  security_list = flatten([
    for item in local.list : [
      for ip in item.cidr_blocks : {
        protocol          = item.protocol
        options           = item.options
        ip                = ip
        description       = item.description
        destination_type  = item.destination_type
        icmp_options      = item.icmp_options
        source_port_range = item.source_port_range
      }
    ]
  ])

  tags_security_list = {
    "tf-name"        = var.name
    "tf-type"        = "security-group"
    "tf-compartment" = var.compartment_name
  }
}

resource "oci_core_security_list" "create_security_list" {
  compartment_id = var.compartment_id
  display_name   = var.name
  vcn_id         = var.vcn_id
  defined_tags   = var.defined_tags
  freeform_tags  = merge(var.tags, var.use_tags_default ? local.tags_security_list : {})

  dynamic "egress_security_rules" {
    for_each = contains(["egress", "all"], var.type) ? local.security_list : []

    content {
      protocol    = egress_security_rules.value.protocol
      destination = egress_security_rules.value.ip
      stateless   = var.is_stateless

      description      = egress_security_rules.value.description
      destination_type = egress_security_rules.value.destination_type

      dynamic "icmp_options" {
        for_each = egress_security_rules.value.icmp_options != null ? [1] : []

        content {
          type = egress_security_rules.value.icmp_options.type
          code = egress_security_rules.value.icmp_options.code
        }
      }

      dynamic "tcp_options" {
        for_each = egress_security_rules.value.protocol == "6" ? [1] : []

        content {
          min = egress_security_rules.value.options.min == "all" ? 1 : egress_security_rules.value.options.min
          max = egress_security_rules.value.options.max == "all" ? 65535 : egress_security_rules.value.options.max

          dynamic "source_port_range" {
            for_each = egress_security_rules.value.source_port_range != null ? [1] : []

            content {
              min = egress_security_rules.value.source_port_range.min
              max = egress_security_rules.value.source_port_range.max
            }
          }
        }
      }

      dynamic "udp_options" {
        for_each = egress_security_rules.value.protocol == "17" ? [1] : []

        content {
          min = egress_security_rules.value.options.min == "all" ? 1 : egress_security_rules.value.options.min
          max = egress_security_rules.value.options.max == "all" ? 65535 : egress_security_rules.value.options.max

          dynamic "source_port_range" {
            for_each = egress_security_rules.value.source_port_range != null ? [1] : []

            content {
              min = egress_security_rules.value.source_port_range.min
              max = egress_security_rules.value.source_port_range.max
            }
          }
        }
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = contains(["ingress", "all"], var.type) ? local.security_list : []

    content {
      protocol  = ingress_security_rules.value.protocol
      source    = ingress_security_rules.value.ip
      stateless = var.is_stateless

      description = ingress_security_rules.value.description

      dynamic "icmp_options" {
        for_each = ingress_security_rules.value.icmp_options != null ? [1] : []

        content {
          type = ingress_security_rules.value.icmp_options.type
          code = ingress_security_rules.value.icmp_options.code
        }
      }

      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.protocol == "6" ? [1] : []

        content {
          min = ingress_security_rules.value.options.min == "all" ? 1 : ingress_security_rules.value.options.min
          max = ingress_security_rules.value.options.max == "all" ? 65535 : ingress_security_rules.value.options.max

          dynamic "source_port_range" {
            for_each = ingress_security_rules.value.source_port_range != null ? [1] : []

            content {
              min = ingress_security_rules.value.source_port_range.min
              max = ingress_security_rules.value.source_port_range.max
            }
          }
        }
      }

      dynamic "udp_options" {
        for_each = ingress_security_rules.value.protocol == "17" ? [1] : []

        content {
          min = ingress_security_rules.value.options.min == "all" ? 1 : ingress_security_rules.value.options.min
          max = ingress_security_rules.value.options.max == "all" ? 65535 : ingress_security_rules.value.options.max

          dynamic "source_port_range" {
            for_each = ingress_security_rules.value.source_port_range != null ? [1] : []

            content {
              min = ingress_security_rules.value.source_port_range.min
              max = ingress_security_rules.value.source_port_range.max
            }
          }
        }
      }
    }
  }
}
