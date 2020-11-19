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

local base64 = require'clangd_nvim/base64_decode'
local highlight = require'vim/highlight'

local M = {}

M.clangd_namespace = vim.api.nvim_create_namespace("clangd_nvim_namespace")
M.clangd_types = {
	"ClangdVariable",
	"ClangdLocalVariable",
	"ClangdParameter",
	"ClangdFunction",
	"ClangdMemberFunction",
	"ClangdStaticMemberFunction",
	"ClangdField",
	"ClangdStaticField",
	"ClangdClass",
	"ClangdEnum",
	"ClangdEnumConstant",
	"ClangdTypedef",
	"ClangdDependentType",
	"ClangdDependentName",
	"ClangdNamespace",
	"ClangdTemplateParameter",
	"ClangdConcept",
	"ClangdPrimitive",
	"ClangdMacro",
	"ClangdInactiveCode"
}

M.capabilities = {
	worspace = {
		semanticTokens = {
			-- TODO: true
			refreshSupport = false
		}
	},
	textDocument = {
		semanticTokens = {
			dynamicRegistration = false,
			requests = {
				range = true,
				full = true
			},
			overlappingTokenSupport = false,
			multilineTokenSupport = false
		}
	}
}

function M.clear_buffer_highlight(bufnr)
	vim.validate { bufnr = {bufnr, 'n', true} }
	vim.api.nvim_buf_clear_namespace(bufnr,M.clangd_namespace,0,-1)
end

function M.highlight_ref(bufnr,ref)
	-- print(vim.inspect(ref))
	vim.api.nvim_buf_add_highlight(bufnr,M.clangd_namespace,ref.token,ref.line,ref.range_begin,ref.range_end)
end

function M.highlight_request(bufnr,data)
	if data == nil then
		return
	end
	local token_data = data["data"]
	if token_data==nil then
		vim.api.nvim_err_writeln("clangd-nvim: received empty response")
		return
	end

	local line = 0
	local pos = 0
	for i=1,#token_data,5 do
		local delta_line = token_data[i]
		local delta_pos = token_data[i+1]
		local length = token_data[i+2]
		local tokenType = token_data[i+3]
		-- Not used by clangd
		-- local tokenMods = token_data[i+4]

		if not (delta_line == 0) then
			line = line + delta_line
			pos = 0
		end
		pos = pos + delta_pos

		local ref = {
			line = line,
			range_begin = pos,
			range_end = pos + length,
			token = M.clangd_types[tokenType+1]
		}
		M.highlight_ref(bufnr,ref)
	end
end

function M.highlight_buffer_range(bufnr,line_begin,line_end)
	vim.validate { bufnr = { bufnr, 'n', true }}
	local params = {
		["textDocument"] = {
			["uri"] = vim.uri_from_bufnr(bufnr)
		},
		["range"] = {
			["start"] = { line_begin,0 },
			["end"] = { line_end,0 }
		}
	}
	vim.lsp.buf_request(bufnr,"textDocument/semanticTokens/range",params,function(_,_,data,_)
		vim.api.nvim_buf_clear_namespace(bufnr,M.clangd_namespace,line_begin,line_end)
		M.highlight_request(bufnr,data)
	end)
end

function M.highlight_buffer(bufnr)
	if bufnr == nil then
		bufnr = vim.api.nvim_get_current_buf()
	else
		vim.validate { bufnr = {bufnr, 'n', true} }
	end
	local params = {
		textDocument =  {
			uri = vim.uri_from_bufnr(bufnr)
		}
	}
	vim.lsp.buf_request(bufnr,"textDocument/semanticTokens/full",params,function(_,_,data,_)
		M.clear_buffer_highlight(bufnr)
		M.highlight_request(bufnr,data)
	end)
end

function M.on_attach(config)
	local bufnr = vim.api.nvim_get_current_buf()
	if (config.server_capabilities.semanticTokensProvider.range) then
		vim.api.nvim_buf_attach(bufnr, false, { on_lines = function(_,bufnr,_,first,_,last,_,_,_)
			M.highlight_buffer_range(bufnr,first,last)
		end})
	end
	M.highlight_buffer(bufnr)
end

return M
