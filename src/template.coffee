import {resolve} from "path"
import {toJSON, isEmpty} from "panda-parchment"
import {read as _read} from "panda-quill"
import {yaml} from "panda-serialize"
import PandaTemplate from "panda-template"
import AJV from "ajv"

import preprocess from "./preprocess"

ajv = new AJV()
T = new PandaTemplate()
T.handlebars().registerHelper
    isEmpty: (input) -> isEmpty input

read = (name) ->
  await _read resolve __dirname, "..", "..", "..", "files", name

getTemplate = (SDK, global, meta, local) ->
  schema = yaml await read "schema.yaml"
  schema.definitions = yaml await read "definitions.yaml"
  template = await read "template.yaml"

  unless ajv.validate schema, local
    console.error toJSON ajv.errors, true
    throw new Error "failed to validate mixin configuration"

  T.render template, await preprocess SDK, global, meta, local

export default getTemplate
