-- MIT License
--
-- Copyright (c) 2020 Robert John Oleynik
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local function map_to_value(char)
	if(char >= 65 and char <= 90) then -- between A and Z: 00-25
		return char-65
	end
	if(char >= 97 and char <= 122) then -- between a and z: 26-51
		return char-71
	end
	if(char >= 48 and char <= 57) then -- between 0 and 9: 52-61
		return char+4
	end
	if(char == 43) then -- +: 62
		return 62
	end
	if(char == 47) then -- /: 63
		return 63
	end
	return 0 -- padding
end

local function decode(str)
	local arr = {}
	local arr_index = 1
	local padding = 0
	for i = 1,string.len(str),4 do
		local int32 = 0
		for pos = 0,3 do
			local val = map_to_value(string.byte(str,i+pos))
			int32 = bit.lshift(int32,6)
			int32 = int32 + val
			if string.byte(str,i+pos) == 61 then -- padding
				padding = padding + 1
			end
		end
		for j = 2,0,-1 do
			arr[arr_index+j] = bit.band(int32,0xff)
			int32 = bit.rshift(int32, 8)
		end
		arr_index = arr_index+3
	end
	arr_index = arr_index - padding
	return {
		data = arr,
		size = arr_index - 1
	}
end

local function base64toUInt32Array(str)
	local str_decoded = decode(str)
	local data = {}

	for i = 1,str_decoded.size,4 do
		local v = 0
		for j = 0,3 do
			v = bit.lshift(v, 8)
			v = v + str_decoded.data[i+j]
		end
		data[(i+3)/4] = v
	end

	return {
		data = data,
		size = str_decoded.size/4
	}
end

return {
	decode = decode,
	base64toUInt32Array = base64toUInt32Array
}
