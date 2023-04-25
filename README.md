# OCI Security List for multiples accounts with Terraform module
* This module simplifies creating and configuring of Security List across multiple accounts on OCI

* Is possible use this module with one account using the standard profile or multi account using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Criate file provider.tf with the exemple code below:
```hcl
provider "oci" {
  alias   = "alias_profile_a"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.ssh_private_key_path
  region           = var.region
}

provider "oci" {
  alias   = "alias_profile_b"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.ssh_private_key_path
  region           = var.region
}
```


## Features enable of Security List configurations for this module:

- Security list

## Usage exemples


### Create security list with allow_cidr_blocks variable to used on rules that has no defined 

```hcl
module "security_list" {
  source = "web-virtua-oci-multi-account-modules/security-list/oci"

  compartment_id    = var.network_dev_compartment_id
  name              = "tf-security-list"
  vcn_id            = var.network_dev_vcn_id
  type              = "ingress"
  allow_cidr_blocks = ["192.168.10.10/32"]

  allow_rules_list = [
    {
      protocol    = "all"
      ports       = ["all"]
    },
    {
      protocol    = "tcp"
      cidr_blocks = ["3.218.27.211/32"]
      ports       = [22, 80]
    },
    {
      protocol    = "tcp"
      cidr_blocks = ["177.30.66.137/32"]
      ports       = [443, 30414]
    }
  ]

  providers = {
    oci = oci.alias_profile_a
  }
}
```


## Variables

| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| compartment_id | `string` | `-` | yes | Compartment ID | `-` |
| name | `string` | `-` | yes | Security list name | `-` |
| vcn_id | `string` | `-` | yes | VCN ID | `-` |
| compartment_name | `string` | `null` | no | Compartment name | `-` |
| type | `string` | `all` | no | If the security list is type of ingress | `*`all <br> `*`ingress <br> `*`egress |
| is_stateless | `bool` | `false` | no | If will be stateless | `*`false <br> `*`true |
| use_tags_default | `bool` | `true` | no | If true will be use the tags default to resources | `*`false <br> `*`true |
| tags | `map(any)` | `{}` | no | Tags to security list | `-` |
| defined_tags | `map(any)` | `{}` | no | Defined tags to security list | `-` |
| allow_cidr_blocks | `list(string)` | `[]` | no | Allow cidir blocks, if defined this values will be used in all cidr block for each rules | `-` |
| protocols | `object` | `object` | no | Available protocols, can be used the default protocols or customize, the values by default are all, icmp, ipv4, tcp, udp, ipv6 and icmpv6. Doc: others protocols http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml | `*`all <br> `*`icmp <br> `*`ipv4 <br> `*`tcp <br> `*`udp <br> `*`ipv6 <br> `*`icmpv6 |
| allow_rules_list | `list(object)` | `[]` | no | List with rules, ports and protocols allowed | `-` |


* Default variable protocols
```hcl
variable "protocols" {
  description = "Available protocols, can be used the default protocols or customize, the values by default are all, icmp, ipv4, tcp, udp, ipv6 and icmpv6. Doc: others protocols http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml"
  type        = object({
    all    = string
    icmp   = number
    ipv4   = number
    tcp    = number
    udp    = number
    ipv6   = number
    icmpv6 = number
  })
  default = {
    all    = "all"
    icmp   = 1
    ipv4   = 4
    tcp    = 6
    udp    = 17
    ipv6   = 41
    icmpv6 = 58
  }
}
```

* Model of allow_rules_list variable
```hcl
variable "allow_rules_list" {
  description = "List with rules, ports and protocols allowed"
  type = list(object({
    protocol         = string
    cidr_blocks      = optional(list(string))
    ports            = optional(list(any))
    description      = optional(string)
    destination_type = optional(string)
    icmp_options = optional(object({
      type = number
      code = number
    }))
    source_port_range = optional(object({
      max = number
      min = number
    }))
  }))
  default = [
    {
      protocol    = "tcp"
      cidr_blocks = ["3.218.27.135/32"]
      ports       = [22, 80]
    }
  ]
}
```


## Resources

| Name | Type |
|------|------|
| [oci_core_security_list.create_security_list](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list) | resource |

## Outputs

| Name | Description |
|------|-------------|
| `security_list` | Security List |
| `security_list_id` | Security List ID |
