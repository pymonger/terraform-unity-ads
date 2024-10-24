locals {
  subnet_map = jsondecode(data.aws_ssm_parameter.subnet_list.value)

  cost_tags = {
    ServiceArea = "аds"
    Proj = "unity"
    Venue = "venue-dev"
    Component = "jupyterhub"
    CreatedBy = "ads"
    Env = "uads"
    Stack = "jupyterhub"
  }
}
