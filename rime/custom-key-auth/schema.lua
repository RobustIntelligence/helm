local typedefs = require "kong.db.schema.typedefs"


return {
  name = "custom-key-auth",
  fields = {
      { protocols = typedefs.protocols_http },
      { config = {
          type = "record",
          fields = {
              { validation_endpoint = typedefs.url({ required = true }) },
              { token_header = { type = "string", default = "rime-api-key", required = true } },
              { map_headers = { type = "array", required = true, elements = { type = "string" }, default = {}, }, },
          },
      },
      }
  }
}
