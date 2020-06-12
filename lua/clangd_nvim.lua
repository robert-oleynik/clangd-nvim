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

local base64 = require'clangd_nvim/base64'
local highlight = require'vim/highlight'

local clangd_scopes = {}

local clangd_namespace = vim.api.nvim_create_namespace("vim_lsp_clangd_references")

local function clangd_decode_kind(scope)
	-- Sources:
	--		- https://github.com/clangd/coc-clangd/blob/28e8d303b723716240e680090c86535582e7894f/src/semantic-highlighting.ts#L125
	--		- https://github.com/llvm/llvm-project/blob/4e3a44d42eace1924c9cba3b7c1ea9cdbbd6cb48/clang-tools-extra/clangd/SemanticHighlighting.cpp#L584
	if scope == "entity.name.function.cpp" then
		return "ClangdFunction" end
	if scope == "entity.name.function.method.cpp" then
		return "ClangdMethod" end
	if scope == "entity.name.function.method.static.cpp" then
		return "ClangdStaticMethod" end
	if scope == "variable.other.cpp" then
		return "ClangdVariable" end
	if scope == "variable.other.local.cpp" then
		return "ClangdLocalVariable" end
	if scope == "variable.parameter.cpp" then
		return "ClangdParameter" end
	if scope == "variable.other.field.cpp" then
		return "ClangdField" end
	if scope == "variable.other.static.field.cpp" then
		return "ClangdStaticField" end
	if scope == "entity.name.type.class.cpp" then
		return "ClangdClass" end
	if scope == "entity.name.type.enum.cpp" then
		return "ClangdEnum" end
	if scope == "variable.other.enummember.cpp" then
		return "ClangdEnumConstant" end
	if scope == "entity.name.type.typedef.cpp"
		then return "Typedef" end
	if scope == "Clangdentity.name.type.dependent.cpp" then
		return "DependentType" end
	if scope == "Clangdentity.name.other.dependent.cpp" then
		return "ClangdDependentName" end
	if scope == "entity.name.namespace.cpp" then
		return "ClangdNamespace" end
	if scope == "entity.name.type.template.cpp" then
		return "ClangdTemplate" end
	if scope == "entity.name.type.concept.cpp" then
		return "ClangdConcept" end
	if scope == "storage.type.primitive.cpp" then
		return "ClangdPrimitive" end
	if scope == "entity.name.function.preprocessor.cpp" then
		return "ClangdMacro" end
	if scope == "meta.disabled" then
		return "ClangdInactiveCode" end
	return 'Unknown'
end

local function highlight_references(bufnr,references)
	vim.validate { bufnr = {bufnr, 'n', true} }
	for _,ref in ipairs(references) do
		print(bufnr, clangd_namespace, ref.kind, ref.range.start_pos, ref.range.end_pos)
		highlight.range(bufnr, clangd_namespace, ref.kind, ref.range.start_pos, ref.range.end_pos)
	end
end

local function clear_references(bufnr)
	vim.validate { bufnr = {bufnr, 'n', true} }
	vim.api.nvim_buf_clear_namespace(bufnr, clangd_namespace, 0, -1)
end

local function on_init(config)
	clangd_scopes = config.server_capabilities.semanticHighlighting.scopes
	config.callbacks['textDocument/semanticHighlighting'] = function(_,_,result,_)
		print(vim.inspect(result))
		if not result then
			return
		end

		local references = {}
		local references_index = 1
		for i, token in ipairs(result.lines) do
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
				references[references_index] = ref
				references_index = references_index + 1
			end
		end

		print(vim.inspect(references))
		local buf_number = vim.api.nvim_get_current_buf()
		-- clear_references(buf_number)
		highlight_references(buf_number, references)
	end
end

return {
	on_init = on_init
}
