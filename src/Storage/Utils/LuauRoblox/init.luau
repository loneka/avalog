local dom = require(script.dom)
local manager = require(script.core.manager)
local reflection = require(script.reflection)

local module = {}

module.dom = dom
module.manager = manager
module.reflection = reflection

function module.deserializePlace(contents: string | buffer)
	local content = if type(contents) == "string" then buffer.fromstring(contents) else contents
	local docs = dom.deserialize(content)
	return manager.placeFromDom(docs)
end

function module.deserializeModel(contents: string | buffer)
	local content = if type(contents) == "string" then buffer.fromstring(contents) else contents
	local docs = dom.deserialize(content)
	return manager.modelFromDOM(docs)
end

function module.serializePlace(dataModel: any, xml: boolean?): buffer
	local docs = manager.domFromPlace(dataModel)
	return dom.serialize(docs, if xml then "XML" else "BINARY")
end

function module.serializeModel(instances: { any }, xml: boolean?): buffer
	local docs = manager.domFromModel(instances)
	return dom.serialize(docs, if xml then "XML" else "BINARY")
end

function module.getReflectionDatabase(): reflection.ReflectionDatabase
	return reflection
end

return module
