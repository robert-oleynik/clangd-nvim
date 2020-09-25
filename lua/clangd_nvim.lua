-- MIT License
--
-- Copyright (c) [year] [fullname]
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

local base64 = require'clangd_nvim/base64_decode'
local highlight = require'vim/highlight'

local M = {}

M.enabled = true
M.debug = false

local clangd_scopes = {}

local clangd_namespace = vim.api.nvim_create_namespace("vim_lsp_clangd_references")

local clangd_kind_to_highlight_group_map = {
	-- https://github.com/clangd/coc-clangd/blob/28e8d303b723716240e680090c86535582e7894f/src/semantic-highlighting.ts#L125
	-- https://github.com/llvm/llvm-project/blob/4e3a44d42eace1924c9cba3b7c1ea9cdbbd6cb48/clang-tools-extra/clangd/SemanticHighlighting.cpp#L584
	["entity.name.function.cpp"] = "ClangdFunction",
	["entity.name.function.method.cpp"] = "ClangdMemberFunction",
	["entity.name.function.method.static.cpp"] = "ClangdStaticMemberFunction",
	["variable.other.cpp"] = "ClangdVariable",
	["variable.other.local.cpp"] = "ClangdLocalVariable",
	["variable.parameter.cpp"] = "ClangdParameter",
	["variable.other.field.cpp"] = "ClangdField",
	["variable.other.static.field.cpp"] = "ClangdStaticField",
	["entity.name.type.class.cpp"] = "ClangdClass",
	["entity.name.type.enum.cpp"] = "ClangdEnum",
	["variable.other.enummember.cpp"] = "ClangdEnumConstant",
	["entity.name.type.typedef.cpp"] = "ClangdTypedef",
	["entity.name.type.dependent.cpp"] = "ClangdDependentType",
	["entity.name.other.dependent.cpp"] = "ClangdDependentName",
	["entity.name.namespace.cpp"] = "ClangdNamespace",
	["entity.name.type.template.cpp"] = "ClangdTemplateParameter",
	["entity.name.type.concept.cpp"] = "ClangdConcept",
	["storage.type.primitive.cpp"] = "ClangdPrimitive",
	["entity.name.function.preprocessor.cpp"] = "ClangdMacro",
	["meta.disabled"] = "ClangdInactiveCode",
}

local function clangd_decode_kind(scope)
	local result = clangd_kind_to_highlight_group_map[scope]
	if not result then
		return 'ClangdUnknown'
	end
	return result
end

local function highlight_references(bufnr,references)
	vim.validate { bufnr = {bufnr, 'n', true} }
	for _,ref in ipairs(references) do
		if M.debug then
			print(bufnr, ref.kind, vim.inspect(ref.range))
		end
		highlight.range(bufnr, clangd_namespace, ref.kind, ref.range.start_pos, ref.range.end_pos)
	end
end

local function clear_references(bufnr)
	vim.validate { bufnr = {bufnr, 'n', true} }
	vim.api.nvim_buf_clear_namespace(bufnr, clangd_namespace, 0, -1)
end


local function highlight(_,_,result,_)
	if not result or not M.enabled then
		return
	end

	local uri = result.textDocument.uri
	local file = string.gsub(uri,"file://","")

	for _,bufnum in ipairs(vim.api.nvim_list_bufs()) do
		local buf_name = vim.api.nvim_buf_get_name(bufnum)
		-- print(buf_name,file)
		if file==buf_name then
			local references = {}
			local references_index = 1
			for _, token in ipairs(result.lines) do
				local uint32array = base64.base64toUInt32Array(token.tokens)
				for j = 1,uint32array.size,2 do
					local start_character_index = uint32array.data[j]
					local length = bit.rshift(uint32array.data[j+1], 16)
					local scope_index = bit.band(uint32array.data[j+1], 0xffff)+1

					local ref = {
						range = {
							start_pos = {token.line, start_character_index},
							end_pos = {token.line, start_character_index + length}
						},
						kind = clangd_decode_kind(clangd_scopes[scope_index][1])
					}
					vim.api.nvim_buf_clear_namespace(bufnum, clangd_namespace, token.line, token.line)

					references[references_index] = ref
					references_index = references_index + 1
				end
			end

			-- clear_references(bufnum)
			highlight_references(bufnum, references)
		end
	end
end

function M.on_init(config)
	clangd_scopes = config.server_capabilities.semanticHighlighting.scopes
	config.callbacks['textDocument/semanticHighlighting'] = highlight
end

function M.clear_highlight()
	local buf_number = vim.api.nvim_get_current_buf()
	clear_references(buf_number)
end

function M.reload()
	M.clear_highlight()
	vim.api.nvim_command(":e")
end

function M.enable()
	M.enabled = true
	M.reload()
end

function M.disable()
	M.enabled = false
	M.clear_highlight()
end

return M
