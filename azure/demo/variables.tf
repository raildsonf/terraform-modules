variable "tags" {
  type = map(string)
  default = {
    TEAM    = "GK",
    STACK   = "webtier",
    OU      = "SRE",
    PROJECT = "unit"
  }
}

variable "subnet_ranges" {
  type = map(string)
  default = {
    "1" = "10.0.0.0/20",
    "2" = "10.0.16.0/20",
    "3" = "10.0.32.0/20"
  }
}