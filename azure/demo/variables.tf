variable "tags" {
  type = map(string)
  default = {
    TEAM    = "GK",
    STACK   = "webtier",
    OU      = "SRE",
    PROJECT = "unit"
  }
}