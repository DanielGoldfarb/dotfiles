" Vim color file
" Maintainer:	Matthew Jimenez	<mjimenez@ersnet.net>
" Last Change:	2005 Feb 25

" darkblack -- an alteration to the darkblue colorscheme by Bohdan Vlasyuk <bohdan@vstu.edu.ua>
" Updated to use 256-color indices for vivid, palette-independent colors.


set bg=dark
hi clear
if exists("syntax_on")
	syntax reset
endif

let colors_name = "darkblack"

hi Normal	guifg=lightgrey guibg=lightblue	ctermfg=252 ctermbg=16
hi ErrorMsg	guifg=white guibg=lightblue	ctermfg=white ctermbg=lightblue
hi Visual	guifg=lightblue guibg=fg	gui=reverse	ctermfg=lightblue ctermbg=fg cterm=reverse
hi VisualNOS	guifg=lightblue guibg=fg	gui=reverse,underline	ctermfg=lightblue ctermbg=fg cterm=reverse,underline
hi Todo		guifg=red guibg=black	ctermfg=196	ctermbg=black
hi Search	guifg=white guibg=black	ctermfg=white ctermbg=black cterm=underline term=underline
hi IncSearch	guifg=darkgreen guibg=black	gui=reverse,underline	ctermfg=34 ctermbg=black cterm=reverse,underline

hi SpecialKey	guifg=cyan	ctermfg=37
hi Directory	guifg=cyan	ctermfg=51
hi Title	guifg=magenta gui=none ctermfg=201 cterm=bold
hi WarningMsg	guifg=red	ctermfg=196
hi WildMenu	guifg=yellow guibg=black ctermfg=226 ctermbg=black cterm=none term=none
hi ModeMsg	guifg=lightblue	ctermfg=117
hi MoreMsg	ctermfg=darkgreen	ctermfg=34
hi Question	guifg=green gui=none ctermfg=46 cterm=none
hi NonText	guifg=lightcyan	ctermfg=159

hi StatusLine	guifg=lightblue guibg=darkgray gui=none	ctermfg=117 ctermbg=240 term=none cterm=none
hi StatusLineNC	guifg=black guibg=darkgray gui=none	ctermfg=black ctermbg=240 term=none cterm=none
hi VertSplit	guifg=black guibg=darkgray gui=none	ctermfg=black ctermbg=240 term=none cterm=none

hi Folded	guifg=darkgrey guibg=black	ctermfg=245 ctermbg=black cterm=bold term=bold
hi FoldColumn	guifg=darkgrey guibg=black	ctermfg=245 ctermbg=black cterm=bold term=bold
hi LineNr	guifg=blue	ctermfg=63 cterm=none

hi DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
hi DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
hi DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
hi DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red

hi Cursor	guifg=bg guibg=lightgrey ctermfg=bg ctermbg=252
hi lCursor	guifg=bg guibg=darkgreen ctermfg=bg ctermbg=34

hi Comment	guifg=cyan ctermfg=51
hi Constant	ctermfg=201 guifg=magenta cterm=none
hi Special	ctermfg=208 guifg=Orange cterm=none gui=none
hi Identifier	ctermfg=51 guifg=cyan cterm=none
hi Statement	ctermfg=226 cterm=none guifg=yellow gui=none
hi PreProc	ctermfg=201 guifg=magenta gui=none cterm=none
hi type		ctermfg=46 guifg=green gui=none cterm=none
hi Underlined	cterm=underline term=underline
hi Ignore	guifg=bg ctermfg=bg
