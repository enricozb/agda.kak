# https://github.com/agda/agda
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# See https://agda.readthedocs.io/en/v2.7.0.1/language/lexical-structure.html

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*.agda$ %{
    set-option buffer filetype agda
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=agda %{
    require-module agda
    set-option window static_words %opt{agda_static_words}
    set-option -add buffer extra_word_chars .

    map window normal <c-a> ': enter-user-mode agda<ret>'
}

hook -group agda-highlight global WinSetOption filetype=agda %{
    add-highlighter window/agda ref agda
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/agda }
}

provide-module agda %§

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/agda regions
add-highlighter shared/agda/code default-region group
add-highlighter shared/agda/code/number regex \b\d+(\.\d+)?\b 0:value
add-highlighter shared/agda/code/constructor regex (?<!\.)\b([A-Z]\w+)\b(?!\.) 1:type
add-highlighter shared/agda/code/definition regex ^\h*([^\h.]+)\h*: 1:type
add-highlighter shared/agda/code/symbols regex \s(=|\|->|→|:|\?|λ|∀|\.{2,3}|Set)\s 1:function
add-highlighter shared/agda/double_string region '"' '(?<!\\)(\\\\)*"' fill string
add-highlighter shared/agda/single_string region "'" "'"               fill value
add-highlighter shared/agda/line-comment region '--' $ fill comment
add-highlighter shared/agda/block-comment region -recurse '\{-' '\{-' '-\}' fill comment

evaluate-commands %sh{
    # Grammar
    keywords="abstract|coinductive|constructor|data|do|eta-equality|field|forall"
    keywords="${keywords}|hiding|import|in|inductive|infix|infixl|infixr|instance"
    keywords="${keywords}|interleaved|let|macro|module|mutual|no-eta-equality|opaque"
    keywords="${keywords}|open|overlap|pattern|postulate|primitive|private|public"
    keywords="${keywords}|quote|quoteTerm|record|renaming|rewrite|syntax|tactic"
    keywords="${keywords}|unfolding|unquote|unquoteDecl|unquoteDef|using|variable"
    keywords="${keywords}|where|with|to|as"

    # Add the language's grammar to the static completion list
    printf '%s\n' "declare-option str-list agda_static_words ${keywords}" | tr '|' ' '

    # Highlight keywords
    printf "%s" "
        add-highlighter shared/agda/code/keywords regex '\b(${keywords})\b' 1:keyword
    "
}

§

# Commands
# ‾‾‾‾‾‾‾‾

declare-user-mode agda

map global agda m -docstring 'check' ': agda-check<ret>'

define-command -override agda-check %{
  popup \
    --title 'agda check' \
    -- \
    fish -c %{
      set output (agda --color=always $argv[1])

      if [ $status = 0 ]
        echo "Checked OK"
      else
        # joins the `output` list with `\n` as a separator
        echo {$output}\n
      end

      # wait for any keypress
      read -n 1 -s -P ''
    } %val{buffile}
}
