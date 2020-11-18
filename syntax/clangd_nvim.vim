" MIT License
"
" Copyright (c) 2020 Robert John Oleynik
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the 'Software'), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.

" Link highlight groups
hi default link ClangdInactiveCode Comment

" Namespace
hi default link ClangdNamespace Namespace

" Types
hi default link ClangdClass cppType
hi default link ClangdEnum cppType
hi default link ClangdTypedef cppType
hi default link ClangdDependentType cppType
hi default link ClangdTemplateParameter cppType
hi default link ClangdPrimitive cppType
hi default link ClangdConcept cppType

" Function
hi default link ClangdFunction Function
hi default link ClangdMemberFunction Function
hi default link ClangdStaticMemberFunction Function
hi default link ClangdDependentName Function

" Macro
hi default link ClangdMacro Macro

" Constant
hi default link ClangdEnumConstant cppConstant

" Variables
hi default link ClangdField Variable
hi default link ClangdStaticField Variable
hi default link ClangdParameter Variable
hi default link ClangdVariable Variable
hi default link ClangdLocalVariable Variable

" Unknown
hi default link ClangdUnknown Normal
