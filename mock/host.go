package main

import (
	// to simulate Host Functions, use the PDK to manage host/guest memory.
	"encoding/json"

	pdk "github.com/extism/go-pdk"
)

// this is our in-memory KV store (e.g. a mock database)
var kv map[string][]string = make(map[string][]string)

// This export will be made available to the plugin as an import function.
// The offset param is the location in memory to the 'key' string
// The return offset is the location in memory to the 'value' string
//
//go:export KvRead
func KvRead(offset uint64) uint64 {
	// find the memory block that contains the key, read the bytes, and look up the
	// corresponding value in the KV store
	keyMem := pdk.FindMemory(offset)
	k := string(keyMem.ReadBytes())
	// if the entry is not found, return non-zero code
	v, ok := kv[k]
	if !ok {
		v = make([]string, 0)
	}

	// allocate a new memory block for the value, storing the string in memory
	valMem, _ := pdk.AllocateJSON(v)

	// return the memory offset
	return valMem.Offset()
}

// A struct to deserialize the JSON input behind the memory address passed to `KvWriteAppend`
// NOTE: you probably have these types defined somewhere else and can import them here
type WriteParams struct {
	Key   string `json:"key"`
	Value string `json:"value"`
}

// A struct to serialize the return from `KvWriteAppend` to store in memory.
// Non-zero `Code` value indicates an error.
// NOTE: you probably have these types defined somewhere else and can import them here
type WriteReturns struct {
	Message string `json:"message"`
	Code    int8   `json:"code"`
}

// This export will be made available to the plugin as an import function
// The offset param is the location in memory to the JSON-serialized 'WriteParams'
// The return offset is the location in memory to the JSON-serialized 'WriteReturns'
//
//go:export KvWriteAppend
func KvWriteAppend(offset uint64) uint64 {
	// find the memory block that contains the WriteParams,
	// read its bytes and deserialize into WriteParams
	paramsMem := pdk.FindMemory(offset)
	var params WriteParams
	err := json.Unmarshal(paramsMem.ReadBytes(), &params)
	if err != nil {
		mem, _ := pdk.AllocateJSON(WriteReturns{
			Message: err.Error(),
			Code:    2,
		})
		return mem.Offset()
	}

	// store the key-value pair in the KV store
	kv[params.Key] = append(kv[params.Key], params.Value)

	// return the WriteReturns offset for the caller to read
	mem, _ := pdk.AllocateJSON(WriteReturns{
		Message: "",
		Code:    0,
	})
	return mem.Offset()
}

// for now, an empty main function is required by the compiler
func main() {}
