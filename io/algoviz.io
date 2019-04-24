#!/usr/bin/env io

if(System args size < 2,
	"Usage: #{System launchScript} <io source file>" interpolate println
	System exit(1)
)

Yajl

CommandSender := Object clone do(
	socket ::= nil
	serializedSet ::= nil

	init := method(
		setSocket(
			Socket clone setHost("localhost") setPort(5555) connect
		)
		setSerializedSet(
			Map clone
		)
	)

	sendObject := method(obj,
		socket write(
			obj asJson .. "\n"
		)
	)

	isSerializable := method(value,
		return (value isKindOf(Number) or value isKindOf(String) or value isKindOf(Proxy) or value == true or value == false or value == nil)
	)

	serializeValue := method(value,
		if(value isKindOf(Map),
			return Map with("type", "map", "value", value)
		)

		if(value isKindOf(List),
			return value map(e, self serializeValue(e))
		)

		if(value isKindOf(Proxy),
			if(self serializedSet hasKey(value wrapped uniqueId)) then(
				return Map with("type", "proxy", "name", value name)
			) else(
				self serializedSet atPut(value wrapped uniqueId, true)
				return Map with("type", "proxy", "value", value)
			)
		)

		return value
	)

	send := method(name, methodName, args,
		obj := Map with(
			"methodName", methodName, 
			"args", args map(arg, self serializeValue(arg))
		)

		if(name,
			obj atPut("name", name)
		)

		sendObject(obj)
	)
)

cmdSender := CommandSender clone

Proxy := Object clone do(
	name ::= nil
	wrapped ::= nil

	with := method(name, obj,
		self clone setName(name) setWrapped(obj)
	)

	forward := method(
		cmdSender send(name, call message name, call evalArgs)
		call delegateTo(wrapped)
	)

	asString := method(
		call delegateTo(wrapped)
	)
)

Context := Object clone do(
	updateSlot := method(name, value,
		if(cmdSender isSerializable(value),
			cmdSender send(nil, "updateSlot", list(name, value))
			return resend
		)

		self updateSlot(name, Proxy with(name, value))
	)

	setSlot := method(name, value,
		if(cmdSender isSerializable(value),
			cmdSender send(nil, "setSlot", list(name, value))
			return resend
		)

		self setSlot(name, Proxy with(name, value))
	)
)

Algorithm := Object clone do(
	parameterNames ::= list()
	body ::= nil

	curlyBrackets := method(
		self setBody(call message arguments first)
	)

	call := method(
		context := Context clone
		parameterNames foreach(i, name,
			context setSlot(name, call evalArgAt(i))
		)

		return context doMessage(body)
	)
)

algorithm := method(
	Algorithm clone setParameterNames(call message arguments map(name))
)

filename := System args last

doFile(filename)
