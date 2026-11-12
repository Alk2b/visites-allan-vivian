variable "TAG" {
  default = "dev"
}

group "default" {
  targets = ["app"]
}

target "app" {
  context    = "."
  dockerfile = "Dockerfile"
  tags       = ["ghcr.io/alk2b/visites-allan-vivian:${TAG}"]
  platforms  = ["linux/amd64"]
}
