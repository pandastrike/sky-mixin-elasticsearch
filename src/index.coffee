import getTemplate from "./template"

create = (SDK, global, meta, local) ->
  name = "elasticsearch"
  policy = []
  vpc = true
  template = await getTemplate SDK, global, meta, local

  {name, policy, vpc, template}

export default create
